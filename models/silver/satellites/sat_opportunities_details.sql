{{ config(materialized='incremental', unique_key='OPPORTUNITYID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(OPPORTUNITYID) as OPPORTUNITYID,
        trim(OPPORTUNITYNAME) as OpportunityName,
        trim(STAGE) as OpportunityStage,
        AMOUNT as EstimatedAmount,
        CLOSEDATE as CloseDate,
        trim(DESCRIPTION) as Description,
        current_timestamp() as LOAD_DATE,
        'OPPORTUNITIES' as RECORD_SOURCE
    from {{ ref('stg_opportunities') }}
    where OPPORTUNITYID is not null
        and trim(OPPORTUNITYID) != ''
        and trim(OpportunityStage) in (select stage from {{ ref('opportunity_stages') }})
        and AMOUNT > 0
        and OPPORTUNITYID in (select OPPORTUNITYID from {{ ref('hub_opportunities') }})
)

select * from source_data