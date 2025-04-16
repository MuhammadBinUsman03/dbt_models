{{ config(materialized='incremental', unique_key='USERID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(USERID) as USERID,
        concat_ws(' ', trim(FIRSTNAME), trim(LASTNAME)) as UserName,
        trim(EMAIL) as Email,
        trim(ROLE) as UserRole,
        trim(PROFILE) as Profile,
        current_timestamp() as LOAD_DATE,
        'USERS' as RECORD_SOURCE
    from {{ ref('stg_users') }}
    where USERID is not null
        and trim(USERID) != ''
        and trim(FIRSTNAME) != ''
        and trim(LASTNAME) != ''
        and trim(EMAIL) != ''
        and USERID in (select USERID from {{ ref('hub_users') }})
)

select * from source_data