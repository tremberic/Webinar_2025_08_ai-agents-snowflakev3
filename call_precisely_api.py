#call_precisely_api.py 
import streamlit as st
import _snowflake
import requests
import os

# ── Precisely Demographics By Address helper ───────────────────────────────
PRECISELY_DEMO_URL = (
    "https://api.precisely.com/"
    "demographics-segmentation/v1/demographics/byaddress"
)  # :contentReference[oaicite:0]{index=0}

#Precisely precisely_api_key vs precisely_api_secret??

#secret = _snowflake.get_generic_secret_string("precisely_api_key")
#os.environ["precisely_api_key"] = secret

secret = _snowflake.get_generic_secret_string("precisely_api_secret")
os.environ["precisely_api_key"] = secret

def call_precisely_demographics(address: str) -> dict:
    params = {
        "address": address,
        "country": "USA",
        "valueFormat": "PercentAsAvailable",
        "variableLevel": "Key",
    }
    headers = {"apikey": secret}
    resp = requests.get(PRECISELY_DEMO_URL, params=params, headers=headers, timeout=30)
    if resp.status_code == 200:
        return resp.json()
    st.error(f"Demographics API error {resp.status_code}: {resp.text}")
    return {}

