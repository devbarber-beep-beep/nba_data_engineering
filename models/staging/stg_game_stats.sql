{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_summary AS (
    SELECT * 
    FROM {{ ref('base__game_summary') }}
),

bs_stats as (
    select
    {{ dbt_utils.star(from=ref('base__other_stats'), except=['TEAM_ID_HOME', 'TEAM_ID_AWAY']) }}
    from {{ ref("base__other_stats") }}
)

SELECT 
    su.{{ dbt_utils.star(from=ref('base__game_summary')) }},
    st.{{ dbt_utils.star(from=ref('base__other_stats'), except=['GAME_ID', 'TEAM_ID_HOME', 'TEAM_ID_AWAY']) }}
FROM 
    bs_summary su
LEFT JOIN bs_stats st
ON su.GAME_ID=st.GAME_ID