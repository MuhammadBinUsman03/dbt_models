{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(prod.product_hashkey, loc.stocklocation_hashkey)) AS link_hashkey,
        prod.product_hashkey,
        loc.stocklocation_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'INVENTORY' AS record_source
    FROM {{ source('TELELINK', 'INVENTORY') }} AS INV
    INNER JOIN {{ ref('hub_products') }} AS prod
        ON INV.PRODUCTID = prod.productid
    INNER JOIN {{ ref('hub_stocklocations') }} AS loc
        ON INV.LOCATIONID = loc.locationid
    WHERE INV.INVENTORYID IS NOT NULL
        AND INV.PRODUCTID IS NOT NULL
        AND INV.LOCATIONID IS NOT NULL
        AND INV.QUANTITYONHAND >= 0
        AND INV.QUANTITYRESERVED >= 0
        AND INV.QUANTITYRESERVED <= INV.QUANTITYONHAND
)

SELECT
    link_hashkey,
    product_hashkey,
    stocklocation_hashkey,
    load_date,
    record_source
FROM source_data