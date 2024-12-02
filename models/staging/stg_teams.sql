{{
  config(
    database='ALUMNO6_DEV_SILVER_DB',
    materialized='view',
    schema='staging'
  )
}}

WITH bs_team AS (
    SELECT * 
    FROM {{ ref('base__team') }}
),

bs_details as (
    select {{ dbt_utils.star(from=ref('base__team_details'), except=[ 'ABBREVIATION', 'CITY', 'NICKNAME', 'YEARFOUNDED' ]) }}
    from {{ ref("base__team_details") }}
)

SELECT 
    t.{{ dbt_utils.star(from=ref('base__team')) }},
    {{ dbt_utils.star(from=ref('base__team_details'), except=['TEAM_ID', 'ABBREVIATION', 'CITY', 'NICKNAME', 'YEARFOUNDED' ]) }},
FROM 
    bs_team t
LEFT JOIN bs_details d
ON t.TEAM_ID = d.TEAM_ID