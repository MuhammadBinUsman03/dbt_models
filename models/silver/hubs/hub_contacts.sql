{{ config(
    materialized='incremental',
    unique_key='hash_key',
    tags=['hub']
) }}

with source_data as (

    select
        trim(CONTACTID) as business_key,
        current_timestamp() as load_date,
        'CONTACTS' as record_source

    from {{ ref('stg_contacts') }}

    where CONTACTID IS NOT NULL
      and trim(CONTACTID) != ''
)

select distinct
    {{ hash_key(['business_key']) }} as hash_key,
    business_key,
    load_date,
    record_source

from source_data

{% if is_incremental() %}

    where hash_key not in (select hash_key from {{ this }})

{% endif %}