{{ config(materialized='incremental', unique_key='CUSTOMERID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        CUSTOMERID,
        trim(CUSTOMERNAME) as CustomerName,
        trim(CUSTOMERTYPE) as CustomerType,
        trim(EMAIL) as ContactInformation,
        trim(ADDRESS) as Address,
        current_timestamp() as LOAD_DATE,
        'CUSTOMERS' as RECORD_SOURCE
    from {{ ref('stg_customers') }}
    where CUSTOMERID is not null
        and trim(CUSTOMERID) != ''
        and trim(CUSTOMERNAME) != ''
        and CUSTOMERTYPE in ('Individual', 'Corporate')
        and CUSTOMERID in (select CUSTOMERID from {{ ref('hub_customers') }})
)

select * from source_data