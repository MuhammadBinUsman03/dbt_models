{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(cont.contact_hashkey, acc.account_hashkey)) AS link_hashkey,
        cont.contact_hashkey,
        acc.account_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'CONTACTS' AS record_source
    FROM {{ source('TELELINK', 'CONTACTS') }} AS C
    INNER JOIN {{ ref('hub_contacts') }} AS cont
        ON C.CONTACTID = cont.contactid
    INNER JOIN {{ ref('hub_accounts') }} AS acc
        ON C.ACCOUNTID = acc.accountid
    WHERE C.CONTACTID IS NOT NULL
        AND C.ACCOUNTID IS NOT NULL
)

SELECT
    link_hashkey,
    contact_hashkey,
    account_hashkey,
    load_date,
    record_source
FROM source_data