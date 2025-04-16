{{ config(materialized='incremental', unique_key='link_hashkey') }}

WITH source_data AS (

    SELECT
        MD5(emp.employee_hashkey) AS link_hashkey,
        emp.employee_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'PAYROLLS' AS record_source
    FROM {{ source('TELELINK', 'PAYROLLS') }} AS PR
    INNER JOIN {{ ref('hub_employees') }} AS emp
        ON PR.EMPLOYEEID = emp.employeeid
    WHERE PR.PAYROLLID IS NOT NULL
        AND PR.EMPLOYEEID IS NOT NULL
        AND PR.GROSSPAY > 0
        AND PR.NETPAY > 0
        AND PR.NETPAY <= PR.GROSSPAY
)

SELECT
    link_hashkey,
    employee_hashkey,
    load_date,
    record_source
FROM source_data