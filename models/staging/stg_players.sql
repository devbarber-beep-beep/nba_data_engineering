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

bs_info as (
    select * 
    from {{ ref("base_common_player_info") }}
),

bs_draft as (
    select * 
    from {{ ref("base_player_draft_history") }}
)

SELECT 
    p.{{ dbt_utils.star(from=ref('base_player')) }},
    i.{{ dbt_utils.star(from=ref('base_common_player_info'), except=['PLAYER_ID']) }},
    d.{{ dbt_utils.star(from=ref('base_player_draft_history'), except=['PLAYER_ID', 'PLAYER_NAME']) }}
FROM 
    bs_player p
LEFT JOIN bs_info i
ON p.PLAYER_ID = i.PLAYER_ID
LEFT JOIN bs_draft d
on p.PLAYER_ID = d.PLAYER_ID