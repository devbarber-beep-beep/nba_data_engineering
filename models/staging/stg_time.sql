{{
  config(
    materialized='view',
    schema="staging",
  )
}}
    --pre_hook="alter session set timezone = 'Europe/Madrid'; alter session set week_start = 7;"

WITH base_date AS(
    SELECT * FROM (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2025-12-31' as date)"
    )
    }}
    )
)

SELECT 
    date_day as date_id                  -- Id de la fecha
    , year (date_day) as year            -- Año
    , month(date_day) as month_number    -- Mes (número)
    , to_char(date_day, 'Month') as month_name  -- Mes (nombre)
    , day(date_day) as day_of_month      -- Día del mes
    , case 
        when dayofweek(date_day) = 0 then 7
        else dayofweek(date_day)
    end as weekday_number                -- Día de la semana (1 = Lunes, 7 = Domingo)
    , dayname(date_day) as weekday_name  -- Día de la semana (nombre)
    , quarter(date_day) as quarter       -- Trimestre (1-4)
    , case
        when month(date_day) in (1, 2, 3, 4) then 1  -- Cuatrimestre 1
        when month(date_day) in (5, 6, 7, 8) then 2  -- Cuatrimestre 2
        when month(date_day) in (9, 10, 11, 12) then 3  -- Cuatrimestre 3
    end as quatrimester  -- Cuatrimestre (1-3)

    , case
        when month(date_day) in (1, 2, 3, 4, 5, 6) then 1  -- Semestre 1
        when month(date_day) in (7, 8, 9, 10, 11, 12) then 2  -- Semestre 2
    end as semester  -- Semestre (1-2)

    , case 
        when dayofweek(date_day) in (1, 2, 3, 4, 5) then 'Weekday'
        else 'Weekend'
    end as day_type  -- Tipo de día (fin de semana o día de semana)

from base_date