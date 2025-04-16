{{ config(materialized='incremental', unique_key='LOCATIONID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        LOCATIONID,
        trim(LOCATIONNAME) as LocationName,
        trim(LOCATIONTYPE) as LocationType,
        trim(ADDRESS) as Address,
        current_timestamp() as LOAD_DATE,
        'STOCK_LOCATIONS' as RECORD_SOURCE
    from {{ ref('stg_stock_locations') }}
    where LOCATIONID is not null
        and trim(LOCATIONID) != ''
        and trim(LOCATIONNAME) != ''
        and LOCATIONID in (select LOCATIONID from {{ ref('hub_stocklocations') }})
)

select * from source_data