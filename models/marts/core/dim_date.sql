{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='core'
  )
}}


SELECT * 
FROM {{ ref('stg_time') }}