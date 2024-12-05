{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_player AS (
    SELECT * 
    FROM {{ ref('base_player') }}
),

bs_info AS (
    SELECT * 
    FROM {{ ref("base_common_player_info") }}
),

bs_draft AS (
    SELECT * 
    FROM {{ ref("base_player_draft_history") }}
),

with_errors AS (
    SELECT 
        {{ dbt_utils.star(from=ref('base_player'),relation_alias='p') }},
        {{ dbt_utils.star(from=ref('base_common_player_info'), except=['PLAYER_ID'], relation_alias='i') }},
        {{ dbt_utils.star(from=ref('base_player_draft_history'), except=['PLAYER_ID', 'PLAYER_NAME'], relation_alias='d') }},
        ROW_NUMBER() OVER (
            PARTITION BY p.PLAYER_ID
            ORDER BY p.PLAYER_ID -- Ajusta aquí si necesitas un criterio adicional
        ) AS row_num
    FROM 
        bs_player p
    LEFT JOIN bs_info i
    ON p.PLAYER_ID = i.PLAYER_ID
    LEFT JOIN bs_draft d
    ON p.PLAYER_ID = d.PLAYER_ID
)

SELECT *
FROM with_errors
WHERE row_num = 1
  AND team_id IS NOT NULL
