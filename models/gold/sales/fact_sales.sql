{{ config(
    materialized='table',
    tags=['gold', 'fact', 'sales']
) }}

/*
    Sales fact table for the sales domain.
    This table contains sales order line items with references to relevant dimensions.
*/

WITH sales_orders AS (
    SELECT
        so.SALESORDERID,
        so.ORDERDATE,
        so.CUSTOMERID,
        so.SALESPERSONID,
        so.TOTALAMOUNT,
        so.STATUS
    FROM {{ source('bronze', 'SALES_ORDERS') }} so
),

sales_order_lines AS (
    SELECT
        sol.SALESORDERLINEID,
        sol.SALESORDERID,
        sol.PRODUCTID,
        sol.QUANTITY,
        sol.UNITPRICE,
        sol.SUBTOTAL
    FROM {{ source('bronze', 'SALES_ORDER_LINES') }} sol
),

dim_customer_current AS (
    SELECT
        customer_key,
        customer_id
    FROM {{ ref('dim_customer') }}
    WHERE is_current = TRUE
),

dim_product_current AS (
    SELECT
        product_key,
        product_id
    FROM {{ ref('dim_product') }}
    WHERE is_current = TRUE
),

dim_date AS (
    SELECT
        date_key,
        date
    FROM {{ ref('dim_date') }}
),

dim_user_current AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_key,
        user_id
    FROM (
        SELECT
            business_key AS user_id
        FROM {{ ref('hub_users') }}
    ) u
),

final_sales AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['sol.SALESORDERLINEID']) }} AS sales_key,
        so.SALESORDERID AS sales_order_id,
        sol.SALESORDERLINEID AS sales_order_line_id,
        dc.customer_key,
        dp.product_key,
        dd.date_key,
        du.user_key,
        sol.QUANTITY AS quantity,
        sol.UNITPRICE AS unit_price,
        sol.SUBTOTAL AS subtotal,
        so.TOTALAMOUNT AS total_amount,
        so.STATUS AS status
    FROM sales_orders so
    INNER JOIN sales_order_lines sol
        ON so.SALESORDERID = sol.SALESORDERID
    LEFT JOIN dim_customer_current dc
        ON so.CUSTOMERID = dc.customer_id
    LEFT JOIN dim_product_current dp
        ON sol.PRODUCTID = dp.product_id
    LEFT JOIN dim_date dd
        ON TO_DATE(so.ORDERDATE) = dd.date
    LEFT JOIN dim_user_current du
        ON so.SALESPERSONID = du.user_id
)

SELECT * FROM final_sales
