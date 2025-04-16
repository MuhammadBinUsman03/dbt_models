{{ config(materialized='incremental', unique_key='BENEFITPLANID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        trim(BENEFITPLANID) as BENEFITPLANID,
        trim(PLANNAME) as PlanName,
        trim(PLANTYPE) as PlanType,
        trim(PROVIDER) as ProviderName,
        current_timestamp() as LOAD_DATE,
        'BENEFIT_PLANS' as RECORD_SOURCE
    from {{ ref('stg_benefit_plans') }}
    where BENEFITPLANID is not null
        and trim(BENEFITPLANID) != ''
        and PLANNAME is not null
        and trim(PLANNAME) != ''
        and PLANTYPE in ('Health', 'Retirement')
        and PROVIDER is not null
        and PROVIDER in (select ProviderName from {{ ref('authorized_providers') }})
        and BENEFITPLANID in (select BENEFITPLANID from {{ ref('hub_benefitplans') }})
)

select * from source_data