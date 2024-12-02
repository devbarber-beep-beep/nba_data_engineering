{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='games'
  )
}}

WITH scores as (
    select
    {{ dbt_utils.star(from=ref('stg_game_scores'), prefix='score_') }}
    from {{ ref('stg_game_scores') }}
),

stats as (
    select
    {{ dbt_utils.star(from=ref('stg_game_stats'), except=['GAME_DATE_EST'], prefix='stats_') }}
    from {{ ref('stg_game_stats') }}
),

games as (
    select
    {{ dbt_utils.star(from=ref('stg_games')) }}
    from {{ ref('stg_games') }}
)


select
    {{ dbt_utils.star(from=ref('stg_games')) }},
    {{ dbt_utils.star(from=ref('stats'), except=['STATS_GAME_ID', 'STATS_TEAM_ID_HOME', 'STATS_TEAM_ID_AWAY', 'STATS_TEAM_ABBREVIATION_HOME', 'STATS_TEAM_ABBREVIATION_AWAY']) }}
    {{ dbt_utils.star(from=ref('scores'), except=['SCORE_GAME_ID', 'SCORE_GAME_DATE_EST', 'SCORE_TEAM_ID_HOME', 'SCORE_TEAM_ID_AWAY', 'SCORE_PTS_HOME', 'SCORE_PTS_AWAY', 'SCORE_SEASON']) }}
from games g
LEFT JOIN stats st
ON g.GAME_ID = st.GAME_ID
LEFT JOIN scores sc
on g.GAME_ID = sc.GAME_ID

