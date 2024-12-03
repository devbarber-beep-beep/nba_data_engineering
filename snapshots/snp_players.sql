{% snapshot stg_players_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database='ALUMNO6_DEV_SILVER_DB',
        strategy='check',
        check_cols='all',
        unique_key='FULL_NAME',
        materialized='snapshot'
    )
}}

SELECT
    {{ dbt_utils.star(from=ref('stg_players')) }}
FROM {{ ref('stg_players') }}

{% endsnapshot %}