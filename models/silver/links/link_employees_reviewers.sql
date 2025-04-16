{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['pr.reviewid']) }} AS link_performancereviews_hashkey,
        he.employee_hashkey AS employee_hashkey,
        hr.employee_hashkey AS reviewer_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'PERFORMANCE_REVIEWS' AS record_source
    FROM {{ ref('stg_performance_reviews') }} pr
    INNER JOIN {{ ref('hub_employees') }} he ON pr.employeeid = he.employeeid
    INNER JOIN {{ ref('hub_employees') }} hr ON pr.reviewerid = hr.employeeid
    WHERE pr.reviewid IS NOT NULL
)

SELECT * FROM source_data