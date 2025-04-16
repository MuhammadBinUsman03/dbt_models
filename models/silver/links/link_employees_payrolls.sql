{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['p.payrollid']) }} AS link_payrolls_hashkey,
        he.employee_hashkey AS employee_hashkey,
        CURRENT_TIMESTAMP() AS load_date,
        'PAYROLLS' AS record_source
    FROM {{ ref('stg_payrolls') }} p
    INNER JOIN {{ ref('hub_employees') }} he ON p.employeeid = he.employeeid
    WHERE p.payrollid IS NOT NULL
)

SELECT * FROM source_data