{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(emp.employee_hashkey, bp.benefitplan_hashkey)) AS link_hashkey,
        emp.employee_hashkey,
        bp.benefitplan_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'BENEFIT_ENROLLMENTS' AS record_source
    FROM {{ source('TELELINK', 'BENEFIT_ENROLLMENTS') }} AS BE
    INNER JOIN {{ ref('hub_employees') }} AS emp
        ON BE.EMPLOYEEID = emp.employeeid
    INNER JOIN {{ ref('hub_benefitplans') }} AS bp
        ON BE.BENEFITPLANID = bp.benefitplanid
    WHERE BE.ENROLLMENTID IS NOT NULL
        AND BE.EMPLOYEEID IS NOT NULL
        AND BE.BENEFITPLANID IS NOT NULL
        AND BE.COVERAGELEVEL IS NOT NULL
        AND BE.COVERAGELEVEL IN ('Individual', 'Family', 'Spouse')
)

SELECT
    link_hashkey,
    employee_hashkey,
    benefitplan_hashkey,
    load_date,
    record_source
FROM source_data