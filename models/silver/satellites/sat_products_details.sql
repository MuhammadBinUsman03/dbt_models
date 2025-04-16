{{ config(materialized='incremental', unique_key='PRODUCTID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        PRODUCTID,
        trim(PRODUCTNAME) as ProductName,
        trim(PRODUCTCODE) as ProductCode,
        CATEGORYID,
        SALEPRICE,
        COSTPRICE,
        trim(DESCRIPTION) as Description,
        trim(UOM) as UnitOfMeasure,
        current_timestamp() as LOAD_DATE,
        'PRODUCTS' as RECORD_SOURCE
    from {{ ref('stg_products') }}
    where PRODUCTID is not null
        and trim(PRODUCTID) != ''
        and trim(PRODUCTNAME) != ''
        and SALEPRICE >= COSTPRICE
        and SALEPRICE > 0
        and COSTPRICE > 0
        and PRODUCTID in (select PRODUCTID from {{ ref('hub_products') }})
)

select * from source_data