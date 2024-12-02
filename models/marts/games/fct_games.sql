{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='games'
  )
}}

WITH scores as (
    select
    {{ dbt_utils.star(from=ref('stg_game_scores')) }}
    from {{ ref('stg_game_scores') }}
),


games as (
    select
    {{ dbt_utils.star(from=ref('stg_games')) }}
    from {{ ref('stg_games') }}
)


select
    {{ dbt_utils.star(from=ref('stg_games'), relation_alias='g') }},
    {{ dbt_utils.star(from=ref('stg_game_scores'), except=['SCORE_ID', 'GAME_ID','TEAM_ID_HOME', 'TEAM_ID_AWAY', 'EQUIPO_ABREV_LOC', 'EQUIPO_ABREV_VIS', 'PTS_LOC', 'PTS_VIS', 'GAME_DATE_EST' ], prefix='SCORE_', relation_alias='sc') }},
from games g
LEFT JOIN scores sc
ON g.GAME_ID = sc.GAME_ID

