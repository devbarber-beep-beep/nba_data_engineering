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
),

with_duplicated as (SELECT 
    {{ dbt_utils.generate_surrogate_key(['OFFICIAL_ID', 'GAME_ID', 'LAST_NAME']) }} as official_by_game_id,
    {{ dbt_utils.star(from=ref('base__officials')) }},
FROM 
    bs_officials
)

SELECT 
distinct official_by_game_id, {{ dbt_utils.star(from=ref('base__officials')) }}
from with_duplicated