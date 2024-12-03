{{
  config(
    materialized='view',
    schema="staging"
  )
}}

WITH src_summary AS (
    SELECT * 
    FROM {{ ref("base__line_score") }}
    ),

with_duplicated as (
    SELECT 
        {{ dbt_utils.generate_surrogate_key([
        'game_id',                
        'team_id_home',          
        'team_id_away',           
        'game_date_est',          
        'game_sequence',          
        'pts_t1_loc', 'pts_t2_loc', 'pts_t3_loc', 'pts_t4_loc', 
        'pts_ot1_loc', 'pts_ot2_loc', 'pts_ot3_loc', 
        'pts_t1_vis', 'pts_t2_vis', 'pts_t3_vis', 'pts_t4_vis',
        'pts_ot1_vis', 'pts_ot2_vis', 'pts_ot3_vis'
    ]) }} AS score_id,
        {{ dbt_utils.star(from=ref('base__line_score')) }},
    FROM 
        src_summary
)

SELECT distinct
score_id,
{{ dbt_utils.star(from=ref('base__line_score')) }},
FROM 
    with_duplicated