{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['be.ENROLLMENTID']) }} AS link_benefitenrollments_hashkey,
        he.employee_hashkey AS employee_hashkey,
        hb.benefitplan_hashkey AS benefitplan_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'BENEFIT_ENROLLMENTS' AS record_source
    FROM {{ ref('stg_benefit_enrollments') }} be
    INNER JOIN {{ ref('hub_employees') }} he ON be.employeeid = he.employeeid
    INNER JOIN {{ ref('hub_benefitplans') }} hb ON be.benefitplanid = hb.benefitplanid
    WHERE be.enrollmentid IS NOT NULL
)

SELECT * FROM source_data