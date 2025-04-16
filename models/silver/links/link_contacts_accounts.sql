{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['c.contactid', 'c.accountid']) }} AS link_contactaccounts_hashkey,
        hc.contact_hashkey AS contact_hashkey,
        ha.account_hashkey AS account_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'CONTACTS' AS record_source
    FROM {{ ref('stg_contacts') }} c
    INNER JOIN {{ ref('hub_contacts') }} hc ON c.contactid = hc.contactid
    INNER JOIN {{ ref('hub_accounts') }} ha ON c.accountid = ha.accountid
    WHERE c.contactid IS NOT NULL AND c.accountid IS NOT NULL
)

SELECT * FROM source_data