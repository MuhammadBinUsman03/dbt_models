{{ config(materialized='view') }}

WITH source AS (

    SELECT
        CONTACTID,
        ACCOUNTID,
        FIRSTNAME,
        LASTNAME,
        TITLE,
        EMAIL,
        PHONE,
        MAILINGADDRESS,
        OWNERID
    FROM {{ source('TELELINK', 'CONTACTS') }}
),

transformed AS (

    SELECT
        TRIM(CONTACTID) AS CONTACTID,
        TRIM(ACCOUNTID) AS ACCOUNTID,
        TRIM(FIRSTNAME) AS FIRSTNAME,
        TRIM(LASTNAME) AS LASTNAME,
        TRIM(TITLE) AS TITLE,
        TRIM(EMAIL) AS EMAIL,
        TRIM(PHONE) AS PHONE,
        TRIM(MAILINGADDRESS) AS MAILINGADDRESS,
        TRIM(OWNERID) AS OWNERID
    FROM source
),

contact_names AS (

    SELECT
        *,
        CONCAT(TRIM(FIRSTNAME), ' ', TRIM(LASTNAME)) AS CONTACT_NAME
    FROM transformed
),

filtered AS (

    SELECT
        *
    FROM contact_names
    WHERE
        CONTACTID IS NOT NULL
        AND TRIM(CONTACTID) != ''
        AND EMAIL IS NOT NULL
        AND TRIM(EMAIL) != ''
        AND EMAIL LIKE '%@%.%'
)

SELECT * FROM filtered