{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_draft AS (
    SELECT * 
    FROM {{ ref('base__draft_combine_stats') }}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['PLAYER_ID', 'SEASON']) }} as draft_combine_stats_id,
    {{ dbt_utils.star(from=ref('base__draft_combine_stats')) }},
FROM 
    bs_draft