{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(so.link_hashkey, prod.product_hashkey)) AS link_hashkey,
        so.link_hashkey AS salesorder_hashkey,
        prod.product_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'SALES_ORDER_LINES' AS record_source
    FROM {{ source('TELELINK', 'SALES_ORDER_LINES') }} AS SOL
    INNER JOIN {{ ref('link_customer_user') }} AS so
        ON SOL.SALESORDERID = so.salesorderid
    INNER JOIN {{ ref('hub_products') }} AS prod
        ON SOL.PRODUCTID = prod.productid
    WHERE SOL.SALESORDERLINEID IS NOT NULL
        AND SOL.SALESORDERID IS NOT NULL
        AND SOL.PRODUCTID IS NOT NULL
        AND SOL.QUANTITY > 0
)

SELECT
    link_hashkey,
    salesorder_hashkey,
    product_hashkey,
    load_date,
    record_source
FROM source_data