{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(CONCAT(emp.employee_hashkey, job.jobposition_hashkey, dept.department_hashkey)) AS link_hashkey,
        emp.employee_hashkey,
        job.jobposition_hashkey,
        dept.department_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'JOB_HISTORIES' AS record_source
    FROM {{ source('TELELINK', 'JOB_HISTORIES') }} AS JH
    INNER JOIN {{ ref('hub_employees') }} AS emp
        ON JH.EMPLOYEEID = emp.employeeid
    INNER JOIN {{ ref('hub_jobpositions') }} AS job
        ON JH.JOBID = job.jobid
    INNER JOIN {{ ref('hub_departments') }} AS dept
        ON JH.DEPARTMENTID = dept.departmentid
    WHERE JH.JOBHISTORYID IS NOT NULL
        AND JH.EMPLOYEEID IS NOT NULL
        AND JH.JOBID IS NOT NULL
        AND JH.STARTDATE < JH.ENDDATE
)

SELECT
    link_hashkey,
    employee_hashkey,
    jobposition_hashkey,
    department_hashkey,
    load_date,
    record_source
FROM source_data