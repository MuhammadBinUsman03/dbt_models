{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['tor.requestid']) }} AS link_timeoffrequests_hashkey,
        he.employee_hashkey AS employee_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'TIME_OFF_REQUESTS' AS record_source
    FROM {{ ref('stg_time_off_requests') }} tor
    INNER JOIN {{ ref('hub_employees') }} he ON tor.employeeid = he.employeeid
    WHERE tor.requestid IS NOT NULL
)

SELECT * FROM source_data