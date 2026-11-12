with fct_ratings as (
    select * from {{ref('fct_ratings')}}
),

seed_dates as (
    select * from {{ref('seed_movie_release_dates')}}
)

select 
    f.*,
    s.release_date 
from fct_ratings f 
left join seed_dates s 
on f.movie_id = s.movie_id