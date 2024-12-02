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
	CAST(FULL_NAME AS VARCHAR(255)),
	CAST(FIRST_NAME AS VARCHAR(255)),
	CAST(LAST_NAME AS VARCHAR(255)),
	CAST(IS_ACTIVE as BOOLEAN) as IS_ACTIVE

    FROM src_players
    )

SELECT * FROM renamed_casted



