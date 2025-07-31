-- Create database and schema
--CREATE OR REPLACE DATABASE sales_intelligence;
--CREATE OR REPLACE SCHEMA sales_intelligence.data;
--CREATE OR REPLACE WAREHOUSE sales_intelligence_wh;

USE DATABASE PNP;
USE SCHEMA ETREMBLAY;

-- Create tables for sales data
CREATE TABLE sales_conversations (
    conversation_id VARCHAR,
    transcript_text TEXT,
    customer_name VARCHAR,
    deal_stage VARCHAR,
    sales_rep VARCHAR,
    conversation_date TIMESTAMP,
    deal_value FLOAT,
    product_line VARCHAR
);

CREATE TABLE sales_metrics (
    deal_id VARCHAR,
    customer_name VARCHAR,
    deal_value FLOAT,
    close_date DATE,
    sales_stage VARCHAR,
    win_status BOOLEAN,
    sales_rep VARCHAR,
    product_line VARCHAR
);

CREATE TABLE sales_metrics (
    deal_id VARCHAR,
    customer_name VARCHAR,
    deal_value FLOAT,
    close_date DATE,
    sales_stage VARCHAR,
    win_status BOOLEAN,
    sales_rep VARCHAR,
    product_line VARCHAR
);


```sql
CREATE OR REPLACE TABLE emails_webinar_202508 ( (
  id             NUMBER AUTOINCREMENT
                  COMMENT 'Surrogate primary key for each email record',
  
  message_id     VARCHAR(255)
                  COMMENT 'Unique message identifier assigned by the mail provider',
  
  thread_id      VARCHAR(255)
                  COMMENT 'Identifier grouping related messages into a conversation thread',
  
  from_address   VARCHAR(320)
                  COMMENT 'Email address of the sender (max 320 chars per RFC)',
  
  to_addresses   VARCHAR(1000)
                  COMMENT 'Comma‑separated list of primary recipient email addresses',
  
  cc_addresses   VARCHAR(1000)
                  COMMENT 'Comma‑separated list of CC recipient email addresses',
  
  bcc_addresses  VARCHAR(1000)
                  COMMENT 'Comma‑separated list of BCC recipient email addresses',
  
  subject        VARCHAR(1000)
                  COMMENT 'Subject line of the email message',
  
  body           STRING
                  COMMENT 'Full message body (plain‑text or HTML)',
  
  sent_at        TIMESTAMP_NTZ
                  COMMENT 'When the email was sent (no time zone stored)',
  
  received_at    TIMESTAMP_NTZ
                  COMMENT 'When the email was received or ingested',
  
  is_read        BOOLEAN DEFAULT FALSE
                  COMMENT 'Flag indicating whether the user has read this email',
  
  created_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
                  COMMENT 'Record insertion timestamp'
);
```
**Column Descriptions**

* **`id`**: Auto‑incrementing surrogate key.
* **`message_id`**: Provider’s unique message ID (e.g. Gmail/RFC‑822 Message‑ID).
* **`thread_id`**: Conversation/thread grouping key.
* **`from_address`**: Sender’s email address.
* **`to_addresses`**, **`cc_addresses`**, **`bcc_addresses`**: Comma‑separated recipient lists.
* **`subject`**: Email subject line.
* **`body`**: The full email payload (text or HTML).
* **`sent_at`** / **`received_at`**: Timestamps for send and receive events.
* **`is_read`**: Read/unread status flag.
* **`created_at`**: When this row was inserted into the table.



-- First, let's insert data into sales_conversations
INSERT INTO sales_conversations
(conversation_id, transcript_text, customer_name, deal_stage, sales_rep, conversation_date, deal_value, product_line)
VALUES
('CONV001', 'Initial discovery call with TechCorp Inc''s IT Director and Solutions Architect. Client showed strong interest in our enterprise solution features, particularly the automated workflow capabilities. The main discussion centered around integration timeline and complexity. They currently use Legacy System X for their core operations and expressed concerns about potential disruption during migration. The team asked detailed questions about API compatibility and data migration tools.

Action items include providing a detailed integration timeline document, scheduling a technical deep-dive with their infrastructure team, and sharing case studies of similar Legacy System X migrations. The client mentioned a Q2 budget allocation for digital transformation initiatives. Overall, it was a positive engagement with clear next steps.', 'TechCorp Inc', 'Discovery', 'Sarah Johnson', '2024-01-15 10:30:00', 75000, 'Enterprise Suite'),

('CONV002', 'Follow-up call with SmallBiz Solutions'' Operations Manager and Finance Director. The primary focus was on pricing structure and ROI timeline. They compared our Basic Package pricing with Competitor Y''s small business offering. Key discussion points included monthly vs. annual billing options, user license limitations, and potential cost savings from process automation.

The client requested a detailed ROI analysis focusing on time saved in daily operations, resource allocation improvements, and projected efficiency gains. Budget constraints were clearly communicated, with a maximum budget of $30K for this year. They showed interest in starting with the basic package with room for a potential upgrade in Q4. Next steps include providing a competitive analysis and a customized ROI calculator by next week.', 'SmallBiz Solutions', 'Negotiation', 'Mike Chen', '2024-01-16 14:45:00', 25000, 'Basic Package'),

('CONV003', 'Strategy session with SecureBank Ltd''s CISO and Security Operations team. Extremely positive 90-minute deep dive into our Premium Security package. Customer emphasized immediate need for implementation due to recent industry compliance updates. Our advanced security features, especially multi-factor authentication and encryption protocols, were identified as perfect fits for their requirements. Technical team was particularly impressed with our zero-trust architecture approach and real-time threat monitoring capabilities. They''ve already secured budget approval and have executive buy-in. Compliance documentation is ready for review. Action items include: finalizing implementation timeline, scheduling security audit, and preparing necessary documentation for their risk assessment team. Client ready to move forward with contract discussions.', 'SecureBank Ltd', 'Closing', 'Rachel Torres', '2024-01-17 11:20:00', 150000, 'Premium Security'),

('CONV004', 'Comprehensive discovery call with GrowthStart Up''s CTO and Department Heads. Team of 500+ employees across 3 continents discussed current challenges with their existing solution. Major pain points identified: system crashes during peak usage, limited cross-department reporting capabilities, and poor scalability for remote teams. Deep dive into their current workflow revealed bottlenecks in data sharing and collaboration. Technical requirements gathered for each department. Platform demo focused on scalability features and global team management capabilities. Client particularly interested in our API ecosystem and custom reporting engine. Next steps: schedule department-specific workflow analysis and prepare detailed platform migration plan.', 'GrowthStart Up', 'Discovery', 'Sarah Johnson', '2024-01-18 09:15:00', 100000, 'Enterprise Suite'),

('CONV005', 'In-depth demo session with DataDriven Co''s Analytics team and Business Intelligence managers. Showcase focused on advanced analytics capabilities, custom dashboard creation, and real-time data processing features. Team was particularly impressed with our machine learning integration and predictive analytics models. Competitor comparison requested specifically against Market Leader Z and Innovative Start-up X. Price point falls within their allocated budget range, but team expressed interest in multi-year commitment with corresponding discount structure. Technical questions centered around data warehouse integration and custom visualization capabilities. Action items: prepare detailed competitor feature comparison matrix and draft multi-year pricing proposals with various discount scenarios.', 'DataDriven Co', 'Demo', 'James Wilson', '2024-01-19 13:30:00', 85000, 'Analytics Pro'),

('CONV006', 'Extended technical deep dive with HealthTech Solutions'' IT Security team, Compliance Officer, and System Architects. Four-hour session focused on API infrastructure, data security protocols, and compliance requirements. Team raised specific concerns about HIPAA compliance, data encryption standards, and API rate limiting. Detailed discussion of our security architecture, including: end-to-end encryption, audit logging, and disaster recovery protocols. Client requires extensive documentation on compliance certifications, particularly SOC 2 and HITRUST. Security team performed initial architecture review and requested additional information about: database segregation, backup procedures, and incident response protocols. Follow-up session scheduled with their compliance team next week.', 'HealthTech Solutions', 'Technical Review', 'Rachel Torres', '2024-01-20 15:45:00', 120000, 'Premium Security'),

('CONV007', 'Contract review meeting with LegalEase Corp''s General Counsel, Procurement Director, and IT Manager. Detailed analysis of SLA terms, focusing on uptime guarantees and support response times. Legal team requested specific modifications to liability clauses and data handling agreements. Procurement raised questions about payment terms and service credit structure. Key discussion points included: disaster recovery commitments, data retention policies, and exit clause specifications. IT Manager confirmed technical requirements are met pending final security assessment. Agreement reached on most terms, with only SLA modifications remaining for discussion. Legal team to provide revised contract language by end of week. Overall positive session with clear path to closing.', 'LegalEase Corp', 'Negotiation', 'Mike Chen', '2024-01-21 10:00:00', 95000, 'Enterprise Suite'),

('CONV008', 'Quarterly business review with GlobalTrade Inc''s current implementation team and potential expansion stakeholders. Current implementation in Finance department showcasing strong adoption rates and 40% improvement in processing times. Discussion focused on expanding solution to Operations and HR departments. Users highlighted positive experiences with customer support and platform stability. Challenges identified in current usage: need for additional custom reports and increased automation in workflow processes. Expansion requirements gathered from Operations Director: inventory management integration, supplier portal access, and enhanced tracking capabilities. HR team interested in recruitment and onboarding workflow automation. Next steps: prepare department-specific implementation plans and ROI analysis for expansion.', 'GlobalTrade Inc', 'Expansion', 'James Wilson', '2024-01-22 14:20:00', 45000, 'Basic Package'),

('CONV009', 'Emergency planning session with FastTrack Ltd''s Executive team and Project Managers. Critical need for rapid implementation due to current system failure. Team willing to pay premium for expedited deployment and dedicated support team. Detailed discussion of accelerated implementation timeline and resource requirements. Key requirements: minimal disruption to operations, phased data migration, and emergency support protocols. Technical team confident in meeting aggressive timeline with additional resources. Executive sponsor emphasized importance of going live within 30 days. Immediate next steps: finalize expedited implementation plan, assign dedicated support team, and begin emergency onboarding procedures. Team to reconvene daily for progress updates.', 'FastTrack Ltd', 'Closing', 'Sarah Johnson', '2024-01-23 16:30:00', 180000, 'Premium Security'),

('CONV010', 'Quarterly strategic review with UpgradeNow Corp''s Department Heads and Analytics team. Current implementation meeting basic needs but team requiring more sophisticated analytics capabilities. Deep dive into current usage patterns revealed opportunities for workflow optimization and advanced reporting needs. Users expressed strong satisfaction with platform stability and basic features, but requiring enhanced data visualization and predictive analytics capabilities. Analytics team presented specific requirements: custom dashboard creation, advanced data modeling tools, and integrated BI features. Discussion about upgrade path from current package to Analytics Pro tier. ROI analysis presented showing potential 60% improvement in reporting efficiency. Team to present upgrade proposal to executive committee next month.', 'UpgradeNow Corp', 'Expansion', 'Rachel Torres', '2024-01-24 11:45:00', 65000, 'Analytics Pro');

-- Now, let's insert corresponding data into sales_metrics
INSERT INTO sales_metrics
(deal_id, customer_name, deal_value, close_date, sales_stage, win_status, sales_rep, product_line)
VALUES
('DEAL001', 'TechCorp Inc', 75000, '2024-02-15', 'Closed', true, 'Sarah Johnson', 'Enterprise Suite'),

('DEAL002', 'SmallBiz Solutions', 25000, '2024-02-01', 'Lost', false, 'Mike Chen', 'Basic Package'),

('DEAL003', 'SecureBank Ltd', 150000, '2024-01-30', 'Closed', true, 'Rachel Torres', 'Premium Security'),

('DEAL004', 'GrowthStart Up', 100000, '2024-02-10', 'Pending', false, 'Sarah Johnson', 'Enterprise Suite'),

('DEAL005', 'DataDriven Co', 85000, '2024-02-05', 'Closed', true, 'James Wilson', 'Analytics Pro'),

('DEAL006', 'HealthTech Solutions', 120000, '2024-02-20', 'Pending', false, 'Rachel Torres', 'Premium Security'),

('DEAL007', 'LegalEase Corp', 95000, '2024-01-25', 'Closed', true, 'Mike Chen', 'Enterprise Suite'),

('DEAL008', 'GlobalTrade Inc', 45000, '2024-02-08', 'Closed', true, 'James Wilson', 'Basic Package'),

('DEAL009', 'FastTrack Ltd', 180000, '2024-02-12', 'Closed', true, 'Sarah Johnson', 'Premium Security'),

('DEAL010', 'UpgradeNow Corp', 65000, '2024-02-18', 'Pending', false, 'Rachel Torres', 'Analytics Pro');



INSERT INTO emails_webinar_202508 (
  message_id,
  thread_id,
  from_address,
  to_addresses,
  cc_addresses,
  bcc_addresses,
  subject,
  body,
  sent_at,
  received_at,
  is_read,
  created_at
)
SELECT
  UUID_STRING()                                                                                             AS message_id,
  UUID_STRING()                                                                                             AS thread_id,

  -- customer email
  ARRAY_CONSTRUCT(
    'alice.smith@gmail.com','bob.jones@yahoo.com','carol.lee@outlook.com',
    'dave.wilson@example.com','eve.moore@gmail.com','frank.taylor@yahoo.com',
    'grace.anderson@outlook.com','heidi.brown@example.com',
    'ivan.johnson@gmail.com','judy.white@yahoo.com'
  )[UNIFORM(0,10,RANDOM())]::VARCHAR                                                                         AS from_address,

  'sales@snowbins.ca'                                                                                       AS to_addresses,
  ''                                                                                                        AS cc_addresses,
  ''                                                                                                        AS bcc_addresses,

  /* SUBJECT – always complete */
  'Request for '
    || ARRAY_CONSTRUCT('10 yd³','15 yd³','20 yd³','30 yd³')[UNIFORM(0,4,RANDOM())]::VARCHAR
    || ' '
    || ARRAY_CONSTRUCT(
         'mixed waste','green waste','construction debris','concrete',
         'metal scrap','furniture','yard waste'
       )[UNIFORM(0,7,RANDOM())]::VARCHAR
    || ' container rental'                                                                                   AS subject,

  /* BODY – 80% precise, 20% vague */
  CASE
    WHEN UNIFORM(0,10,RANDOM()) < 8 THEN
      /* precise branch */
      ARRAY_CONSTRUCT('Hello','Hi','Greetings','Dear team')[UNIFORM(0,4,RANDOM())]::VARCHAR
      || ' SnowBins,' || '\n\n'
      || 'I need to rent a '
      || ARRAY_CONSTRUCT('10 yd³','15 yd³','20 yd³','30 yd³')[UNIFORM(0,4,RANDOM())]::VARCHAR
      || ' container for '
      || ARRAY_CONSTRUCT(
           'mixed waste','green waste','construction debris','concrete',
           'metal scrap','furniture','yard waste'
         )[UNIFORM(0,7,RANDOM())]::VARCHAR
      || ', approx ' || TO_VARCHAR(UNIFORM(1,10,RANDOM()))
      || IFF(UNIFORM(0,2,RANDOM())=0,' tons',' yd³')
      || '. Please deliver on '
      /* four date formats */
      || CASE UNIFORM(0,4,RANDOM())
           WHEN 0 THEN TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'YYYY-MM-DD'
                      )
           WHEN 1 THEN TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'Month DD, YYYY'
                      )
           WHEN 2 THEN TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'DD/MM/YYYY'
                      )
           ELSE      TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'DD Mon YYYY'
                      )
         END
      || ' for ' || TO_VARCHAR(UNIFORM(3,14,RANDOM())) || ' days at '
      || TO_VARCHAR(UNIFORM(100,999,RANDOM())) || ' '
      || ARRAY_CONSTRUCT(
           'Maple St','Oak St','Pine Ave','Elm Dr','Cedar Blvd',
           'Sunset Blvd','Lincoln Ave','Adams St','Madison Ave','Jefferson St'
         )[UNIFORM(0,10,RANDOM())]::VARCHAR
      || ', '
      || ARRAY_CONSTRUCT(
           'Los Angeles, CA','San Diego, CA','Sacramento, CA','San Jose, CA',
           'Fresno, CA','Bakersfield, CA','Oakland, CA','San Francisco, CA',
           'Irvine, CA','Riverside, CA'
         )[UNIFORM(0,10,RANDOM())]::VARCHAR
      || '\n\n'
      || ARRAY_CONSTRUCT('Thanks,','Best regards,','Cheers,','Sincerely,')[UNIFORM(0,4,RANDOM())]::VARCHAR
      || '\n'
      || SPLIT_PART(
           ARRAY_CONSTRUCT(
             'alice.smith@gmail.com','bob.jones@yahoo.com','carol.lee@outlook.com',
             'dave.wilson@example.com','eve.moore@gmail.com','frank.taylor@yahoo.com',
             'grace.anderson@outlook.com','heidi.brown@example.com',
             'ivan.johnson@gmail.com','judy.white@yahoo.com'
           )[UNIFORM(0,10,RANDOM())]::VARCHAR,
           '@',1
         )

    ELSE
      /* vague branch */
      ARRAY_CONSTRUCT('Hello','Hi','Greetings')[UNIFORM(0,3,RANDOM())]::VARCHAR
      || ' SnowBins,' || '\n\n'
      || 'I need '
      || ARRAY_CONSTRUCT('some containers','a few bins')[UNIFORM(0,2,RANDOM())]::VARCHAR
      || ' for '
      || ARRAY_CONSTRUCT('green waste','mixed waste','debris')[UNIFORM(0,3,RANDOM())]::VARCHAR
      || ' '
      || ARRAY_CONSTRUCT('end of August','early September')[UNIFORM(0,2,RANDOM())]::VARCHAR
      || ' at my usual location.'
      || '\n\n'
      || ARRAY_CONSTRUCT('Cheers,','Sincerely,')[UNIFORM(0,2,RANDOM())]::VARCHAR
      || '\n'
      || SPLIT_PART(
           ARRAY_CONSTRUCT(
             'alice.smith@gmail.com','bob.jones@yahoo.com','carol.lee@outlook.com',
             'dave.wilson@example.com','eve.moore@gmail.com','frank.taylor@yahoo.com',
             'grace.anderson@outlook.com','heidi.brown@example.com',
             'ivan.johnson@gmail.com','judy.white@yahoo.com'
           )[UNIFORM(0,10,RANDOM())]::VARCHAR,
           '@',1
         )
  END                                                                                                       AS body,
  /* sent_at: random Aug 2025, minus 1–5 days, plus random hour */
  DATEADD(
    'hour',
    UNIFORM(0,23,RANDOM()),
    DATEADD(
      'day',
      -UNIFORM(1,5,RANDOM()),
      DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE)
    )
  )                                                                                                         AS sent_at,

  /* received_at: 1–60 minutes later */
  DATEADD('minute', UNIFORM(1,60,RANDOM()), sent_at)                                                        AS received_at,

  /* is_read */
  IFF(UNIFORM(0,2,RANDOM())=0, TRUE, FALSE)                                                                  AS is_read,

  CURRENT_TIMESTAMP()                                                                                       AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

ALTER TABLE emails_webinar_202508 SET CHANGE_TRACKING = TRUE;


-- Enable change tracking
ALTER TABLE sales_conversations SET CHANGE_TRACKING = TRUE;

-- Create the search service
-- Peut aussi maintenant être fait via l'interfacde de Snowpark
CREATE OR REPLACE CORTEX SEARCH SERVICE sales_conversation_search
  ON transcript_text
  ATTRIBUTES customer_name, deal_stage, sales_rep, product_line, conversation_date, deal_value
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 minute'
  AS (
    SELECT
        conversation_id,
        transcript_text,
        customer_name,
        deal_stage,
        sales_rep,
        conversation_date,
        deal_value,
        product_line
    FROM sales_conversations
    WHERE conversation_date >= '2024-01-01'  -- Fixed date instead of CURRENT_TIMESTAMP
);

CREATE TABLE CUSTOMERS_WEBINAR_202508 (
    ID               NUMBER,    -- Unique customer ID
    NAME             VARCHAR(100) NOT NULL,
    EMAIL_ADDRESS    VARCHAR(255) NOT NULL UNIQUE,
    PHONE_NUMBER     VARCHAR(30),           -- Optional, supports various phone formats
    FULL_ADDRESS     VARCHAR(255) NOT NULL, -- Combined address as specified
    STREET_ADDRESS   VARCHAR(100),          -- Separate fields for searching/filtering
    CITY             VARCHAR(50),
    STATE            VARCHAR(50),
    POSTAL_CODE      VARCHAR(20),
    COUNTRY          VARCHAR(50),
    DATE_OF_BIRTH    DATE,                  -- Optional
    CREATED_AT       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Record creation date
    UPDATED_AT       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Last update
    STATUS           VARCHAR(20) NOT NULL DEFAULT 'active',        -- active, inactive, etc.
    NOTES            TEXT                   -- Optional comments about the customer
);

INSERT INTO CUSTOMERS_WEBINAR_202508
(NAME, EMAIL_ADDRESS, PHONE_NUMBER, FULL_ADDRESS, STREET_ADDRESS, CITY, STATE, POSTAL_CODE, COUNTRY, DATE_OF_BIRTH, STATUS, NOTES) VALUES
('Michael Brown', 'michael.brown@email.com', '646-555-0101', '1120 Madison Ave. New York, NY 10028', '1120 Madison Ave.', 'New York', 'NY', '10028', 'USA', '1981-04-12', 'active', ''),
('Sarah Wilson', 'sarah.wilson@email.com', '917-555-0110', '780 Columbus Ave. New York, NY 10025', '780 Columbus Ave.', 'New York', 'NY', '10025', 'USA', '1993-08-23', 'active', ''),
('David Lee', 'david.lee@email.com', '212-555-0115', '350 E 54th St. New York, NY 10022', '350 E 54th St.', 'New York', 'NY', '10022', 'USA', '1975-02-19', 'active', ''),
('Maria Garcia', 'maria.garcia@email.com', '917-555-0119', '1540 1st Ave. New York, NY 10028', '1540 1st Ave.', 'New York', 'NY', '10028', 'USA', '1989-05-14', 'inactive', ''),
('James Anderson', 'james.anderson@email.com', '646-555-0125', '230 E 83rd St. New York, NY 10028', '230 E 83rd St.', 'New York', 'NY', '10028', 'USA', '1997-09-05', 'pending', ''),
('Ashley Moore', 'ashley.moore@email.com', '212-555-0130', '159 W 53rd St. New York, NY 10019', '159 W 53rd St.', 'New York', 'NY', '10019', 'USA', '1984-10-10', 'active', ''),
('Joshua White', 'joshua.white@email.com', '718-555-0140', '245 W 99th St. New York, NY 10025', '245 W 99th St.', 'New York', 'NY', '10025', 'USA', '1986-03-28', 'active', ''),
('Amanda Martinez', 'amanda.martinez@email.com', '917-555-0150', '311 E 75th St. New York, NY 10021', '311 E 75th St.', 'New York', 'NY', '10021', 'USA', '1990-11-15', 'inactive', ''),
('Christopher Harris', 'christopher.harris@email.com', '646-555-0155', '600 W 110th St. New York, NY 10025', '600 W 110th St.', 'New York', 'NY', '10025', 'USA', '1987-07-02', 'active', ''),
('Elizabeth Clark', 'elizabeth.clark@email.com', '212-555-0160', '120 E 90th St. New York, NY 10128', '120 E 90th St.', 'New York', 'NY', '10128', 'USA', '1991-01-19', 'pending', ''),
('Matthew Robinson', 'matthew.robinson@email.com', '718-555-0167', '680 Riverside Dr. New York, NY 10031', '680 Riverside Dr.', 'New York', 'NY', '10031', 'USA', '1978-09-21', 'inactive', ''),
('Lauren Lewis', 'lauren.lewis@email.com', '917-555-0173', '405 E 63rd St. New York, NY 10065', '405 E 63rd St.', 'New York', 'NY', '10065', 'USA', '1995-04-27', 'active', ''),
('Brandon Walker', 'brandon.walker@email.com', '646-555-0179', '227 E 28th St. New York, NY 10016', '227 E 28th St.', 'New York', 'NY', '10016', 'USA', '1983-05-10', 'active', ''),
('Emily Hall', 'emily.hall@email.com', '212-555-0183', '305 W 50th St. New York, NY 10019', '305 W 50th St.', 'New York', 'NY', '10019', 'USA', '1994-08-13', 'active', ''),
('Andrew Allen', 'andrew.allen@email.com', '917-555-0186', '403 E 62nd St. New York, NY 10065', '403 E 62nd St.', 'New York', 'NY', '10065', 'USA', '1982-12-02', 'pending', ''),
('Samantha Young', 'samantha.young@email.com', '646-555-0192', '88 W 89th St. New York, NY 10024', '88 W 89th St.', 'New York', 'NY', '10024', 'USA', '1979-10-09', 'active', ''),
('Ryan King', 'ryan.king@email.com', '718-555-0197', '220 E 72nd St. New York, NY 10021', '220 E 72nd St.', 'New York', 'NY', '10021', 'USA', '1990-07-21', 'inactive', ''),
('Natalie Scott', 'natalie.scott@email.com', '212-555-0202', '150 W 51st St. New York, NY 10019', '150 W 51st St.', 'New York', 'NY', '10019', 'USA', '1985-06-11', 'active', ''),
('Justin Adams', 'justin.adams@email.com', '646-555-0210', '340 E 93rd St. New York, NY 10128', '340 E 93rd St.', 'New York', 'NY', '10128', 'USA', '1996-02-24', 'active', ''),
('Victoria Baker', 'victoria.baker@email.com', '917-555-0217', '99 Jane St. New York, NY 10014', '99 Jane St.', 'New York', 'NY', '10014', 'USA', '1987-03-07', 'pending', ''),
('Benjamin Carter', 'benjamin.carter@email.com', '212-555-0225', '135 W 96th St. New York, NY 10025', '135 W 96th St.', 'New York', 'NY', '10025', 'USA', '1999-12-01', 'active', ''),
('Grace Mitchell', 'grace.mitchell@email.com', '718-555-0230', '215 W 98th St. New York, NY 10025', '215 W 98th St.', 'New York', 'NY', '10025', 'USA', '1993-04-30', 'inactive', ''),
('Jacob Perez', 'jacob.perez@email.com', '646-555-0238', '1212 5th Ave. New York, NY 10029', '1212 5th Ave.', 'New York', 'NY', '10029', 'USA', '1988-01-12', 'active', ''),
('Rachel Evans', 'rachel.evans@email.com', '917-555-0244', '160 W End Ave. New York, NY 10023', '160 W End Ave.', 'New York', 'NY', '10023', 'USA', '1980-09-03', 'active', ''),
('Tyler Edwards', 'tyler.edwards@email.com', '212-555-0251', '740 Park Ave. New York, NY 10021', '740 Park Ave.', 'New York', 'NY', '10021', 'USA', '1991-05-26', 'pending', ''),
('Megan Collins', 'megan.collins@email.com', '646-555-0256', '270 W 96th St. New York, NY 10025', '270 W 96th St.', 'New York', 'NY', '10025', 'USA', '1977-10-15', 'active', ''),
('Jason Stewart', 'jason.stewart@email.com', '718-555-0262', '88 Greenwich St. New York, NY 10006', '88 Greenwich St.', 'New York', 'NY', '10006', 'USA', '1982-08-28', 'inactive', ''),
('Hannah Morris', 'hannah.morris@email.com', '212-555-0267', '300 E 71st St. New York, NY 10021', '300 E 71st St.', 'New York', 'NY', '10021', 'USA', '1994-06-20', 'active', ''),
('Alexander Rogers', 'alexander.rogers@email.com', '917-555-0271', '121 W 19th St. New York, NY 10011', '121 W 19th St.', 'New York', 'NY', '10011', 'USA', '1990-03-11', 'active', ''),
('Sophie Reed', 'sophie.reed@email.com', '646-555-0278', '2109 Broadway St. New York, NY 10023', '2109 Broadway St.', 'New York', 'NY', '10023', 'USA', '1986-01-03', 'pending', ''),
('Nathan Bell', 'nathan.bell@email.com', '718-555-0285', '150 E 44th St. New York, NY 10017', '150 E 44th St.', 'New York', 'NY', '10017', 'USA', '1985-12-28', 'active', ''),
('Brittany Murphy', 'brittany.murphy@email.com', '212-555-0291', '400 E 84th St. New York, NY 10028', '400 E 84th St.', 'New York', 'NY', '10028', 'USA', '1996-09-10', 'active', ''),
('Kyle Bailey', 'kyle.bailey@email.com', '646-555-0297', '35 Sutton Pl. New York, NY 10022', '35 Sutton Pl.', 'New York', 'NY', '10022', 'USA', '1980-07-24', 'inactive', ''),
('Victoria Rivera', 'victoria.rivera@email.com', '917-555-0304', '100 Riverside Blvd. New York, NY 10069', '100 Riverside Blvd.', 'New York', 'NY', '10069', 'USA', '1989-11-18', 'active', ''),
('Mason Campbell', 'mason.campbell@email.com', '718-555-0310', '215 W 91st St. New York, NY 10024', '215 W 91st St.', 'New York', 'NY', '10024', 'USA', '1993-05-02', 'pending', ''),
('Chloe Morgan', 'chloe.morgan@email.com', '212-555-0316', '411 E 53rd St. New York, NY 10022', '411 E 53rd St.', 'New York', 'NY', '10022', 'USA', '1995-12-12', 'active', ''),
('Ethan Cooper', 'ethan.cooper@email.com', '646-555-0323', '301 E 63rd St. New York, NY 10065', '301 E 63rd St.', 'New York', 'NY', '10065', 'USA', '1981-06-07', 'inactive', ''),
('Sofia Cox', 'sofia.cox@email.com', '718-555-0330', '555 W 57th St. New York, NY 10019', '555 W 57th St.', 'New York', 'NY', '10019', 'USA', '1987-02-22', 'active', ''),
('Henry Ward', 'henry.ward@email.com', '917-555-0335', '122 E 42nd St. New York, NY 10168', '122 E 42nd St.', 'New York', 'NY', '10168', 'USA', '1999-08-15', 'pending', ''),
('Ella Ramirez', 'ella.ramirez@email.com', '646-555-0342', '160 E 38th St. New York, NY 10016', '160 E 38th St.', 'New York', 'NY', '10016', 'USA', '1991-11-30', 'active', ''),
('Jack Brooks', 'jack.brooks@email.com', '212-555-0348', '50 W 34th St. New York, NY 10001', '50 W 34th St.', 'New York', 'NY', '10001', 'USA', '1988-03-18', 'active', ''),
('Avery Wood', 'avery.wood@email.com', '718-555-0355', '300 Mercer St. New York, NY 10003', '300 Mercer St.', 'New York', 'NY', '10003', 'USA', '1983-10-05', 'inactive', ''),
('Lily Bennett', 'lily.bennett@email.com', '646-555-0361', '241 E 86th St. New York, NY 10028', '241 E 86th St.', 'New York', 'NY', '10028', 'USA', '1998-05-09', 'active', ''),
('Caleb Griffin', 'caleb.griffin@email.com', '917-555-0367', '120 E 87th St. New York, NY 10128', '120 E 87th St.', 'New York', 'NY', '10128', 'USA', '1977-08-21', 'active', ''),
('Madison Torres', 'madison.torres@email.com', '212-555-0373', '45 Wall St. New York, NY 10005', '45 Wall St.', 'New York', 'NY', '10005', 'USA', '1992-12-29', 'pending', ''),
('Owen Reed', 'owen.reed@email.com', '646-555-0378', '55 W 26th St. New York, NY 10010', '55 W 26th St.', 'New York', 'NY', '10010', 'USA', '1985-09-17', 'active', ''),
('Isabella Long', 'isabella.long@email.com', '917-555-0385', '165 W End Ave. New York, NY 10023', '165 W End Ave.', 'New York', 'NY', '10023', 'USA', '1986-12-07', 'inactive', ''),
('Elijah Foster', 'elijah.foster@email.com', '212-555-0391', '145 W 79th St. New York, NY 10024', '145 W 79th St.', 'New York', 'NY', '10024', 'USA', '1997-07-01', 'active', ''),
('Aubrey Price', 'aubrey.price@email.com', '646-555-0397', '515 E 72nd St. New York, NY 10021', '515 E 72nd St.', 'New York', 'NY', '10021', 'USA', '1990-10-25', 'active', ''),
('Mila Howard', 'mila.howard@email.com', '718-555-0404', '201 E 87th St. New York, NY 10128', '201 E 87th St.', 'New York', 'NY', '10128', 'USA', '1982-04-14', 'pending', ''),
('Luke Perry', 'luke.perry@email.com', '212-555-0410', '222 E 39th St. New York, NY 10016', '222 E 39th St.', 'New York', 'NY', '10016', 'USA', '1979-01-25', 'active', ''),
('Layla Russell', 'layla.russell@email.com', '646-555-0415', '111 W 67th St. New York, NY 10023', '111 W 67th St.', 'New York', 'NY', '10023', 'USA', '1993-11-16', 'inactive', ''),
('Logan Jenkins', 'logan.jenkins@email.com', '917-555-0420', '30 Lincoln Plaza. New York, NY 10023', '30 Lincoln Plaza.', 'New York', 'NY', '10023', 'USA', '1984-06-29', 'active', ''),
('Penelope Simmons', 'penelope.simmons@email.com', '718-555-0428', '250 W 50th St. New York, NY 10019', '250 W 50th St.', 'New York', 'NY', '10019', 'USA', '1998-01-04', 'active', '');





CREATE OR REPLACE PNP.ETREMBLAY.MODELSACE STAGE models
    DIRECTORY = (ENABLE = TRUE);



    
- Donner accès à l'API HERE et spécifier sa  KEY

CREATE OR REPLACE NETWORK RULE here_api_rules  
MODE = EGRESS  
TYPE = HOST_PORT  
VALUE_LIST = ('router.hereapi.com','geocode.search.hereapi.com');

CREATE OR REPLACE SECRET here_api_key  
TYPE = GENERIC_STRING  
SECRET_STRING = 'REMOVED'; 

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION here_api_access_int  
ALLOWED_NETWORK_RULES = (here_api_rules)  
ALLOWED_AUTHENTICATION_SECRETS = (here_api_key)  
ENABLED = TRUE;

GRANT READ ON SECRET here_api_key TO ROLE PNP;

GRANT USAGE ON INTEGRATION here_api_access_int TO ROLE PNP;

--Get Streamlit ID 
SHOW STREAMLITS IN SCHEMA PNP.ETREMBLAY;

ALTER STREAMLIT PNP.ETREMBLAY.V23DZEU56TC6GE2H --Streamlit ID  
SET EXTERNAL_ACCESS_INTEGRATIONS = (here_api_access_int)  
SECRETS = ('here_api_key' = pnp.etremblay.here_api_key);

- Donner accès à l'API PRECISELY et spécifier sa  KEY

CREATE OR REPLACE NETWORK RULE precisely_api_rules  
MODE = EGRESS  
TYPE = HOST_PORT  
VALUE_LIST = ('api.precisely.com', 'api.cloud.precisely.com');

CREATE OR REPLACE SECRET precisely_api_key  
TYPE = GENERIC_STRING  
SECRET_STRING = 'REMOVED'; 

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION precisely_api_access_int  
ALLOWED_NETWORK_RULES = (precisely_api_rules)  
ALLOWED_AUTHENTICATION_SECRETS = (precisely_api_key)  
ENABLED = TRUE;

GRANT READ ON SECRET precisely_api_key TO ROLE PNP;
GRANT READ ON SECRET here_api_key TO ROLE PNP;

GRANT USAGE ON INTEGRATION here_api_access_int TO ROLE PNP;
GRANT USAGE ON INTEGRATION precisely_api_access_int TO ROLE PNP;

--Get Streamlit ID 
SHOW STREAMLITS IN SCHEMA PNP.ETREMBLAY;

ALTER STREAMLIT PNP.ETREMBLAY.FX2YIC80IVFSOBR7 --Streamlit ID  
SET EXTERNAL_ACCESS_INTEGRATIONS = (precisely_api_access_int,here_api_access_int)  
SECRETS = ('precisely_api_key' = pnp.etremblay.precisely_api_key,
'here_api_key' = pnp.etremblay.here_api_key);







Install precisely-mcp-servers
https://github.com/PreciselyData/precisely-mcp-servers
With all that in place, your local MCP server will auto‑detect 
the “matter” of any question you throw at it—no more regex hacks 
in your Streamlit app. You can now focus on wiring your UI up to call:

/geocode
/route
/property
/demographics

etc.

and let the MCP server handle the rest.

Function Reference Guide
Geo Addressing API
autocomplete - Suggest addresses as you type

"Complete this address: 123 Main"
"What addresses start with Empire State?"
"Autocomplete: 1600 Penn"
autocomplete_postal_city - Find cities by postal code

"What cities are in ZIP 90210?"
"Cities for postal code 10001"
"Find cities in 02101 area"
autocomplete_v2 - Enhanced address suggestions with details

"Smart complete: Apple Park Way"
"Enhanced suggestions for Times Square"
"V2 autocomplete for Golden Gate"
geocode - Convert addresses to coordinates

"What are coordinates for White House?"
"Get lat/lon for 123 Main St"
"Geocode this address: Central Park"
lookup - Find address details by ID

"Lookup address ID: ABC123"
"Get details for precisely ID 456"
"Address info for reference XYZ"
reverse_geocode - Convert coordinates to addresses

"What address is at 40.7589, -73.9851?"
"Address for GPS location 34.0522, -118.2437"
"Reverse geocode: 41.8781, -87.6298"
verify_address - Validate and standardize addresses

"Verify: 123 Main Street Boston MA"
"Is this address valid: 456 Oak Ave?"
"Standardize this address format"
Address Parser API
parse_address - Break address into components

"Parse: John Doe 123 Main St Boston"
"Split this address into parts"
"Extract components from full address"
parse_address_batch - Parse multiple addresses together

"Parse my address list into components"
"Batch parse 100 customer addresses"
"Split multiple addresses into fields"
Email Verification API
verify_email - Check if email is valid

"Verify email: user@example.com"
"Is this email real: test@domain.com?"
"Check email deliverability"
verify_batch_emails - Validate multiple emails together

"Verify my email list"
"Check 500 customer emails"
"Bulk validate email addresses"
Emergency Info API
psap_address - Find 911 center by address

"911 center for 123 Main St?"
"Emergency dispatch for this address"
"PSAP serving my location"
psap_location - Find 911 center by coordinates

"911 center at 40.7589, -73.9851"
"Emergency services for GPS location"
"PSAP for coordinates 34.05, -118.24"
psap_ahj_address - Find authority by address

"Emergency authority for this address"
"AHJ serving 456 Oak Street"
"Jurisdiction for my location"
psap_ahj_location - Find authority by coordinates

"Emergency authority at coordinates"
"AHJ for GPS 41.88, -87.63"
"Jurisdiction for this location"
psap_ahj_fccid - Find authority by FCC ID

"AHJ for FCC ID: ABC123"
"Emergency authority for FCC XYZ"
"Jurisdiction by FCC identifier"
Geolocation API
geo_locate_ip_address - Find location of IP

"Where is IP 192.168.1.1?"
"Geolocate this IP address"
"Location for IP 8.8.8.8"
geo_locate_wifi_access_point - Find WiFi location

"Locate WiFi: MAC AA:BB:CC"
"Where is this access point?"
"WiFi geolocation by MAC address"
Geo Tax API
lookup_by_address - Find tax rates by address

"Tax rates for 123 Main St"
"Sales tax at this address"
"Tax jurisdiction for my business"
lookup_by_addresses - Get tax rates for multiple addresses

"Tax rates for my store locations"
"Bulk tax lookup for addresses"
"Sales tax for address list"
lookup_by_location - Find tax rates by coordinates

"Tax rates at 40.7589, -73.9851"
"Sales tax for GPS location"
"Tax jurisdiction for coordinates"
lookup_by_locations - Get tax rates for multiple coordinates

"Tax rates for coordinate list"
"Bulk tax lookup by GPS points"
"Sales tax for multiple locations"
Name Parsing API
parse_name - Split names into components

"Parse: Dr. John Michael Smith Jr."
"Split name into first/middle/last"
"Extract title and suffix from name"
Phone Verification API
validate_phone - Check if phone number valid

"Verify phone: (555) 123-4567"
"Is this phone number real?"
"Validate mobile number format"
validate_batch_phones - Validate multiple phones together

"Verify my phone number list"
"Check 200 customer phone numbers"
"Bulk validate phone database"
Timezone API
timezone_addresses - Find timezone by address

"Timezone for 123 Main St Seattle"
"What timezone is this address in?"
"Time zone for business location"
timezone_locations - Find timezone by coordinates

"Timezone at 40.7589, -73.9851"
"Time zone for GPS location"
"Timezone for coordinates 34.05, -118.24"
GraphQL API - Core Property Data
get_addresses_detailed - Complete address information with IDs

"Detailed info for 123 Main St"
"Full address data including IDs"
"Complete address profile and metadata"
get_buildings_by_address - Building data including type and area

"Building info for Empire State Building"
"Structure details at this address"
"Building type and square footage"
get_parcels_by_address - Land parcel information and boundaries

"Parcel data for 123 Oak Street"
"Land boundaries for this property"
"Lot information and parcel ID"
get_places_nearby - Local businesses and points of interest

"Restaurants near 123 Main St"
"Businesses within 1 mile radius"
"Coffee shops close to this address"
get_property_attributes_by_address - Detailed property characteristics

"Property details for 456 Oak Ave"
"Bedrooms, bathrooms, year built info"
"Square footage and property value"
get_replacement_cost_by_address - Insurance replacement cost estimates

"Replacement cost for my house"
"Insurance rebuild estimate"
"Property replacement value calculation"
GraphQL API - Risk Assessment
get_coastal_risk - Hurricane and storm surge vulnerability

"Hurricane risk for Miami Beach address"
"Coastal storm threat assessment"
"Storm surge risk for beachfront property"
get_property_fire_risk - Fire station distances and response

"Fire risk for 123 Forest Lane"
"Fire station response time"
"Nearest fire department distance"
get_earth_risk - Earthquake fault proximity and risk

"Earthquake risk for San Francisco address"
"Fault line distance and seismic risk"
"Earthquake hazard assessment"
get_wildfire_risk_by_address - Wildfire probability and severity ratings

"Wildfire risk for Malibu property"
"Fire danger assessment"
"Wildfire threat level analysis"
get_flood_risk_by_address - FEMA flood zones and elevation

"Flood risk for New Orleans address"
"FEMA flood zone designation"
"Flood insurance requirements"
get_historical_weather_risk - Tornado, hail, severe weather history

"Weather risk for Kansas address"
"Tornado and hail history"
"Severe weather threat assessment"
GraphQL API - Demographics & Lifestyle
get_crime_index_by_address - Crime statistics and safety indices

"Crime rates for 123 Downtown Ave"
"Safety index compared to national average"
"Violent vs property crime statistics"
get_psyte_geodemographics_by_address - Lifestyle and consumer segments

"Demographics for this neighborhood"
"Consumer lifestyle segments nearby"
"Household income and lifestyle data"
get_ground_view_by_address - Detailed demographic and economic data

"Population demographics for this area"
"Income, education, employment statistics"
"Age distribution and household composition"
GraphQL API - Neighborhood & Area
get_neighborhoods_by_address - Walkability, home prices, area statistics

"Neighborhood stats for 123 Elm St"
"Walkability and transit scores"
"Average home values and trends"
get_schools_by_address - School districts, attendance zones, colleges

"Schools serving 456 Oak Avenue"
"School district and ratings"
"Colleges and universities nearby"
get_serviceability - Delivery and service accessibility

"Is this address serviceable?"
"Delivery accessibility information"
"Service availability for location"
GraphQL API - Spatial Queries
get_spatial_addresses - Addresses within geographic boundaries

"Addresses in downtown Boston polygon"
"All addresses within coordinate boundary"
"Properties in this geographic area"
get_spatial_buildings - Buildings in specified areas

"Buildings within Central Park boundary"
"Structures in this geographic region"
"Buildings intersecting polygon area"
get_spatial_parcels - Land parcels within boundaries

"Parcels in this neighborhood boundary"
"Land lots within coordinate area"
"Property parcels in polygon region"
get_spatial_places - Businesses and POIs in regions

"Restaurants in downtown boundary"
"Businesses within geographic area"
"POIs in this coordinate region"
GraphQL API - Relationships
get_parcel_by_owner_detailed - Properties by owner name/ID

"Properties owned by John Smith"
"All parcels for owner ID 12345"
"Real estate holdings by owner"
get_address_family - Related addresses and units

"Related addresses for apartment building"
"Address family for 123 Main St"
"Connected units and addresses"
API Response Format
All API functions return structured JSON responses with:

metadata: Pagination and data vintage information
data: The actual response data array
errors: Any validation or processing errors
Example response structure:

{
  "data": {
    "getByAddress": {
      "addresses": {
        "metadata": {
          "pageNumber": 1,
          "totalPages": 1,
          "count": 1,
          "vintage": "2024-Q1"
        },
        "data": [
          {
            "preciselyID": "12345",
            "addressNumber": "123",
            "streetName": "Main St",
            "city": "Boston",
            "admin1ShortName": "MA",
            "postalCode": "02101",
            "latitude": 42.3601,
            "longitude": -71.0589
          }
        ]
      }
    }
  }
}










##################################################
##################################################
##################################################
CLEANED UP VERSION BY AI
##################################################
##################################################
##################################################
-- =====================================================
-- Cleaned & Annotated setup.sql for Intelligent Sales Assistant
-- Truth-aligned with implementation; idempotent; clearer structure
-- Key improvements:
--   * Removed duplicate definitions (e.g., duplicate sales_metrics)
--   * Fixed malformed CREATE TABLE for emails
--   * Made intent explicit, added primary keys, improved naming
--   * Removed stray documentation / prose from end of file
--   * External integrations: left placeholders, avoid hardcoding secrets
-- =====================================================

-- ---------------------------
-- 0. Context / environment setup
-- ---------------------------
-- NOTE: adjust warehouse/database/schema names to your actual environment.
-- Prefer to set context outside this script if orchestrated; this makes it explicit here.
USE WAREHOUSE COMPUTE_WH;  -- replace with your actual warehouse if different
-- Database / schema in original was PNP.ETREMBLAY; keep consistent with usage below
USE DATABASE PNP;
USE SCHEMA ETREMBLAY;

-- ---------------------------
-- 1. Core table definitions
-- ---------------------------

-- sales_conversations: unstructured transcript data
CREATE OR REPLACE TABLE sales_conversations (
    conversation_id VARCHAR PRIMARY KEY,  -- unique id per conversation
    transcript_text TEXT,                -- the raw transcript content
    customer_name VARCHAR,
    deal_stage VARCHAR,
    sales_rep VARCHAR,
    conversation_date TIMESTAMP,
    deal_value FLOAT,
    product_line VARCHAR,
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP
);

-- sales_metrics: structured deal-level metrics
CREATE OR REPLACE TABLE sales_metrics (
    deal_id VARCHAR PRIMARY KEY,
    customer_name VARCHAR,
    deal_value FLOAT,
    close_date DATE,
    sales_stage VARCHAR,
    win_status BOOLEAN,
    sales_rep VARCHAR,
    product_line VARCHAR,
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP
);

-- NOTE: The original had no dedicated customers table in this cleaned file; if needed,
-- ensure it exists separately. (Implementation uses CUSTOMERS_WEBINAR_202508 elsewhere.)

-- emails_webinar_202508: incoming emails to be parsed
CREATE OR REPLACE TABLE emails_webinar_202508 (
    id             NUMBER AUTOINCREMENT                                  COMMENT 'Surrogate primary key for each email record',
    message_id     VARCHAR(255)                                          COMMENT 'Unique message identifier assigned by the mail provider',
    thread_id      VARCHAR(255)                                          COMMENT 'Identifier grouping related messages into a conversation thread',
    from_address   VARCHAR(320)                                          COMMENT 'Email address of the sender (max 320 chars per RFC)',
    to_addresses   VARCHAR(1000)                                         COMMENT 'Comma-separated list of primary recipient email addresses',
    cc_addresses   VARCHAR(1000)                                         COMMENT 'Comma-separated list of CC recipient email addresses',
    bcc_addresses  VARCHAR(1000)                                         COMMENT 'Comma-separated list of BCC recipient email addresses',
    subject        VARCHAR(1000)                                         COMMENT 'Subject line of the email message',
    body           STRING                                                COMMENT 'Full message body (plain-text or HTML)',
    sent_at        TIMESTAMP_NTZ                                         COMMENT 'When the email was sent (no time zone stored)',
    received_at    TIMESTAMP_NTZ                                         COMMENT 'When the email was received or ingested',
    is_read        BOOLEAN DEFAULT FALSE                                COMMENT 'Flag indicating whether the user has read this email',
    parsed_fields  VARIANT                                               COMMENT 'Structured extraction output (from Cortex COMPLETE)',
    created_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()             COMMENT 'Record insertion timestamp'
);

-- ---------------------------
-- 2. Change tracking (if desired)
-- ---------------------------
-- Enable change tracking if your use case needs delta detection (original had it for some tables)
-- Note: ensure your Snowflake edition / permissions support CHANGE_TRACKING
ALTER TABLE sales_conversations SET CHANGE_TRACKING = TRUE;
ALTER TABLE emails_webinar_202508 SET CHANGE_TRACKING = TRUE;

-- ---------------------------
-- 3. Cortex Search service creation
-- ---------------------------
-- Clean, explicit creation of the semantic search index over transcripts.
-- Adjust configuration as needed; this assumes current syntax supports specifying target columns.
CREATE OR REPLACE SEARCH SERVICE sales_conversation_search
  ON TABLE sales_conversations(transcript_text)
  WITH (
    TYPE = 'CORTEX_SEARCH',
    COMMENT = 'Semantic search index over sales call transcripts'
    -- Further embedding / vector config can be added here if required by your setup
  );

-- ---------------------------
-- 4. Sample / seed data insertion
-- (These are optional; could be split to a separate seed script)
-- ---------------------------

-- Insert example conversations
INSERT INTO sales_conversations
  (conversation_id, transcript_text, customer_name, deal_stage, sales_rep, conversation_date, deal_value, product_line)
VALUES
  ('CONV001', 'Initial discovery call with TechCorp Inc''s IT Director and Solutions Architect. Client showed strong interest in our enterprise solution features, particularly the automated workflow capabilities. The main discussion centered around integration timeline and complexity. They currently use Legacy System X for their core operations and expressed concerns about potential disruption during migration. The team asked detailed questions about API compatibility and data migration tools.

Action items include providing a detailed integration timeline document, scheduling a technical deep-dive with their infrastructure team, and sharing case studies of similar Legacy System X migrations. The client mentioned a Q2 budget allocation for digital transformation initiatives. Overall, it was a positive engagement with clear next steps.', 'TechCorp Inc', 'Discovery', 'Sarah Johnson', '2024-01-15 10:30:00', 75000, 'Enterprise Suite'),
  ('CONV002', 'Follow-up call with SmallBiz Solutions'' Operations Manager and Finance Director. The primary focus was on pricing structure and ROI timeline. They compared our Basic Package pricing with Competitor Y''s small business offering. Key discussion points included monthly vs. annual billing options, user license limitations, and potential cost savings from process automation.

The client requested a detailed ROI analysis focusing on time saved in daily operations, resource allocation improvements, and projected efficiency gains. Budget constraints were clearly communicated, with a maximum budget of $30K for this year. They showed interest in starting with the basic package with room for a potential upgrade in Q4. Next steps include providing a competitive analysis and a customized ROI calculator by next week.', 'SmallBiz Solutions', 'Negotiation', 'Mike Chen', '2024-01-16 14:45:00', 25000, 'Basic Package'),
  ('CONV003', 'Strategy session with SecureBank Ltd''s CISO and Security Operations team. Extremely positive 90-minute deep dive into our Premium Security package. Customer emphasized immediate need for implementation due to recent industry compliance updates. Our advanced security features, especially multi-factor authentication and encryption protocols, were identified as perfect fits for their requirements. Technical team was particularly impressed with our zero-trust architecture approach and real-time threat monitoring capabilities. They''ve already secured budget approval and have executive buy-in. Compliance documentation is ready for review. Action items include: finalizing implementation timeline, scheduling security audit, and preparing necessary documentation for their risk assessment team. Client ready to move forward with contract discussions.', 'SecureBank Ltd', 'Closing', 'Rachel Torres', '2024-01-17 11:20:00', 150000, 'Premium Security'),
  ('CONV004', 'Comprehensive discovery call with GrowthStart Up''s CTO and Department Heads. Team of 500+ employees across 3 continents discussed current challenges with their existing solution. Major pain points identified: system crashes during peak usage, limited cross-department reporting capabilities, and poor scalability for remote teams. Deep dive into their current workflow revealed bottlenecks in data sharing and collaboration. Technical requirements gathered for each department. Platform demo focused on scalability features and global team management capabilities. Client particularly interested in our API ecosystem and custom reporting engine. Next steps: schedule department-specific workflow analysis and prepare detailed platform migration plan.', 'GrowthStart Up', 'Discovery', 'Sarah Johnson', '2024-01-18 09:15:00', 100000, 'Enterprise Suite'),
  ('CONV005', 'In-depth demo session with DataDriven Co''s Analytics team and Business Intelligence managers. Showcase focused on advanced analytics capabilities, custom dashboard creation, and real-time data processing features. Team was particularly impressed with our machine learning integration and predictive analytics models. Competitor comparison requested specifically against Market Leader Z and Innovative Start-up X. Price point falls within their allocated budget range, but team expressed interest in multi-year commitment with corresponding discount structure. Technical questions centered around data warehouse integration and custom visualization capabilities. Action items: prepare detailed competitor feature comparison matrix and draft multi-year pricing proposals with various discount scenarios.', 'DataDriven Co', 'Demo', 'James Wilson', '2024-01-19 13:30:00', 85000, 'Analytics Pro'),
  ('CONV006', 'Extended technical deep dive with HealthTech Solutions'' IT Security team, Compliance Officer, and System Architects. Four-hour session focused on API infrastructure, data security protocols, and compliance requirements. Team raised specific concerns about HIPAA compliance, data encryption standards, and API rate limiting. Detailed discussion of our security architecture, including: end-to-end encryption, audit logging, and disaster recovery protocols. Client requires extensive documentation on compliance certifications, particularly SOC 2 and HITRUST. Security team performed initial architecture review and requested additional information about: database segregation, backup procedures, and incident response protocols. Follow-up session scheduled with their compliance team next week.', 'HealthTech Solutions', 'Technical Review', 'Rachel Torres', '2024-01-20 15:45:00', 120000, 'Premium Security'),
  ('CONV007', 'Contract review meeting with LegalEase Corp''s General Counsel, Procurement Director, and IT Manager. Detailed analysis of SLA terms, focusing on uptime guarantees and support response times. Legal team requested specific modifications to liability clauses and data handling agreements. Procurement raised questions about payment terms and service credit structure. Key discussion points included: disaster recovery commitments, data retention policies, and exit clause specifications. IT Manager confirmed technical requirements are met pending final security assessment. Agreement reached on most terms, with only SLA modifications remaining for discussion. Legal team to provide revised contract language by end of week. Overall positive session with clear path to closing.', 'LegalEase Corp', 'Negotiation', 'Mike Chen', '2024-01-21 10:00:00', 95000, 'Enterprise Suite'),
  ('CONV008', 'Quarterly business review with GlobalTrade Inc''s current implementation team and potential expansion stakeholders. Current implementation in Finance department showcasing strong adoption rates and 40% improvement in processing times. Discussion focused on expanding solution to Operations and HR departments. Users highlighted positive experiences with customer support and platform stability. Challenges identified in current usage: need for additional custom reports and increased automation in workflow processes. Expansion requirements gathered from Operations Director: inventory management integration, supplier portal access, and enhanced tracking capabilities. HR team interested in recruitment and onboarding workflow automation. Next steps: prepare department-specific implementation plans and ROI analysis for expansion.', 'GlobalTrade Inc', 'Expansion', 'James Wilson', '2024-01-22 14:20:00', 45000, 'Basic Package'),
  ('CONV009', 'Emergency planning session with FastTrack Ltd''s Executive team and Project Managers. Critical need for rapid implementation due to current system failure. Team willing to pay premium for expedited deployment and dedicated support team. Detailed discussion of accelerated implementation timeline and resource requirements. Key requirements: minimal disruption to operations, phased data migration, and emergency support protocols. Technical team confident in meeting aggressive timeline with additional resources. Executive sponsor emphasized importance of going live within 30 days. Immediate next steps: finalize expedited implementation plan, assign dedicated support team, and begin emergency onboarding procedures. Team to reconvene daily for progress updates.', 'FastTrack Ltd', 'Closing', 'Sarah Johnson', '2024-01-23 16:30:00', 180000, 'Premium Security'),
  ('CONV010', 'Quarterly strategic review with UpgradeNow Corp''s Department Heads and Analytics team. Current implementation meeting basic needs but team requiring more sophisticated analytics capabilities. Deep dive into current usage patterns revealed opportunities for workflow optimization and advanced reporting needs. Users expressed strong satisfaction with platform stability and basic features, but requiring enhanced data visualization and predictive analytics capabilities. Analytics team presented specific requirements: custom dashboard creation, advanced data modeling tools, and integrated BI features. Discussion about upgrade path from current package to Analytics Pro tier. ROI analysis presented showing potential 60% improvement in reporting efficiency. Team to present upgrade proposal to executive committee next month.', 'UpgradeNow Corp', 'Expansion', 'Rachel Torres', '2024-01-24 11:45:00', 65000, 'Analytics Pro');

-- Insert corresponding metrics
INSERT INTO sales_metrics
  (deal_id, customer_name, deal_value, close_date, sales_stage, win_status, sales_rep, product_line)
VALUES
  ('DEAL001', 'TechCorp Inc', 75000, '2024-02-15', 'Closed', true, 'Sarah Johnson', 'Enterprise Suite'),
  ('DEAL002', 'SmallBiz Solutions', 25000, '2024-02-01', 'Lost', false, 'Mike Chen', 'Basic Package'),
  ('DEAL003', 'SecureBank Ltd', 150000, '2024-01-30', 'Closed', true, 'Rachel Torres', 'Premium Security'),
  ('DEAL004', 'GrowthStart Up', 100000, '2024-02-10', 'Pending', false, 'Sarah Johnson', 'Enterprise Suite'),
  ('DEAL005', 'DataDriven Co', 85000, '2024-02-05', 'Closed', true, 'James Wilson', 'Analytics Pro'),
  ('DEAL006', 'HealthTech Solutions', 120000, '2024-02-20', 'Pending', false, 'Rachel Torres', 'Premium Security'),
  ('DEAL007', 'LegalEase Corp', 95000, '2024-01-25', 'Closed', true, 'Mike Chen', 'Enterprise Suite'),
  ('DEAL008', 'GlobalTrade Inc', 45000, '2024-02-08', 'Closed', true, 'James Wilson', 'Basic Package'),
  ('DEAL009', 'FastTrack Ltd', 180000, '2024-02-12', 'Closed', true, 'Sarah Johnson', 'Premium Security'),
  ('DEAL010', 'UpgradeNow Corp', 65000, '2024-02-18', 'Pending', false, 'Rachel Torres', 'Analytics Pro');

-- Emails synthetic seeding (retained from original, randomized generator logic)
INSERT INTO emails_webinar_202508 (
  message_id,
  thread_id,
  from_address,
  to_addresses,
  cc_addresses,
  bcc_addresses,
  subject,
  body,
  sent_at,
  received_at,
  is_read,
  created_at
)
SELECT
  UUID_STRING() AS message_id,
  UUID_STRING() AS thread_id,
  ARRAY_CONSTRUCT(
    'alice.smith@gmail.com','bob.jones@yahoo.com','carol.lee@outlook.com',
    'dave.wilson@example.com','eve.moore@gmail.com','frank.taylor@yahoo.com',
    'grace.anderson@outlook.com','heidi.brown@example.com',
    'ivan.johnson@gmail.com','judy.white@yahoo.com'
  )[UNIFORM(0,10,RANDOM())]::VARCHAR AS from_address,
  'sales@snowbins.ca' AS to_addresses,
  '' AS cc_addresses,
  '' AS bcc_addresses,
  'Request for '
    || ARRAY_CONSTRUCT('10 yd³','15 yd³','20 yd³','30 yd³')[UNIFORM(0,4,RANDOM())]::VARCHAR
    || ' '
    || ARRAY_CONSTRUCT(
         'mixed waste','green waste','construction debris','concrete',
         'metal scrap','furniture','yard waste'
       )[UNIFORM(0,7,RANDOM())]::VARCHAR
    || ' container rental' AS subject,
  CASE
    WHEN UNIFORM(0,10,RANDOM()) < 8 THEN
      ARRAY_CONSTRUCT('Hello','Hi','Greetings','Dear team')[UNIFORM(0,4,RANDOM())]::VARCHAR
      || ' SnowBins,' || '\n\n'
      || 'I need to rent a '
      || ARRAY_CONSTRUCT('10 yd³','15 yd³','20 yd³','30 yd³')[UNIFORM(0,4,RANDOM())]::VARCHAR
      || ' container for '
      || ARRAY_CONSTRUCT(
           'mixed waste','green waste','construction debris','concrete',
           'metal scrap','furniture','yard waste'
         )[UNIFORM(0,7,RANDOM())]::VARCHAR
      || ', approx ' || TO_VARCHAR(UNIFORM(1,10,RANDOM()))
      || IFF(UNIFORM(0,2,RANDOM())=0,' tons',' yd³')
      || '. Please deliver on '
      || CASE UNIFORM(0,4,RANDOM())
           WHEN 0 THEN TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'YYYY-MM-DD'
                      )
           WHEN 1 THEN TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'Month DD, YYYY'
                      )
           WHEN 2 THEN TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'DD/MM/YYYY'
                      )
           ELSE      TO_CHAR(
                        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE),
                        'DD Mon YYYY'
                      )
         END
      || ' for ' || TO_VARCHAR(UNIFORM(3,14,RANDOM())) || ' days at '
      || TO_VARCHAR(UNIFORM(100,999,RANDOM())) || ' '
      || ARRAY_CONSTRUCT(
           'Maple St','Oak St','Pine Ave','Elm Dr','Cedar Blvd',
           'Sunset Blvd','Lincoln Ave','Adams St','Madison Ave','Jefferson St'
         )[UNIFORM(0,10,RANDOM())]::VARCHAR
      || ', '
      || ARRAY_CONSTRUCT(
           'Los Angeles, CA','San Diego, CA','Sacramento, CA','San Jose, CA',
           'Fresno, CA','Bakersfield, CA','Oakland, CA','San Francisco, CA',
           'Irvine, CA','Riverside, CA'
         )[UNIFORM(0,10,RANDOM())]::VARCHAR
      || '\n\n'
      || ARRAY_CONSTRUCT('Thanks,','Best regards,','Cheers,','Sincerely,')[UNIFORM(0,4,RANDOM())]::VARCHAR
      || '\n'
      || SPLIT_PART(
           ARRAY_CONSTRUCT(
             'alice.smith@gmail.com','bob.jones@yahoo.com','carol.lee@outlook.com',
             'dave.wilson@example.com','eve.moore@gmail.com','frank.taylor@yahoo.com',
             'grace.anderson@outlook.com','heidi.brown@example.com',
             'ivan.johnson@gmail.com','judy.white@yahoo.com'
           )[UNIFORM(0,10,RANDOM())]::VARCHAR,
           '@',1
         )
    ELSE
      ARRAY_CONSTRUCT('Hello','Hi','Greetings')[UNIFORM(0,3,RANDOM())]::VARCHAR
      || ' SnowBins,' || '\n\n'
      || 'I need '
      || ARRAY_CONSTRUCT('some containers','a few bins')[UNIFORM(0,2,RANDOM())]::VARCHAR
      || ' for '
      || ARRAY_CONSTRUCT('green waste','mixed waste','debris')[UNIFORM(0,3,RANDOM())]::VARCHAR
      || ' '
      || ARRAY_CONSTRUCT('end of August','early September')[UNIFORM(0,2,RANDOM())]::VARCHAR
      || ' at my usual location.'
      || '\n\n'
      || ARRAY_CONSTRUCT('Cheers,','Sincerely,')[UNIFORM(0,2,RANDOM())]::VARCHAR
      || '\n'
      || SPLIT_PART(
           ARRAY_CONSTRUCT(
             'alice.smith@gmail.com','bob.jones@yahoo.com','carol.lee@outlook.com',
             'dave.wilson@example.com','eve.moore@gmail.com','frank.taylor@yahoo.com',
             'grace.anderson@outlook.com','heidi.brown@example.com',
             'ivan.johnson@gmail.com','judy.white@yahoo.com'
           )[UNIFORM(0,10,RANDOM())]::VARCHAR,
           '@',1
         )
  END AS body,
  DATEADD(
    'hour',
    UNIFORM(0,23,RANDOM()),
    DATEADD(
      'day',
      -UNIFORM(1,5,RANDOM()),
      DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE)
    )
  ) AS sent_at,
  DATEADD('minute', UNIFORM(1,60,RANDOM()), /* reference to sent_at alias is not allowed here; recompute similarly */ 
    DATEADD(
      'hour',
      UNIFORM(0,23,RANDOM()),
      DATEADD(
        'day',
        -UNIFORM(1,5,RANDOM()),
        DATEADD('day', UNIFORM(0,30,RANDOM()), '2025-08-01'::DATE)
      )
    )
  ) AS received_at,
  IFF(UNIFORM(0,2,RANDOM())=0, TRUE, FALSE) AS is_read,
  CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- ---------------------------
-- 5. External Access Integrations (HERE API example)
-- ---------------------------

-- Network rule for HERE endpoints (egress control)
CREATE OR REPLACE NETWORK RULE here_api_rules  
  MODE = EGRESS  
  TYPE = HOST_PORT  
  VALUE_LIST = ('router.hereapi.com','geocode.search.hereapi.com');

-- Secret for HERE API key
-- IMPORTANT: In production, create the secret via a secrets management process; avoid hardcoding secret strings in source-controlled SQL.
-- The following is shown for clarity; rotate the secret and consider using Snowflake Secret Manager UI or external vault integration.
-- Replace '<YOUR_ACTUAL_KEY>' securely, or better: create secret outside in console and reference here.
CREATE OR REPLACE SECRET here_api_key  
  TYPE = GENERIC_STRING  
  SECRET_STRING = '<REDACTED_OR_REFERENCED_SECURELY>';

-- External Access Integration for HERE API (secure callout)
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION here_api_access_int  
  ALLOWED_NETWORK_RULES = (here_api_rules)  
  ALLOWED_AUTHENTICATION_SECRETS = (here_api_key)  
  ENABLED = TRUE;

-- Grant appropriate access (adjust roles as needed)
GRANT READ ON SECRET here_api_key TO ROLE PNP;
GRANT USAGE ON INTEGRATION here_api_access_int TO ROLE PNP;

-- Example: associating a Streamlit app with the integration (if you manage a Streamlit object)
-- This assumes the Streamlit object exists; adjust name accordingly.
ALTER STREAMLIT PNP.ETREMBLAY.V23DZEU56TC6GE2H
  SET EXTERNAL_ACCESS_INTEGRATIONS = (here_api_access_int)
  SECRETS = ('here_api_key' = PNP.ETREMBLAY.here_api_key);

-- ---------------------------
-- 6. Notes / cleanup
-- ---------------------------
-- * Removed stray prose, documentation, and external installation instructions from this script.
-- * If Precisely API integration is required similarly, replicate the pattern above:
--     - create network rules for Precisely endpoints
--     - store its key as a secret (do not hardcode)
--     - create an external access integration
--     - grant usage to relevant roles
-- * Consider splitting seed data into a separate "seed" script to isolate side effects.
-- * The search service should be validated to ensure it aligns with your current Snowflake/Cortex version syntax.
-- * If you want demographics enrichment for customers, update or create a similar integration and invoke it from the Customers List flow.

-- End of cleaned setup.sql
