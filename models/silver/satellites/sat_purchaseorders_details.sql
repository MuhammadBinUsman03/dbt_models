{{ config(materialized='incremental', unique_key='PURCHASEORDERID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        PURCHASEORDERID,
        ORDERDATE as OrderDate,
        TOTALAMOUNT as TotalAmount,
        trim(STATUS) as Status,
        current_timestamp() as LOAD_DATE,
        'PURCHASE_ORDERS' as RECORD_SOURCE
    from {{ ref('stg_purchase_orders') }}
    where PURCHASEORDERID is not null
        and trim(PURCHASEORDERID) != ''
        and ORDERDATE <= current_date()
        and TOTALAMOUNT > 0
        and PURCHASEORDERID in (select PURCHASEORDERID from {{ ref('hub_purchaseorders') }})
)

select * from source_data