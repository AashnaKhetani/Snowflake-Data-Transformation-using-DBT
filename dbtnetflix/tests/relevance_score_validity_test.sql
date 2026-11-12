{# select
    movie_id,
    tag_id,
    relevance_score
from {{ref('fct_genome_scores')}} 
where relevance_score is null 
    or relevance_score not between 0 and 1 #}

{{ no_nulls_in_columns(ref('fct_genome_scores'))}}    