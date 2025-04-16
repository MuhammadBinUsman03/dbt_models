{{ config(materialized='incremental', unique_key='SUPPLIERID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        SUPPLIERID,
        trim(SUPPLIERNAME) as SupplierName,
        trim(EMAIL) as ContactInformation,
        trim(ADDRESS) as Address,
        current_timestamp() as LOAD_DATE,
        'SUPPLIERS' as RECORD_SOURCE
    from {{ ref('stg_suppliers') }}
    where SUPPLIERID is not null
        and trim(SUPPLIERID) != ''
        and trim(SUPPLIERNAME) != ''
        and trim(EMAIL) != ''
        and SUPPLIERID in (select SUPPLIERID from {{ ref('hub_suppliers') }})
)

select * from source_data