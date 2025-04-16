{{ config(materialized='incremental', unique_key='CONTACTID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(CONTACTID) as CONTACTID,
        trim(FIRSTNAME) as FirstName,
        trim(LASTNAME) as LastName,
        concat_ws(' ', trim(FIRSTNAME), trim(LASTNAME)) as ContactName,
        trim(EMAIL) as Email,
        trim(PHONE) as PhoneNumber,
        trim(MAILINGADDRESS) as Address,
        trim(TITLE) as Position,
        current_timestamp() as LOAD_DATE,
        'CONTACTS' as RECORD_SOURCE
    from {{ ref('stg_contacts') }}
    where CONTACTID is not null
        and trim(CONTACTID) != ''
        and ACCOUNTID is not null
        and ACCOUNTID in (select ACCOUNTID from {{ ref('hub_accounts') }})
        and EMAIL is not null
        and trim(EMAIL) != ''
        and regexp_like(EMAIL, '^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$')
        and CONTACTID in (select CONTACTID from {{ ref('hub_contacts') }})
)

select * from source_data