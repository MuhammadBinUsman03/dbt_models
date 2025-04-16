{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['sol.salesorderlineid']) }} AS link_salesorderlines_hashkey,
        lso.link_salesorders_hashkey AS salesorder_hashkey,
        hp.product_hashkey AS product_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'SALES_ORDER_LINES' AS record_source
    FROM {{ ref('stg_sales_order_lines') }} sol
    INNER JOIN {{ ref('link_customers_users') }} lso ON sol.salesorderid = lso.salesorderid
    INNER JOIN {{ ref('hub_products') }} hp ON sol.productid = hp.productid
    WHERE sol.salesorderlineid IS NOT NULL
)

SELECT * FROM source_data