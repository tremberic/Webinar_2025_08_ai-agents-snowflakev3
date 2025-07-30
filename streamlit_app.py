import threading
from precisely_sdk.server import FastMCP    # or `from fastmcp import FastMCP`
import os

def _start_mcp():
    mcp = FastMCP(
      name="Precisely MCP Server",
      host="0.0.0.0",
      port=8000,
      log_level="INFO"
    )
    mcp.run(transport="sse")

# Launch MCP in background
threading.Thread(target=_start_mcp, daemon=True).start()


import streamlit as st
import json
import re
import pandas as pd
import _snowflake
import subprocess
import threading
import queue
import requests

from snowflake.snowpark.context import get_active_session
from bin_request_retrieval import fetch_bin_requests, mark_request_read
from call_here_api import (
    call_routing_here_api,
    call_geocoding_here_api,
    decode_polyline,
    display_map,
)

session = get_active_session()

API_ENDPOINT = '/api/v2/cortex/agent:run'
API_TIMEOUT  = 50_000  # milliseconds

SEMANTIC_MODELS        = '@pnp.etremblay.models/sales_metrics_model.yaml'
CORTEX_SEARCH_SERVICES = 'pnp.etremblay.sales_conversation_search'
CORTEX_MODEL           = 'claude-4-sonnet'




# Then your normal imports…
import streamlit as st
import requests
# …
MCP_URL = "http://localhost:8000"


def ask_mcp(prompt: str) -> str:
    """Send a single SSE‐style JSON request and collect the streamed answer."""
    payload = {"input": {"content": prompt}}
    try:
        # request SSE stream
        resp = requests.post(MCP_URL, json=payload, stream=True, timeout=10)
        resp.raise_for_status()
        answer = ""
        for line in resp.iter_lines(decode_unicode=True):
            if not line or not line.startswith("data:"):
                continue
            # strip the "data: " prefix
            chunk = line[len("data:"):].strip()
            if chunk == "[DONE]":
                break
            obj = json.loads(chunk)
            # accumulate text deltas
            for c in obj.get("output", {}).get("content", []):
                if isinstance(c, dict) and c.get("type")=="text":
                    answer += c["text"]
        return answer.strip()
    except Exception as e:
        st.error(f"⚠️ MCP HTTP/SSE error: {e}")
        return "⚠️ Could not reach MCP server"
        


def process_sse_response(events):
    """Parse SSE events into (text, sql, citations, tools)."""
    text, sql, citations, tools = "", "", [], []
    for evt in events:
        if evt.get('event') == 'message.delta':
            for c in evt['data']['delta'].get('content', []):
                if c['type'] == 'text':
                    text += c['text']
                elif c['type'] == 'tool_results':
                    tools.extend(c['tool_results'].get('tool_names', []))
                    for r in c['tool_results']['content']:
                        if r['type'] == 'json':
                            j = r['json']
                            text += j.get('text', '')
                            sql = j.get('sql', sql)
                            for sr in j.get('searchResults', []):
                                citations.append({
                                    'source_id': sr.get('source_id',''),
                                    'doc_id':    sr.get('doc_id','')
                                })
    return text.strip(), sql.strip(), citations, tools


def run_snowflake_query(sql):
    try:
        return session.sql(sql.replace(';', ''))
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
        'model': CORTEX_MODEL,
        'messages': [{'role':'user','content':[{'type':'text','text':prompt}]}],
    }
    resp = _snowflake.send_snow_api_request(
        'POST', API_ENDPOINT, {}, {}, payload, None, API_TIMEOUT
    )
    if resp.get('status') != 200:
        st.error(f"Agent error: {resp.get('status')}")
        return []
    try:
        events = json.loads(resp.get('content','[]'))
    except json.JSONDecodeError:
        return []
    full_text, _, _, _ = process_sse_response(events)
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
        items = geo.get('items') or []
        if not items:
            return None, None
        pos = items[0]['position']
        return pos['lat'], pos['lng']
    except Exception as e:
        st.error(f"Geocoding failed: {e}")
        return None, None


def handle_address_logic(query: str) -> bool:
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
            addrs = [m.group(1).strip(' ,.'), m.group(2).strip(' ,.')]
    st.write("🔍 extracted addresses:", addrs)

    if len(addrs) == 1:
        lat, lon = geocode_address(addrs[0])
        if lat is not None:
            st.write(f"📍 Map for: **{addrs[0]}**")
            st.map(pd.DataFrame({'lat':[lat],'lon':[lon]}))
        return True

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

    return False


SYSTEM_PROMPT = """
You are a helpful mapping assistant that can extract addresses, run SQL against our sales DB,
and call external routing/geocoding tools. Respond concisely and only return JSON where requested.
"""


def agent_call(messages, limit=5):
    payload = {
        'model': CORTEX_MODEL,
        'messages': [
            {'role':'system','content':[{'type':'text','text':SYSTEM_PROMPT}]},
            *[
                {'role':m['role'], 'content':[{'type':'text','text':m['content']}]}
                for m in messages
            ]
        ],
        'tool_choice':{'type':'auto'},
        'tools': [
            {'tool_spec':{'type':'cortex_search','name':'search1'}},
            {'tool_spec':{'type':'cortex_analyst_text_to_sql','name':'analyst1'}},
            {'tool_spec':{'type':'http_request','name':'here_geocode'}},
            {'tool_spec':{'type':'http_request','name':'here_route'}}
        ],
        'tool_resources': {
            'search1':  {'name':CORTEX_SEARCH_SERVICES,'max_results':limit,'id_column':'conversation_id'},
            'analyst1': {'semantic_model_file':SEMANTIC_MODELS},
            'here_geocode': {
                'base_url':'https://geocode.search.hereapi.com/v1',
                'api_key':_snowflake.get_generic_secret_string('here_api_key'),
                'allowed_paths':['/v1/geocode']
            },
            'here_route': {
                'base_url':'https://router.hereapi.com/v8',
                'api_key':_snowflake.get_generic_secret_string('here_api_key'),
                'allowed_paths':['/v8/routes']
            }
        }
    }
    resp = _snowflake.send_snow_api_request('POST', API_ENDPOINT, {}, {}, payload, None, API_TIMEOUT)
    return json.loads(resp['content']) if resp.get('status') == 200 else []


def direct_completion(prompt: str) -> str:
    """Fallback pure-text completion (no tools)."""
    payload = {'model': CORTEX_MODEL, 'messages':[{'role':'user','content':[{'type':'text','text':prompt}]}]}
    resp = _snowflake.send_snow_api_request('POST', API_ENDPOINT, {}, {}, payload, None, API_TIMEOUT)
    if resp.get('status') != 200:
        st.error(f"Completion HTTP error: {resp.get('status')}")
        return ""
    try:
        events = json.loads(resp['content'])
    except json.JSONDecodeError:
        return ""
    text = ""
    for evt in events:
        if evt.get('event') == 'message.delta':
            for c in evt['data']['delta'].get('content', []):
                if c['type'] == 'text':
                    text += c['text']
    return text.strip()



def main():
    st.title("🚚 Bin Management & Mapping Assistant")
    tab1, tab2, tab3 = st.tabs(["Review Requests", "Cortex Assistant", "Precisely MCP"])

    # ── Tab 1: Bin request review ──────────────────────────────────────
    with tab1:
        requests_list = fetch_bin_requests()
        for req in requests_list:
            st.write(req)
            request_id = req.get('id') or req.get('request_id') or req.get('bin_id')
            if not request_id:
                st.warning("No ID found; skipping this request")
                continue
            if st.button(f"Mark {request_id} as read", key=f"mark_{request_id}"):
                mark_request_read(request_id)
                st.experimental_rerun()

    # ── Tab 2: Unified Chat + Maps + MCP ───────────────────────────────
    with tab2:
        if 'messages' not in st.session_state:
            st.session_state.messages = []

        # replay history
        for msg in st.session_state.messages:
            who = 'You' if msg['role']=='user' else 'Assistant'
            st.markdown(f"**{who}:** {msg['content']}")

        query = st.text_input("Your question:", key="chat_input")
        if st.button("Send", key="chat_send") and query:
            st.session_state.messages.append({'role':'user','content':query})

            # 1) Address/route override?
            if handle_address_logic(query):
                return

            # 2) Call Cortex agent
            events = agent_call(st.session_state.messages)
            text, sql, citations, tools = process_sse_response(events)

            # 3) Show which tools ran
            if tools:
                st.write("🛠️ Cortex tools used:", ", ".join(tools))

            # 4) If SQL generated, execute and display
            if sql:
                st.markdown("### Generated SQL")
                st.code(sql, language="sql")
                df = run_snowflake_query(sql)
                if df is not None:
                    st.write("### Results")
                    st.dataframe(df)

            # 5) Display text answer
            if text:
                st.session_state.messages.append({'role':'assistant','content':text})
                st.markdown(f"**Assistant:** {text}")

            # 6) Show citations
            if citations:
                st.write("Citations:")
                for c in citations:
                    lbl = c.get('source_id','source')
                    doc_id = c.get('doc_id','')
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
                            txt = pdf.iloc[0,0]
                    with st.expander(lbl):
                        st.write(txt)


    # ── Tab 3: Precisely MCP ───────────────────────────────────────────
    with tab3:
        st.subheader("Ask the Precisely MCP Geo Agent")
        mcp_query = st.text_input("Your question for the Geo Agent:", key="mcp_input")
        if st.button("Ask MCP", key="mcp_send") and mcp_query:
            with st.spinner("Asking MCP..."):
                mcp_reply = ask_mcp(mcp_query)
                st.markdown(mcp_reply)

    # ── Sidebar: reset conversation ────────────────────────────────────
    with st.sidebar:
        if st.button("🔄 New Conversation"):
            st.session_state.messages = []
            st.rerun()


if __name__ == '__main__':
    main()
