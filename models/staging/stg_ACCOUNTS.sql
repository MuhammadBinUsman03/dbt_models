{{ config(materialized='view') }}

WITH source AS (

    SELECT
        ACCOUNTID,
        ACCOUNTNAME,
        ACCOUNTTYPE,
        INDUSTRY,
        ANNUALREVENUE,
        PHONE,
        WEBSITE,
        BILLINGADDRESS,
        SHIPPINGADDRESS,
        OWNERID
    FROM {{ source('TELELINK', 'ACCOUNTS') }}
),

transformed AS (

    SELECT
        TRIM(ACCOUNTID) AS ACCOUNTID,
        TRIM(ACCOUNTNAME) AS ACCOUNTNAME,
        TRIM(ACCOUNTTYPE) AS ACCOUNTTYPE,
        TRIM(INDUSTRY) AS INDUSTRY,
        ANNUALREVENUE,
        TRIM(PHONE) AS PHONE,
        TRIM(WEBSITE) AS WEBSITE,
        TRIM(BILLINGADDRESS) AS BILLINGADDRESS,
        TRIM(SHIPPINGADDRESS) AS SHIPPINGADDRESS,
        TRIM(OWNERID) AS OWNERID
    FROM source
),

filtered AS (

    SELECT
        *
    FROM transformed
    WHERE
        ACCOUNTID IS NOT NULL
        AND TRIM(ACCOUNTID) != ''
)

SELECT * FROM filtered