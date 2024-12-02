with invalid_birthdate as (
    select birthdate
    from {{ ref('common_player_info') }}
    where birthdate !~ '^(\\d{4}-\\d{2}-\\d{2})([T ][0-2][0-9]:[0-5][0-9]:[0-5][0-9](\\.\\d{3})?(Z)?)?$'
)
select
    count(*) as invalid_count
from invalid_birthdate;
