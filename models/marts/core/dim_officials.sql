{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='core'
  )
}}

with stg_officials as (
    select {{ dbt_utils.star(from=ref('stg_officials')) }}
    from {{ ref('stg_officials') }}
)

SELECT 
    OFFICIAL_ID, 
    MIN(FIRST_NAME) AS first_name, 
    MIN(LAST_NAME) AS last_name, 
    MIN(JERSEY_NUM) AS jersey_num
FROM stg_officials
GROUP BY OFFICIAL_ID
    