#call_precisely_api.py 
import streamlit as st
import _snowflake
import requests
import os
import base64

# ── Precisely Demographics By Address helper ───────────────────────────────
PRECISELY_DEMO_URL = "https://api.precisely.com/demographics-segmentation/v1/basic/demographics" # :contentReference[oaicite:0]{index=0}

PRECISELY_AUTH_URL = "https://api.precisely.com/oauth/token"

#Precisely precisely_api_key vs precisely_api_secret??

api_key = _snowflake.get_generic_secret_string("precisely_api_key")
#os.environ["precisely_api_key"] = secret

api_secret = _snowflake.get_generic_secret_string("precisely_api_secret")
#os.environ["precisely_api_key"] = secret


def get_access_token(api_key, api_secret, auth_url):

    credentials = f"{api_key}:{api_secret}"
    st.error(f"Credetials: {credentials}")
    encoded_credentials = base64.b64encode(credentials.encode('utf-8')).decode('utf-8')
    headers = {
        'Authorization': f'Basic {encoded_credentials}',
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    data = {'grant_type': 'client_credentials', 'scope': 'default'}
    response = requests.post(auth_url, headers=headers, data=data)
    print(f"Response: {response.json()}")
    response.raise_for_status()
    access_token = response.json().get('access_token')
    print(f"Access token fetched: {access_token}")
    st.error(f"Response: {response.json()}")
    return access_token


def call_precisely_demographics(address: str) -> dict:
    token = get_access_token(api_key, api_secret, PRECISELY_AUTH_URL)
    params = {
        "address": address,
        "country": "USA",
        "valueFormat": "PercentAsAvailable",
        "variableLevel": "Key",
    }
    headers = {'Authorization': f'Bearer {token}'}
    resp = requests.get(PRECISELY_DEMO_URL, params=params, headers=headers, timeout=30)
    if resp.status_code == 200:
        return resp.json()
    st.error(f"Demographics API error {resp.status_code}: {resp.text}")
    return {}

