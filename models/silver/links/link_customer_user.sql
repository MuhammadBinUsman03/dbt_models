{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(cust.customer_hashkey, user.user_hashkey)) AS link_hashkey,
        cust.customer_hashkey,
        user.user_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'SALES_ORDERS' AS record_source
    FROM {{ source('TELELINK', 'SALES_ORDERS') }} AS SO
    INNER JOIN {{ ref('hub_customers') }} AS cust
        ON SO.CUSTOMERID = cust.customerid
    INNER JOIN {{ ref('hub_users') }} AS user
        ON SO.SALESPERSONID = user.userid
    WHERE SO.SALESORDERID IS NOT NULL
        AND SO.CUSTOMERID IS NOT NULL
        AND SO.SALESPERSONID IS NOT NULL
        AND SO.TOTALAMOUNT > 0
)

SELECT
    link_hashkey,
    customer_hashkey,
    user_hashkey,
    load_date,
    record_source
FROM source_data