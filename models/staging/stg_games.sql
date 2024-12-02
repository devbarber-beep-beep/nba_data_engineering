{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_game AS (
    SELECT * 
    FROM {{ ref('base__game') }}
),

bs_info as (
    select
    {{ dbt_utils.star(from=ref('base__game_info'), except=['GAME_DATE'])}}
    from {{ ref("base__game_info") }}
)

SELECT 
    i.{{ dbt_utils.star(from=ref('base__game_info'), except=['GAME_ID', 'GAME_DATE']) }},
    g.{{ dbt_utils.star(from=ref('base__game')) }},
FROM 
    bs_game g
LEFT JOIN bs_info i
ON g.GAME_ID = i.GAME_ID