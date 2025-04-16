{{ config(materialized='incremental', unique_key='JOBID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        JOBID,
        trim(JOBTITLE) as JobTitle,
        trim(JOBLEVEL) as JobLevel,
        trim(JOBFAMILY) as JobFamily,
        trim(DESCRIPTION) as Description,
        current_timestamp() as LOAD_DATE,
        'JOB_POSITIONS' as RECORD_SOURCE
    from {{ ref('stg_job_positions') }}
    where JOBID is not null
        and trim(JOBID) != ''
        and trim(JOBTITLE) != ''
        and JOBID in (select JOBID from {{ ref('hub_jobpositions') }})
)

select * from source_data