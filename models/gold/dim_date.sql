{{ config(
    materialized='table',
    tags=['gold', 'dimension']
) }}

/*
    Date dimension table for time-based analysis.
    This table is generated using a date spine from 2010 to 2030.
*/

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('2010-01-01', 'YYYY-MM-DD')",
        end_date="to_date('2030-12-31', 'YYYY-MM-DD')"
    )
    }}
),

date_dimension AS (
    SELECT
        TO_CHAR(date_day, 'YYYYMMDD')::INTEGER AS date_key,
        date_day AS date,
        DAYOFWEEK(date_day) AS day_of_week,
        DAYNAME(date_day) AS day_name,
        DAY(date_day) AS day_of_month,
        DAYOFYEAR(date_day) AS day_of_year,
        WEEKOFYEAR(date_day) AS week_of_year,
        MONTH(date_day) AS month,
        MONTHNAME(date_day) AS month_name,
        QUARTER(date_day) AS quarter,
        YEAR(date_day) AS year,
        CASE
            WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE
            ELSE FALSE
        END AS is_weekend,
        FALSE AS is_holiday, -- This could be enhanced with a holiday calendar
        
        -- Assuming fiscal year starts in July
        CASE
            WHEN MONTH(date_day) >= 7 THEN YEAR(date_day)
            ELSE YEAR(date_day) - 1
        END AS fiscal_year,
        
        CASE
            WHEN MONTH(date_day) BETWEEN 7 AND 9 THEN 1
            WHEN MONTH(date_day) BETWEEN 10 AND 12 THEN 2
            WHEN MONTH(date_day) BETWEEN 1 AND 3 THEN 3
            WHEN MONTH(date_day) BETWEEN 4 AND 6 THEN 4
        END AS fiscal_quarter
    FROM date_spine
)

SELECT * FROM date_dimension
