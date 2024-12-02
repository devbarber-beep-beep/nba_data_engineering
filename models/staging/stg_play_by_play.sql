{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_play_by_play AS (
    SELECT * 
    FROM {{ ref('base__play_by_play') }}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['GAME_ID', 'EVENTNUM']) }} as pbp_id,
    {{ dbt_utils.star(from=ref('base__play_by_play')) }},
FROM 
    bs_play_by_play