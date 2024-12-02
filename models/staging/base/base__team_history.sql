{{
  config(
    materialized='view',
    schema="base"
  )
}}

WITH src_details AS (
    SELECT * 
    FROM {{ source('nba_project', 'team_history') }}
    )

SELECT 
	TEAM_ID,
    CAST(CITY AS VARCHAR(255)) AS CITY,
    CAST(NICKNAME AS VARCHAR(255)) AS NICKNAME,
    CAST(YEAR_FOUNDED AS BIGINT) AS YEAR_FOUNDED,
    CAST(YEAR_ACTIVE_TILL AS BIGINT) AS YEAR_ACTIVE_TILL
FROM 
    src_details