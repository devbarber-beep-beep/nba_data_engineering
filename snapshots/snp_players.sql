{% snapshot bs_players_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database='ALUMNO6_DEV_SILVER_DB',
        strategy='check',
        check_cols='all',
        unique_key='PLAYER_ID',
        materialized='snapshot'
    )
}}

SELECT
    {{ dbt_utils.star(from=ref('base_player')) }}
FROM {{ ref('base_player') }}

{% endsnapshot %}