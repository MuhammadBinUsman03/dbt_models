{{ config(materialized='incremental', unique_key='COMPENSATIONID', incremental_strategy='merge', on_schema_change='append_new_columns') }}

with source_data as (

    select
        COMPENSATIONID,
        EMPLOYEEID,
        BASESALARY as BaseSalary,
        trim(CURRENCY) as Currency,
        EFFECTIVEDATE as EffectiveDate,
        BONUSELIGIBLE as BonusEligibility,
        current_timestamp() as LOAD_DATE,
        'COMPENSATIONS' as RECORD_SOURCE
    from {{ ref('stg_compensations') }}
    where COMPENSATIONID is not null
        and COMPENSATIONID in (select COMPENSATIONID from {{ ref('sat_compensations') }})
        and EMPLOYEEID in (select EMPLOYEEID from {{ ref('hub_employees') }})
        and BASESALARY > 0
        and EFFECTIVEDATE <= current_date()
)

select * from source_data