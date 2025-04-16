{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['jh.jobhistoryid']) }} AS link_jobhistories_hashkey,
        he.employee_hashkey AS employee_hashkey,
        hj.jobposition_hashkey AS jobposition_hashkey,
        hd.department_hashkey AS department_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'JOB_HISTORIES' AS record_source
    FROM {{ ref('stg_job_histories') }} jh
    INNER JOIN {{ ref('hub_employees') }} he ON jh.employeeid = he.employeeid
    INNER JOIN {{ ref('hub_jobpositions') }} hj ON jh.jobid = hj.jobid
    INNER JOIN {{ ref('hub_departments') }} hd ON jh.departmentid = hd.departmentid
    WHERE jh.jobhistoryid IS NOT NULL
)

SELECT * FROM source_data