{{ config(
    materialized='table',
    tags=['gold', 'dimension', 'sales', 'inventory']
) }}

/*
    Product dimension table for the sales and inventory domains.
    This is a Type 2 Slowly Changing Dimension (SCD) that tracks historical changes.
*/

WITH product_hub AS (
    SELECT
        hash_key,
        business_key AS product_id,
        load_date
    FROM {{ ref('hub_products') }}
),

product_sat AS (
    SELECT
        PRODUCTID,
        PRODUCTNAME,
        PRODUCTCODE,
        CATEGORYID,
        SALEPRICE,
        COSTPRICE,
        DESCRIPTION,
        UOM,
        LOAD_DATE AS effective_from,
        LEAD(LOAD_DATE) OVER (
            PARTITION BY PRODUCTID 
            ORDER BY LOAD_DATE
        ) AS effective_to
    FROM {{ ref('sat_products_details') }}
),

category_hub AS (
    SELECT
        hash_key,
        business_key AS category_id,
        load_date
    FROM {{ ref('hub_productcategories') }}
),

category_sat AS (
    SELECT
        CATEGORYID,
        CATEGORYNAME,
        LOAD_DATE AS effective_from
    FROM {{ ref('sat_productcategories_details') }}
),

final_products AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['p.hash_key', 'ps.effective_from']) }} AS product_key,
        p.product_id,
        ps.PRODUCTNAME AS product_name,
        ps.PRODUCTCODE AS product_code,
        ps.CATEGORYID AS category_id,
        cs.CATEGORYNAME AS category_name,
        ps.SALEPRICE AS sale_price,
        ps.COSTPRICE AS cost_price,
        ps.DESCRIPTION AS description,
        ps.UOM AS uom,
        ps.effective_from,
        COALESCE(ps.effective_to, '9999-12-31'::TIMESTAMP) AS effective_to,
        CASE
            WHEN ps.effective_to IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current
    FROM product_hub p
    INNER JOIN product_sat ps
        ON p.product_id = ps.PRODUCTID
    LEFT JOIN category_hub c
        ON ps.CATEGORYID = c.category_id
    LEFT JOIN category_sat cs
        ON c.category_id = cs.CATEGORYID
        AND cs.effective_from <= ps.effective_from
        AND (cs.effective_from = (
            SELECT MAX(effective_from)
            FROM category_sat
            WHERE CATEGORYID = ps.CATEGORYID
            AND effective_from <= ps.effective_from
        ))
)

SELECT * FROM final_products
