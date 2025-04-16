{% config(
    materialized='incremental',
    unique_key='CONTACTID',
    incremental_strategy='merge'
) %}

with source_data as (

    select
        trim(CONTACTID) as CONTACTID,
        trim(FIRSTNAME) as FirstName,
        trim(LASTNAME) as LastName,
        concat(trim(FIRSTNAME), ' ', trim(LASTNAME)) as ContactName,
        trim(EMAIL) as Email,
        trim(PHONE) as PhoneNumber,
        trim(MAILINGADDRESS) as Address,
        trim(TITLE) as Position,
        ACCOUNTID,
        current_timestamp() as LOAD_DATE,
        'CONTACTS' as RECORD_SOURCE
    from {{ source('TELELINK_BRONZE', 'CONTACTS') }}
    where
        CONTACTID is not null
        and trim(CONTACTID) != ''
        and ACCOUNTID is not null
        and trim(ACCOUNTID) != ''
        and EMAIL is not null
        and trim(EMAIL) != ''
        and EMAIL like '%@%.%'
)

select * from source_data