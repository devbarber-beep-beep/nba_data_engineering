{{
  config(
    materialized='view',
    schema="staging"
  )
}}

WITH src_summary AS (
    SELECT * 
    FROM {{ ref("base__line_score") }}
    )

SELECT 
	{{ dbt_utils.generate_surrogate_key(['GAME_ID', 'GAME_SEQUENCE']) }} as score_id,
    {{ dbt_utils.star(from=ref('base__line_score')) }},
FROM 
    src_summary