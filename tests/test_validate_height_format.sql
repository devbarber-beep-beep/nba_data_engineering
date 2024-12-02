with invalid_height as (
    select height
    from {{ ref('common_player_info') }}
    where height !~ '^[1-9]\'([0-9]|1[0-1])"?$'
)
select
    count(*) as invalid_count
from invalid_height;