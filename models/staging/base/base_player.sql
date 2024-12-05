{{
  config(
    materialized='view',
    schema="base"
  )
}}

WITH src_players AS (
    SELECT * 
    FROM {{ source('nba_project', 'player') }}
    ),

renamed_casted AS (
    SELECT
    ID as PLAYER_ID,
	CAST(FULL_NAME AS VARCHAR(255)) as FULL_NAME,
	CAST(FIRST_NAME AS VARCHAR(255)) as FIRST_NAME,
	CAST(LAST_NAME AS VARCHAR(255)) as LAST_NAME,
	CAST(IS_ACTIVE as BOOLEAN) as IS_ACTIVE

    FROM src_players
    )

SELECT * FROM renamed_casted




