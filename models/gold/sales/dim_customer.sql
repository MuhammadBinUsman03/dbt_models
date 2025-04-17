{{ config(
    materialized='table',
    tags=['gold', 'dimension', 'sales']
) }}

/*
    Customer dimension table for the sales domain.
    This is a Type 2 Slowly Changing Dimension (SCD) that tracks historical changes.
*/

WITH customer_hub AS (
    SELECT
        hash_key,
        business_key AS customer_id,
        load_date
    FROM {{ ref('hub_customers') }}
),

customer_sat AS (
    SELECT
        CUSTOMERID,
        CustomerName,
        CustomerType,
        ContactInformation AS email,
        Address,
        LOAD_DATE AS effective_from,
        LEAD(LOAD_DATE) OVER (
            PARTITION BY CUSTOMERID 
            ORDER BY LOAD_DATE
        ) AS effective_to
    FROM {{ ref('sat_customers_details') }}
),

final_customers AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['h.hash_key', 's.effective_from']) }} AS customer_key,
        h.customer_id,
        s.CustomerName AS customer_name,
        s.CustomerType AS customer_type,
        s.email,
        NULL AS phone, -- Assuming phone is not available in the current data
        s.Address AS address,
        s.effective_from,
        COALESCE(s.effective_to, '9999-12-31'::TIMESTAMP) AS effective_to,
        CASE
            WHEN s.effective_to IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current
    FROM customer_hub h
    INNER JOIN customer_sat s
        ON h.customer_id = s.CUSTOMERID
)

SELECT * FROM final_customers
