{{ config(materialized='incremental', unique_key='CATEGORYID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        CATEGORYID,
        trim(CATEGORYNAME) as CategoryName,
        trim(DESCRIPTION) as CategoryDescription,
        PARENTCATEGORYID,
        current_timestamp() as LOAD_DATE,
        'PRODUCT_CATEGORIES' as RECORD_SOURCE
    from {{ ref('stg_product_categories') }}
    where CATEGORYID is not null
        and trim(CATEGORYID) != ''
        and trim(CATEGORYNAME) != ''
        and CATEGORYID in (select CATEGORYID from {{ ref('hub_productcategories') }})
)

select * from source_data