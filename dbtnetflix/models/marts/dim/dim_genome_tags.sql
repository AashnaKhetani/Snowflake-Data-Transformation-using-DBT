with src_tags as (
    select * from {{ref('src_genome_tags')}}
)

select
    tag_id,
    initcap(trim(tag)) as tag_name,
from src_tags