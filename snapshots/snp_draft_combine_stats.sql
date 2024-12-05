{% snapshot stg_draft_combine_stats_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database='ALUMNO6_DEV_SILVER_DB',
        strategy='check',
        check_cols='all',
        unique_key='DRAFT_COMBINE_STATS_ID',
        materialized='snapshot'
    )
}}

SELECT
    {{ dbt_utils.star(from=ref('stg_draft_combine_stats')) }}
FROM {{ ref('stg_draft_combine_stats') }}

{% endsnapshot %}
