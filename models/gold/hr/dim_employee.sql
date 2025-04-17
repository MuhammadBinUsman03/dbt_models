{{ config(
    materialized='table',
    tags=['gold', 'dimension', 'hr']
) }}

/*
    Employee dimension table for the HR domain.
    This is a Type 2 Slowly Changing Dimension (SCD) that tracks historical changes.
*/

WITH employee_hub AS (
    SELECT
        hash_key,
        business_key AS employee_id,
        load_date
    FROM {{ ref('hub_employees') }}
),

employee_sat AS (
    SELECT
        EMPLOYEEID,
        FIRSTNAME,
        LASTNAME,
        DATEOFBIRTH,
        GENDER,
        HIREDATE,
        JOBID,
        DEPARTMENTID,
        MANAGERID,
        EMAIL,
        PHONE,
        ADDRESS,
        EMPLOYMENTSTATUS,
        LOAD_DATE AS effective_from,
        LEAD(LOAD_DATE) OVER (
            PARTITION BY EMPLOYEEID 
            ORDER BY LOAD_DATE
        ) AS effective_to
    FROM {{ ref('sat_employees_details') }}
),

final_employees AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['h.hash_key', 's.effective_from']) }} AS employee_key,
        h.employee_id,
        s.FIRSTNAME AS first_name,
        s.LASTNAME AS last_name,
        CONCAT(s.FIRSTNAME, ' ', s.LASTNAME) AS full_name,
        s.DATEOFBIRTH AS date_of_birth,
        s.GENDER AS gender,
        s.HIREDATE AS hire_date,
        s.EMAIL AS email,
        s.PHONE AS phone,
        s.ADDRESS AS address,
        s.EMPLOYMENTSTATUS AS employment_status,
        s.effective_from,
        COALESCE(s.effective_to, '9999-12-31'::TIMESTAMP) AS effective_to,
        CASE
            WHEN s.effective_to IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current
    FROM employee_hub h
    INNER JOIN employee_sat s
        ON h.employee_id = s.EMPLOYEEID
)

SELECT * FROM final_employees
