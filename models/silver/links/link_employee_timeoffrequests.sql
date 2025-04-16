{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(emp.employee_hashkey) AS link_hashkey,
        emp.employee_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'TIME_OFF_REQUESTS' AS record_source
    FROM {{ source('TELELINK', 'TIME_OFF_REQUESTS') }} AS TOR
    INNER JOIN {{ ref('hub_employees') }} AS emp
        ON TOR.EMPLOYEEID = emp.employeeid
    WHERE TOR.REQUESTID IS NOT NULL
        AND TOR.EMPLOYEEID IS NOT NULL
        AND TOR.STARTDATE < TOR.ENDDATE
        AND TOR.TIMEOFFTYPE IS NOT NULL
)

SELECT
    link_hashkey,
    employee_hashkey,
    load_date,
    record_source
FROM source_data