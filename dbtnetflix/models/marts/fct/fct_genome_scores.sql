with src_scores as (
    select * from {{ref('src_genome_scores')}}
)

select
    movie_id,
    tag_id,
    round(relevance, 4) as relevance_score
from src_scores
where relevance > 0 
-- for this dataset all rows retained for 0 threshold but it can be set to 0.5 to drop low relevance rows