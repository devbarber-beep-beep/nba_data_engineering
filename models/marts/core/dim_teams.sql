{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='core'
  )
}}

with stg_teams as (
    select {{ dbt_utils.star(from=ref('stg_teams')) }}
    from {{ ref('stg_teams') }}
),

stg_team_history as(
    select {{ dbt_utils.star(from=ref('stg_team_history'), except=['TEAM_ID', 'CITY', 'NICKNAME', 'YEAR_FOUNDED']) }}
    from {{ ref('stg_team_history') }}
)


SELECT 
    {{ dbt_utils.star(from=ref('stg_teams'),  except=['TEAM_HISTORY_ID'])  }},
    t.team_history_id,
    {{ dbt_utils.star(from=ref('stg_team_history'),  except=['TEAM_ID', 'TEAM_HISTORY_ID','CITY', 'NICKNAME', 'YEAR_FOUNDED']) }}  
FROM 
    stg_teams t
LEFT JOIN stg_team_history th
on t.team_history_id = th.team_history_id