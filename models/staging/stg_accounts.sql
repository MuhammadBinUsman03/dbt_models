{% config(
    materialized='incremental',
    unique_key='ACCOUNTID',
    incremental_strategy='merge'
) %}

with source_data as (

    select
        trim(ACCOUNTID) as ACCOUNTID,
        trim(ACCOUNTNAME) as AccountName,
        trim(ACCOUNTTYPE) as AccountType,
        trim(INDUSTRY) as Industry,
        ANNUALREVENUE as AnnualRevenue,
        trim(PHONE) as PhoneNumber,
        trim(WEBSITE) as Website,
        trim(BILLINGADDRESS) as Address,
        current_timestamp() as LOAD_DATE,
        'ACCOUNTS' as RECORD_SOURCE
    from {{ source('TELELINK_BRONZE', 'ACCOUNTS') }}
    where
        ACCOUNTID is not null
        and trim(ACCOUNTID) != ''
        and trim(ACCOUNTTYPE) in ('Corporate Customer', 'Individual Customer')
        and (ANNUALREVENUE is null or ANNUALREVENUE > 0)
        and PHONE is not null
        and trim(PHONE) != ''
)

select * from source_data