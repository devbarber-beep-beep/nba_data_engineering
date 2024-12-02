{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_officials AS (
    SELECT * 
    FROM {{ ref('base__officials') }}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['OFFICIAL_ID', 'GAME_ID']) }} as official_by_game_id,
    {{ dbt_utils.star(from=ref('base__officials')) }},
FROM 
    bs_officials