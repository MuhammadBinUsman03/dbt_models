{{ config(
    materialized='table',
    tags=['gold', 'fact', 'hr']
) }}

/*
    Employment fact table for the HR domain.
    This table contains employment records with references to relevant dimensions.
*/

WITH job_histories AS (
    SELECT
        jh.JOBHISTORYID,
        jh.EMPLOYEEID,
        jh.JOBID,
        jh.STARTDATE,
        jh.ENDDATE,
        jh.DEPARTMENTID
    FROM {{ source('bronze', 'JOB_HISTORIES') }} jh
),

dim_employee_current AS (
    SELECT
        employee_key,
        employee_id
    FROM {{ ref('dim_employee') }}
    WHERE is_current = TRUE
),

dim_job_position_current AS (
    SELECT
        job_key,
        job_id
    FROM {{ ref('dim_job_position') }}
    WHERE is_current = TRUE
),

dim_department_current AS (
    SELECT
        department_key,
        department_id
    FROM {{ ref('dim_department') }}
    WHERE is_current = TRUE
),

dim_date AS (
    SELECT
        date_key,
        date
    FROM {{ ref('dim_date') }}
),

final_employment AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['jh.JOBHISTORYID']) }} AS employment_key,
        de.employee_key,
        dj.job_key,
        dd.department_key,
        start_date.date_key AS start_date_key,
        end_date.date_key AS end_date_key,
        manager.employee_key AS manager_key,
        CASE
            WHEN jh.ENDDATE IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current
    FROM job_histories jh
    LEFT JOIN dim_employee_current de
        ON jh.EMPLOYEEID = de.employee_id
    LEFT JOIN dim_job_position_current dj
        ON jh.JOBID = dj.job_id
    LEFT JOIN dim_department_current dd
        ON jh.DEPARTMENTID = dd.department_id
    LEFT JOIN dim_date start_date
        ON TO_DATE(jh.STARTDATE) = start_date.date
    LEFT JOIN dim_date end_date
        ON TO_DATE(jh.ENDDATE) = end_date.date
    LEFT JOIN (
        SELECT
            e.MANAGERID,
            de.employee_key
        FROM {{ ref('sat_employees_details') }} e
        JOIN dim_employee_current de
            ON e.EMPLOYEEID = de.employee_id
        WHERE e.LOAD_DATE = (
            SELECT MAX(LOAD_DATE)
            FROM {{ ref('sat_employees_details') }}
            WHERE EMPLOYEEID = e.EMPLOYEEID
        )
    ) manager
        ON jh.EMPLOYEEID IN (
            SELECT EMPLOYEEID
            FROM {{ ref('sat_employees_details') }}
            WHERE MANAGERID = manager.MANAGERID
        )
)

SELECT * FROM final_employment
