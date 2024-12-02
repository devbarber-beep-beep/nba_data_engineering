{% snapshot stg_games_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database='ALUMNO6_DEV_SILVER_DB',
        strategy='check',
        check_cols='all',
        unique_key='GAME_ID',
        materialized='snapshot'
    )
}}

SELECT
    {{ dbt_utils.star(from=ref('stg_games')) }}
FROM {{ ref('stg_games') }}

{% endsnapshot %}