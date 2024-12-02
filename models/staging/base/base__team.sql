{{
  config(
    materialized='view',
    schema="base"
  )
}}

WITH src_team AS (
    SELECT * 
    FROM {{ source('nba_project', 'team') }}
    )

SELECT 
	ID AS TEAM_ID,
    CAST(FULL_NAME AS VARCHAR(255)) AS FULL_NAME,
    CAST(ABBREVIATION AS VARCHAR(255)) AS ABBREVIATION,
    CAST(NICKNAME AS VARCHAR(255)) AS NICKNAME,
    CAST(CITY AS VARCHAR(255)) AS CITY,
    CAST(STATE AS VARCHAR(255)) AS STATE,
    CAST(YEAR_FOUNDED AS FLOAT) AS YEAR_FOUNDED
FROM 
    src_team