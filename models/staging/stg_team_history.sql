{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_history AS (
    SELECT * 
    FROM {{ ref('base__team_history') }}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['TEAM_ID', 'YEAR_FOUNDED', 'CITY']) }} as team_history_id,
    {{ dbt_utils.star(from=ref('base__team_history')) }},
FROM 
    bs_history 