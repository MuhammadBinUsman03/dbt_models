{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['so.salesorderid']) }} AS link_salesorders_hashkey,
        hc.customer_hashkey AS customer_hashkey,
        hu.user_hashkey AS user_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'SALES_ORDERS' AS record_source
    FROM {{ ref('stg_sales_orders') }} so
    INNER JOIN {{ ref('hub_customers') }} hc ON so.customerid = hc.customerid
    INNER JOIN {{ ref('hub_users') }} hu ON so.salespersonid = hu.userid
    WHERE so.salesorderid IS NOT NULL
)

SELECT * FROM source_data