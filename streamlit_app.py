import streamlit as st
import json
import re
import pandas as pd
import _snowflake
import streamlit_folium

from snowflake.snowpark.context import get_active_session
from bin_request_retrieval import fetch_bin_request, fetch_bin_requests, mark_request_read
from call_here_api import (
    call_routing_here_api,
    call_geocoding_here_api,
    decode_polyline,
    display_map,
)

session = get_active_session()

API_ENDPOINT = "/api/v2/cortex/agent:run"
API_TIMEOUT  = 50_000  # milliseconds

SEMANTIC_MODELS        = "@pnp.etremblay.models/sales_metrics_model.yaml"
CORTEX_SEARCH_SERVICES = "pnp.etremblay.sales_conversation_search"
CORTEX_MODEL           = "claude-4-sonnet"


def process_sse_response(events):
    """Parse SSE events into (text, sql, citations)."""
    text, sql, citations = "", "", []
    for evt in events:
        if evt.get("event") == "message.delta":
            for c in evt["data"]["delta"].get("content", []):
                if c["type"] == "text":
                    text += c["text"]
                elif c["type"] == "tool_results":
                    for r in c["tool_results"]["content"]:
                        if r["type"] == "json":
                            j = r["json"]
                            text += j.get("text", "")
                            sql = j.get("sql", sql)
                            for sr in j.get("searchResults", []):
                                citations.append({
                                    "source_id": sr.get("source_id",""),
                                    "doc_id":    sr.get("doc_id","")
                                })
    return text.strip(), sql.strip(), citations


def run_snowflake_query(sql):
    try:
        return session.sql(sql.replace(";", ""))
    except Exception as e:
        st.error(f"SQL error: {e}")
        return None


def extract_addresses(text: str) -> list[str]:
    prompt = (
        "Extract every full street address from this text and output only "
        "a JSON array of strings (no markdown). Example:\n"
        '["123 Main St City, ST 12345", "456 Rue Example Montréal QC H2X 1Y4"]\n\n'
        f"Text:\n```{text}```"
    )
    payload = {
        "model": CORTEX_MODEL,
        "messages": [
            {"role":"user","content":[{"type":"text","text":prompt}]}
        ],
    }
    resp = _snowflake.send_snow_api_request(
        "POST", API_ENDPOINT, {}, {}, payload, None, API_TIMEOUT
    )
    if resp.get("status") != 200:
        st.error(f"Agent error: {resp.get('status')}")
        return []
    try:
        events = json.loads(resp.get("content","[]"))
    except json.JSONDecodeError:
        return []
    full_text, _, _ = process_sse_response(events)
    cleaned = re.sub(r"```(?:json)?","", full_text, flags=re.IGNORECASE).strip()
    m = re.search(r"\[.*\]", cleaned, flags=re.DOTALL)
    if not m:
        return []
    try:
        return json.loads(m.group(0))
    except json.JSONDecodeError:
        return []


def geocode_address(addr: str):
    try:
        geo = call_geocoding_here_api(addr)
        items = geo.get("items") or []
        if not items:
            return None, None
        pos = items[0]["position"]
        return pos["lat"], pos["lng"]
    except Exception as e:
        st.error(f"Geocoding failed: {e}")
        return None, None


def handle_address_logic(query: str, assistant_text: str) -> bool:
    """
    1) Ask Cortex to extract addresses from the **user’s query**.
    2) Fallback on "between ... and ...".
    3) If 1 address → geocode + st.map
    4) If 2 addresses → geocode + routing + display_map
    Returns True if we handled it here (and should skip the agent).
    """
    addrs = extract_addresses(query)
    if not addrs:
        m = re.search(r"between\s+(.*?)\s+and\s+(.*)", query, flags=re.IGNORECASE)
        if m:
            addrs = [m.group(1).strip(" ,."), m.group(2).strip(" ,.")]
    st.write("🔍 extracted addresses:", addrs)

    # Single-point map
    if len(addrs) == 1:
        lat, lon = geocode_address(addrs[0])
        if lat is not None:
            st.write(f"📍 Map for: **{addrs[0]}**")
            st.map(pd.DataFrame({"lat":[lat],"lon":[lon]}))
        return True

    # Route between two points
    if len(addrs) == 2:
        lat1, lon1 = geocode_address(addrs[0])
        lat2, lon2 = geocode_address(addrs[1])
        if None in (lat1, lon1, lat2, lon2):
            st.error("Could not geocode one or both addresses.")
            return True
        here_json = call_routing_here_api((lat1, lon1), (lat2, lon2))
        coords    = decode_polyline(here_json)
        display_map(coords)
        return True

    # nothing to do
    return False


def snowflake_api_call(prompt: str, limit: int = 5):
    """Call Cortex with only the two supported tools."""
    payload = {
        "model": CORTEX_MODEL,
        "messages":[{"role":"user","content":[{"type":"text","text":prompt}]}],
        "tool_choice": {"type":"auto"},
        "tools": [
            {"tool_spec":{"type":"cortex_analyst_text_to_sql","name":"analyst1"}},
            {"tool_spec":{"type":"cortex_search","name":"search1"}},
        ],
        "tool_resources": {
            "analyst1": {"semantic_model_file": SEMANTIC_MODELS},
            "search1": {
                "name":        CORTEX_SEARCH_SERVICES,
                "max_results": limit,
                "id_column":   "conversation_id"
            }
        }
    }
    resp = _snowflake.send_snow_api_request(
        "POST", API_ENDPOINT, {}, {}, payload, None, API_TIMEOUT
    )
    if resp.get("status") != 200:
        st.error(f"Agent HTTP error: {resp.get('status')}")
        st.write("🔍 Raw agent response:", resp)
        return []
    try:
        return json.loads(resp["content"])
    except json.JSONDecodeError as e:
        st.error(f"Failed to parse response JSON: {e}")
        return []


def direct_completion(prompt: str) -> str:
    """Fallback pure-text completion (no tools)."""
    payload = {
        "model": CORTEX_MODEL,
        "messages":[{"role":"user","content":[{"type":"text","text":prompt}]}]
    }
    resp = _snowflake.send_snow_api_request(
        "POST", API_ENDPOINT, {}, {}, payload, None, API_TIMEOUT
    )
    if resp.get("status") != 200:
        st.error(f"Completion HTTP error: {resp.get('status')}")
        return ""
    try:
        events = json.loads(resp["content"])
    except json.JSONDecodeError:
        return ""
    text = ""
    for evt in events:
        if evt.get("event") == "message.delta":
            for c in evt["data"]["delta"].get("content", []):
                if c["type"] == "text":
                    text += c["text"]
    return text.strip()


def main():
    st.title("🚚 Bin Management & Mapping Assistant")

    # Sidebar navigation
    page = st.sidebar.radio("Select view:", ["Customers list", "New requests", "Prospecting"])

    # ── Prospecting view
    if page == "Customers list":
        if "messages" not in st.session_state:
            st.session_state.messages = []

        query = "SELECT * FROM CUSTOMERS_WEBINAR_202508"
        df = run_snowflake_query(query)
        if df is not None:
            pdf = df.to_pandas()

            # ── Map of customer addresses ───────────────────────────────────────
            # assumes your table has a FULL_ADDRESS column
            coords = []
            for addr in pdf["FULL_ADDRESS"].dropna().unique():
                lat, lon = geocode_address(addr)
                if lat is not None and lon is not None:
                    coords.append({"lat": lat, "lon": lon})
            if coords:
                st.map(pd.DataFrame(coords))
            else:
                st.info("No valid addresses to map")

            # ── Scrollable customer table ──────────────────────────────────────
            
            st.dataframe(
                pdf,
                height=350,           # about 10–12 rows before scrolling
                use_container_width=True
            )

# ── New requests view
    elif page == "New requests":
      
        # fetch raw emails (with message_id, body, comment, etc.)
        df_emails = run_snowflake_query("SELECT * FROM emails_webinar_202508")
        if df_emails is None:
            st.error("Failed to fetch emails_webinar_202508.")
        else:
            email_pdf = df_emails.to_pandas()
            email_pdf.columns = email_pdf.columns.str.lower()
            email_pdf = email_pdf.reset_index(drop=True)

            if email_pdf.empty:
                st.info("No emails found in emails_webinar_202508.")
            else:
                # pagination
                if "email_page" not in st.session_state:
                    st.session_state.email_page = 0
                page_size = 5
                total     = len(email_pdf)
                n_pages   = (total - 1) // page_size + 1
                page      = st.session_state.email_page
                start     = page * page_size
                end       = min(start + page_size, total)

                # columns to list
                list_fields = [f for f in ("subject","received_at") if f in email_pdf.columns]
                page_df = (
                    email_pdf
                    .iloc[start:end]
                    .reset_index()
                    .rename(columns={"index":"orig_idx"})
                )

                # header
                col_widths = [1] + [4]*len(list_fields) + [1]
                hdr = st.columns(col_widths)
                hdr[0].markdown("**#**")
                for i, fld in enumerate(list_fields):
                    hdr[i+1].markdown(f"**{fld.replace('_',' ').title()}**")
                hdr[-1].markdown("**🔍**")

                # render rows
                if "selected_email_idx" not in st.session_state:
                    st.session_state.selected_email_idx = None

                for i, row in page_df.iterrows():
                    cols = st.columns(col_widths)
                    cols[0].write(start + i + 1)
                    for j, fld in enumerate(list_fields):
                        cols[j+1].write(row.get(fld, ""))
                    if cols[-1].button("🔍", key=f"view_{row.orig_idx}"):
                        st.session_state.selected_email_idx = int(row.orig_idx)

                # pagination controls
                nav1, nav2, nav3 = st.columns([1,2,1])
                if nav1.button("◀️ Prev", disabled=page == 0):
                    st.session_state.email_page = page - 1
                nav2.markdown(f"Page **{page+1}** of **{n_pages}**")
                if nav3.button("Next ▶️", disabled=page >= n_pages - 1):
                    st.session_state.email_page = page + 1

                # show details & editable fields
                sel_idx = st.session_state.selected_email_idx
                if sel_idx is not None and 0 <= sel_idx < total:
                    sel = email_pdf.loc[sel_idx]
                    st.markdown("---")
                    st.subheader(f"Details for Email #{sel_idx+1}")
                    st.markdown(f"**Body:**  \n{sel.get('body','*(no body found)*')}")
                    st.markdown(f"**Comment:**  \n{sel.get('comment','*(no comment found)*')}")

                    # fetch parsed fields just for this message_id
                    entry = fetch_bin_request(sel["message_id"])

                    # editable inputs with initial values
                    st.text_input(
                        "Container Format",
                        value=entry.get("container_format", ""),
                        key=f"fmt_email_{sel_idx}"
                    )
                    st.text_input(
                        "Quantity",
                        value=entry.get("quantity", ""),
                        key=f"qty_email_{sel_idx}"
                    )
                    st.text_input(
                        "Date Needed",
                        value=entry.get("date_needed", ""),
                        key=f"date_email_{sel_idx}"
                    )
                    st.text_input(
                        "Requester",
                        value=entry.get("requester", ""),
                        key=f"user_email_{sel_idx}"
                    )
                    st.text_input(
                        "Delivery Address",
                        value=entry.get("address", ""),
                        key=f"user_semail_{sel_idx}"
                    )

        # fall through to existing bin‑requests review UI
            c1, c2, c3 = st.columns(3)
            if c1.button("✅ Approve"):
               # mark_request_read(mid)
                st.success("Approved")
            if c2.button("❌ Reject"):
              #  mark_request_read(mid)
                st.warning("Rejected")
            if c3.button("📤 Generate Proposal"):
#                st.session_state.req_idx += 1
                st.success("Proposal Generated")

   
    # ── Prospecting view
    elif page == "Prospecting":
        if "messages" not in st.session_state:
            st.session_state.messages = []

        # replay prior chat
        for msg in st.session_state.messages:
            who = "You" if msg["role"] == "user" else "Assistant"
            st.markdown(f"**{who}:** {msg['content']}")

        query = st.text_input("Your question:", key="chat_input")
        if st.button("Send", key="chat_send") and query:
            st.session_state.messages.append({"role": "user", "content": query})

            # 1) Address/route override?
            if handle_address_logic(query, ""):
                # mapping has been displayed, skip the rest
                return

            # 2) Fire the 2‑tool agent
            events = snowflake_api_call(query)
            text, sql, citations = process_sse_response(events or [])

            # 3) FALLBACK on plain completion *any time* there was no SQL
            did_fallback = False
            if not sql:
                text = direct_completion(query)
                did_fallback = True

            # 4) Show the assistant’s answer
            if text:
                st.session_state.messages.append({"role": "assistant", "content": text})
                st.markdown(f"**Assistant:** {text}")

            # 5) If we did generate SQL, show it and its results
            if sql:
                st.markdown("### Generated SQL")
                st.code(sql, language="sql")
                df = run_snowflake_query(sql)
                if df is not None:
                    st.write("### Results")
                    st.dataframe(df)

            # 6) Only show citations if we *didn’t* fallback
            if not did_fallback and citations:
                st.write("Citations:")
                for c in citations:
                    lbl = str(c.get("source_id", "source"))
                    doc_id = c.get("doc_id", "")
                    q_sql = (
                        "SELECT transcript_text "
                        "FROM sales_conversations "
                        f"WHERE conversation_id = '{doc_id}'"
                    )
                    df2 = run_snowflake_query(q_sql)
                    txt = "No transcript available"
                    if df2 is not None:
                        pdf = df2.to_pandas()
                        if not pdf.empty:
                            txt = pdf.iloc[0, 0]
                    with st.expander(lbl):
                        st.write(txt)

    # ── Sidebar: reset chat
    if st.sidebar.button("🔄 New Conversation", key="new_chat"):
        st.session_state.messages = []
        st.rerun()


if __name__ == "__main__":
    main()

