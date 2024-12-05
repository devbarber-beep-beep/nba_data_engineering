{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='games'
  )
}}


SELECT * 
FROM {{ ref('stg_play_by_play') }}