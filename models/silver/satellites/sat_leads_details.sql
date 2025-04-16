{{ config(materialized='incremental', unique_key='LEADID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(LEADID) as LEADID,
        trim(FIRSTNAME) as FirstName,
        trim(LASTNAME) as LastName,
        concat_ws(' ', trim(FIRSTNAME), trim(LASTNAME)) as ContactName,
        trim(COMPANY) as Company,
        trim(EMAIL) as Email,
        trim(PHONE) as PhoneNumber,
        trim(STATUS) as LeadStatus,
        trim(SOURCE) as Source,
        current_timestamp() as LOAD_DATE,
        'LEADS' as RECORD_SOURCE
    from {{ ref('stg_leads') }}
    where LEADID is not null
        and trim(LEADID) != ''
        and OWNERID in (select USERID from {{ ref('hub_users') }})
        and trim(LeadStatus) in (select status from {{ ref('lead_statuses') }})
        and trim(ContactName) != ''
        and trim(EMAIL) != ''
        and LEADID in (select LEADID from {{ ref('hub_leads') }})
)

select * from source_data