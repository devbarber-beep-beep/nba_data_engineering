{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='draft'
  )
}}


SELECT * 
FROM {{ ref('stg_draft_combine_stats') }}