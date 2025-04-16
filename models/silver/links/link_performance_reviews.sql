{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(emp.employee_hashkey, reviewer.employee_hashkey)) AS link_hashkey,
        emp.employee_hashkey AS employee_hashkey,
        reviewer.employee_hashkey AS reviewer_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'PERFORMANCE_REVIEWS' AS record_source
    FROM {{ source('TELELINK', 'PERFORMANCE_REVIEWS') }} AS PR
    INNER JOIN {{ ref('hub_employees') }} AS emp
        ON PR.EMPLOYEEID = emp.employeeid
    INNER JOIN {{ ref('hub_employees') }} AS reviewer
        ON PR.REVIEWERID = reviewer.employeeid
    WHERE PR.REVIEWID IS NOT NULL
        AND PR.EMPLOYEEID IS NOT NULL
        AND PR.REVIEWERID IS NOT NULL
        AND PR.REVIEWPERIODEND <= CURRENT_DATE()
)

SELECT
    link_hashkey,
    employee_hashkey,
    reviewer_hashkey,
    load_date,
    record_source
FROM source_data