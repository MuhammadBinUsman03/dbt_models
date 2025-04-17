{{ config(
    materialized='table',
    tags=['gold', 'fact', 'inventory']
) }}

/*
    Inventory fact table for the inventory domain.
    This table contains inventory levels with references to relevant dimensions.
*/

WITH inventory AS (
    SELECT
        i.INVENTORYID,
        i.PRODUCTID,
        i.LOCATIONID,
        i.QUANTITYONHAND,
        i.QUANTITYRESERVED,
        CURRENT_DATE() AS snapshot_date
    FROM {{ source('bronze', 'INVENTORY') }} i
),

dim_product_current AS (
    SELECT
        product_key,
        product_id
    FROM {{ ref('dim_product') }}
    WHERE is_current = TRUE
),

dim_stock_location_current AS (
    SELECT
        location_key,
        location_id
    FROM {{ ref('dim_stock_location') }}
    WHERE is_current = TRUE
),

dim_date AS (
    SELECT
        date_key,
        date
    FROM {{ ref('dim_date') }}
),

final_inventory AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['i.INVENTORYID']) }} AS inventory_key,
        i.INVENTORYID AS inventory_id,
        dp.product_key,
        dl.location_key,
        dd.date_key,
        i.QUANTITYONHAND AS quantity_on_hand,
        i.QUANTITYRESERVED AS quantity_reserved,
        (i.QUANTITYONHAND - i.QUANTITYRESERVED) AS quantity_available,
        TRUE AS is_current
    FROM inventory i
    LEFT JOIN dim_product_current dp
        ON i.PRODUCTID = dp.product_id
    LEFT JOIN dim_stock_location_current dl
        ON i.LOCATIONID = dl.location_id
    LEFT JOIN dim_date dd
        ON i.snapshot_date = dd.date
)

SELECT * FROM final_inventory
