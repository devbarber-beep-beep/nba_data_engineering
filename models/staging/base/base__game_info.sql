{{
  config(
    materialized='view',
    schema="base"
  )
}}

WITH src_games AS (
    SELECT * 
    FROM {{ source('nba_project', 'game_info') }}
)
SELECT 
    GAME_ID,
    GAME_DATE,
    COALESCE(ATTENDANCE, 0) as ATTENDANCE,
    CAST(GAME_TIME AS VARCHAR(255)) AS GAME_TIME
FROM 
    src_games