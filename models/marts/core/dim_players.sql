{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='core'
  )
}}


SELECT distinct
    PLAYER_ID,
    {{ dbt_utils.star(from=ref('stg_players'), except=['PLAYER_ID']) }},
FROM {{ ref('stg_players') }}