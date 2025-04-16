{{ config(materialized='incremental', unique_key='ACCOUNTID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(ACCOUNTID) as ACCOUNTID,
        trim(ACCOUNTTYPE) as AccountType,
        trim(INDUSTRY) as Industry,
        ANNUALREVENUE,
        trim(PHONE) as PhoneNumber,
        trim(BILLINGADDRESS) as Address,
        current_timestamp() as LOAD_DATE,
        'ACCOUNTS' as RECORD_SOURCE
    from {{ ref('stg_accounts') }}
    where ACCOUNTID is not null
        and trim(ACCOUNTID) != ''
        and trim(ACCOUNTTYPE) in ('Corporate Customer', 'Individual Customer')
        and ANNUALREVENUE > 0
        and PHONE is not null
        and trim(PHONE) != ''
        and ACCOUNTID in (select ACCOUNTID from {{ ref('hub_accounts') }})
)

select * from source_data