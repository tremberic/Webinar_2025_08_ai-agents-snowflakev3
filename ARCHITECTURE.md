# Application Architecture

This document outlines the architecture of the Snowflake Geo AI Webinar application.

## Overall Architecture

The application is an **Snowflake Geo AI Webinar** built as a [Streamlit](https://streamlit.io/) web application. It provides a user interface for sales teams to analyze sales data, manage incoming customer requests, and explore new sales prospects.

The entire backend, including data storage, processing, and artificial intelligence capabilities, is powered by [Snowflake](https://www.snowflake.com/). The Streamlit application connects to Snowflake to execute queries, run AI models, and interact with external APIs through Snowflake's external access integrations.

## Implementation Summary
The Streamlit frontend exposes three primary pages—Customers List, New Requests, and Prospecting Chat—each interacting with Snowflake as the single backend via secure integrations and Cortex AI tooling.

-   **Customers List** queries "CUSTOMERS" table for customer data, geocodes addresses through the HERE API, and renders locations on a map.
-   **New Requests** pulls unread emails from "EMAILS" table. For each email body, SNOWFLAKE.CORTEX.COMPLETE is invoked to parse and extract structured request fields (e.g., container format, quantity, date needed) and extract_addresses is used to prefill delivery addresses. Parsed data is presented for user review/approval.
-   **Prospecting Chat** first evaluates whether the user query contains one or two addresses. If so, it handles geocoding/routing via the HERE API and then, after re-extracting, enriches the first detected address with demographic data from the Precisely API. If no address is present, the query is forwarded to the Cortex Agent. The agent dynamically decides between:
    -   **Cortex Analyst** for converting natural language metric queries into SQL against sales_metrics,
    -   **Cortex Search** for semantic retrieval from sales_conversations,
    -   or a **fallback general completion** when structured intent cannot be resolved. Results, relevant transcript snippets, and any enriched or mapped data are returned to the user in the chat interface.
-   All external API calls (HERE and Precisely) are performed via Snowflake External Access Integrations with secrets stored securely. The sales_conversation_search Cortex Search service indexes transcript text to support semantic lookups. This summary reflects the live decision tree and enrichment logic in the implementation, including the fact that Precisely enrichment is applied only to the first extracted address when present.

## AI Elements (Snowflake Cortex)

The application's intelligence is driven by several features of **Snowflake Cortex**. These AI capabilities are used to understand natural language, search through unstructured data, and automate data extraction.

### Cortex Analyst

-   **Purpose**: To convert natural language questions into SQL queries.
-   **Usage**: In the "Prospecting" chat interface, when a user asks a question about sales metrics (e.g., "What are my top 3 deals?"), Cortex Analyst is used to translate that question into a SQL query that can be run against the `SALES_METRICS` table.
-   **Configuration**: The behavior of Cortex Analyst is guided by the `sales_metrics_model.yaml` file. This file defines the schema, dimensions, measures, and synonyms for the `SALES_METRICS` table, helping the model understand the business context and generate accurate SQL.

### Cortex Search

-   **Purpose**: To perform semantic search on unstructured text data.
-   **Usage**: Cortex Search is used in the "Prospecting" chat to find relevant information within sales conversation transcripts. When a user asks a question like "Tell me about the call with Securebank?", Cortex Search finds the most relevant conversation transcript from the `sales_conversations` table.
-   **Configuration**: A Cortex Search Service named `sales_conversation_search` is created in `setup.sql`. It indexes the `transcript_text` column of the `sales_conversations` table.

### Cortex Agents

-   **Purpose**: To act as an orchestrator that can use multiple "tools" (like Cortex Analyst and Cortex Search) to answer a complex question.
-   **Usage**: The main "Prospecting" chat interface uses a Cortex Agent. When a user asks a question, the agent decides whether to use Cortex Analyst (for analytical queries), Cortex Search (for searching transcripts), or a combination of both. This is handled by the `snowflake_api_call` function in `streamlit_app.py`.
-   **Agent orchestration logic**: 
    -   If handle_address_logic returns False (i.e., no address scenario), the query goes to the Cortex Agent via snowflake_api_call(query).
    -   That call uses two tools:
        -   Cortex Analyst (text-to-SQL against sales_metrics using sales_metrics_model.yaml)
        -   Cortex Search (semantic search over sales_conversations)
        -   The agent auto-selects which tool(s) to use.
    -   If Analyst produces SQL, it’s shown/sent to Snowflake and results rendered; if no SQL is inferred, there is a fallback to a plain LLM completion (direct_completion).
    -   Citations from Search are used to fetch and display relevant conversation transcripts.


### Cortex `COMPLETE` Function

-   **Purpose**: For general-purpose Large Language Model (LLM) tasks, such as summarization or data extraction.
-   **Usage**:
    -   In `bin_request_retrieval.py`, `SNOWFLAKE.CORTEX.COMPLETE` is used to parse the body of incoming emails and extract a structured JSON object containing details like "container_format", "quantity", "date_needed", and "requester".
    -   In `streamlit_app.py`, it's used by the `extract_addresses` function to find and extract street addresses from a block of text.

## External API Calls

The application integrates with two external APIs for location-based data and demographics. The calls to these APIs are made from within Snowflake using **External Access Integrations**, which is a secure way to call external APIs from Snowflake.

### HERE API

-   **Purpose**: To provide geolocation and routing services.
-   **Usage**:
    -   **Geocoding**: The `call_geocoding_here_api` function in `call_here_api.py` is used to convert customer addresses into latitude and longitude coordinates. This is used in the "Customers list" page to display customers on a map.
    -   **Routing**: The `call_routing_here_api` function is used in the "Prospecting" page to calculate and display a route on a map when the user provides two addresses.
-   **Security**: The HERE API key is stored as a secure secret in Snowflake (`here_api_key`) and is accessed via an External Access Integration (`here_api_access_int`).

### Precisely API

-   **Purpose**: To enrich address data with demographics.
-   **Usage**: The `call_precisely_demographics` function in `call_precisely_api.py` is called from the "Prospecting" page. When a user enters an address, this function calls the Precisely API to fetch demographic information for that location.
-   **Security**: The Precisely API key is also stored as a Snowflake secret (`precisely_api_secret`) and accessed through an External Access Integration (`precisely_api_access_int`).

## Application Flow (`streamlit_app.py`)

The user interface is a Streamlit application with three main pages, each serving a distinct purpose.

### Customers list

-   This page displays a list of all customers from the "`"CUSTOMERS" table.
-   It iterates through the customer addresses, uses the **HERE API** to geocode them, and then displays all customer locations on a map.
-    Customers list page currently only uses the HERE API for geocoding customer addresses; it does not call Precisely for enrichment (potential enhancement).

### New requests

-   This page is designed for processing incoming service requests from emails.
-   It fetches unread emails from the "EMAILS" table.
-   For each email, it uses the **Cortex `COMPLETE`** function (via `bin_request_retrieval.py`) to parse the email body and extract structured data (container format, quantity, etc.).
-   It also uses a Cortex-powered function (`extract_addresses`) to automatically find and suggest the delivery address from the email text.
-   The user can then review, approve, or reject the request.

### Prospecting

-   This is the main chat-based interface for sales analysis and prospecting.
-   It has special logic to handle queries that contain addresses:
    -   If one address is detected, it uses the **HERE API** to show it on a map and the **Precisely API** to fetch and display demographic data for that location.
    -   If two addresses are detected, it uses the **HERE API** to calculate and display a driving route between them.
    -   If the user query contains an address (or a ‘between X and Y’ pair), the system enriches the first extracted address with demographic data from Precisely.”
-   For all other queries, it uses the **Cortex Agent** to get an answer. The agent, in turn, uses **Cortex Analyst** to query structured `SALES_METRICS` data and **Cortex Search** to find information in unstructured `sales_conversations` data.


## Database Setup (`setup.sql`)

The backend database is set up and configured using the `setup.sql` script. This script is responsible for:

-   Creating the database schema and tables.
-   Inserting sample data for conversations, metrics, customers, and emails.
-   Creating the **Cortex Search Service** on the `sales_conversations` table.
-   Configuring the **External Access Integrations** required for Snowflake to securely call the HERE and Precisely APIs.

### Main Tables

-   `sales_conversations`: Stores unstructured text data from sales call transcripts.
-   `sales_metrics`: Stores structured data about sales deals, such as deal value, stage, and status.
-   `CUSTOMERS_WEBINAR_202508`: Stores information about customers, including their addresses.
-   `emails_webinar_202508`: Stores incoming emails that are processed as new service requests.