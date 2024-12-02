{{
  config(
    materialized='view',
    schema="base"
  )
}}

WITH src_officials AS (
    SELECT * 
    FROM {{ source('nba_project', 'officials') }}
)
SELECT 
    GAME_ID,
    OFFICIAL_ID,
    CAST(FIRST_NAME AS VARCHAR(255)) AS FIRST_NAME,
    CAST(LAST_NAME AS VARCHAR(255)) AS LAST_NAME,
    JERSEY_NUM
FROM 
    src_officials