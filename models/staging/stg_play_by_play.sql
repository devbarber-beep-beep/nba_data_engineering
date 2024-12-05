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
),

with_duplicated AS (
SELECT 
    {{ dbt_utils.generate_surrogate_key([
        'GAME_ID',
        'EVENTNUM',
        'PERIOD',
        'PLAYER1_ID',
        'PLAYER2_ID',
        'PLAYER3_ID' 
    ]) }} as pbp_id,
    {{ dbt_utils.star(from=ref('base__play_by_play')) }},
FROM 
    bs_play_by_play
)

select distinct
pbp_id,
{{ dbt_utils.star(from=ref('base__play_by_play')) }}
from with_duplicated