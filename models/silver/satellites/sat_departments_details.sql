{{ config(materialized='incremental', unique_key='DEPARTMENTID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        DEPARTMENTID,
        trim(DEPARTMENTNAME) as DepartmentName,
        trim(LOCATION) as Location,
        MANAGERID as ManagerEmployeeID,
        current_timestamp() as LOAD_DATE,
        'DEPARTMENTS' as RECORD_SOURCE
    from {{ ref('stg_departments') }}
    where DEPARTMENTID is not null
        and trim(DEPARTMENTID) != ''
        and trim(DEPARTMENTNAME) != ''
        and (MANAGERID is null or MANAGERID in (select EMPLOYEEID from {{ ref('hub_employees') }}))
        and DEPARTMENTID in (select DEPARTMENTID from {{ ref('hub_departments') }})
)

select * from source_data