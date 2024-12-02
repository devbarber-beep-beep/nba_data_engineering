{% snapshot stg_teams_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database='ALUMNO6_DEV_SILVER_DB',
        strategy='check',
        check_cols='all',
        unique_key='TEAM_ID',
        materialized='snapshot'
    )
}}

SELECT
    {{ dbt_utils.star(from=ref('stg_teams')) }}
FROM {{ ref('stg_teams') }}

{% endsnapshot %}
