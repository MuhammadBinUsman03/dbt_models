{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['inv.inventoryid']) }} AS link_inventory_hashkey,
        hp.product_hashkey AS product_hashkey,
        hsl.location_hashkey AS location_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'INVENTORY' AS record_source
    FROM {{ ref('stg_inventory') }} inv
    INNER JOIN {{ ref('hub_products') }} hp ON inv.productid = hp.productid
    INNER JOIN {{ ref('hub_stocklocations') }} hsl ON inv.locationid = hsl.locationid
    WHERE inv.inventoryid IS NOT NULL
)

SELECT * FROM source_data