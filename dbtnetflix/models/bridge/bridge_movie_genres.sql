with dim_movies as (
    select * from {{ref('dim_movies')}}
)

select 
    m.movie_id,
    coalesce(trim(g.value::string), 'N/A') as genre
    
from dim_movies m,
lateral flatten(input => genre_array, outer => true) g