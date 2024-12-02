with invalid_draft_number as (
    select draft_number
    from {{ ref('draft_history') }}
    where draft_number !~ '^\\d+$|^Undrafted$'
)
select
    count(*) as invalid_count
from invalid_draft_number;
