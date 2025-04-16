{{ config(materialized='incremental', unique_key='TASKID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(TASKID) as TASKID,
        trim(SUBJECT) as Subject,
        trim(STATUS) as Status,
        trim(PRIORITY) as Priority,
        DUEDATE as DueDate,
        RELATEDTOID as RelatedEntityID,
        trim(DESCRIPTION) as Description,
        current_timestamp() as LOAD_DATE,
        'TASKS' as RECORD_SOURCE
    from {{ ref('stg_tasks') }}
    where TASKID is not null
        and trim(TASKID) != ''
        and OWNERID in (select USERID from {{ ref('hub_users') }})
        and Status in (select status from {{ ref('task_statuses') }})
        and (DUEDATE is null or DUEDATE >= current_date())
        and TASKID in (select TASKID from {{ ref('hub_tasks') }})
)

select * from source_data