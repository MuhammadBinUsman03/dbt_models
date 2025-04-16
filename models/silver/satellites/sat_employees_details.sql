{{ config(materialized='incremental', unique_key='EMPLOYEEID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        EMPLOYEEID,
        trim(FIRSTNAME) as FirstName,
        trim(LASTNAME) as LastName,
        trim(EMAIL) as Email,
        trim(PHONE) as PhoneNumber,
        trim(ADDRESS) as Address,
        HIREDATE as HireDate,
        JOBID,
        DEPARTMENTID,
        current_timestamp() as LOAD_DATE,
        'EMPLOYEES' as RECORD_SOURCE
    from {{ ref('stg_employees') }}
    where EMPLOYEEID is not null
        and trim(EMPLOYEEID) != ''
        and trim(FIRSTNAME) != ''
        and trim(LASTNAME) != ''
        and DEPARTMENTID in (select DEPARTMENTID from {{ ref('hub_departments') }})
        and JOBID in (select JOBID from {{ ref('hub_jobpositions') }})
        and EMPLOYEEID in (select EMPLOYEEID from {{ ref('hub_employees') }})
)

select * from source_data