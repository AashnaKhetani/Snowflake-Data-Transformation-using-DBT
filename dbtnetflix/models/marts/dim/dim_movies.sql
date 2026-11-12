
with src_movies as (
    -- Pointed to the snapshot to capture historical versions
    select * from {{ ref('snap_movies')}}
),

src_links as (
    select * from {{ ref('src_links') }}
)

select 
    -- Natively generates a unique surrogate key for each historical version of a movie row
    {{ dbt.hash(concat(['m.movie_id', 'm.dbt_valid_from'])) }} as dim_movie_key,
    
    m.movie_id,
    trim(m.title) as movie_title,
    try_to_number(regexp_substr(m.title, '\\((\\d{4})\\)\\s*$', 1, 1, 'e', 1)) as release_year,
    split(nullif(m.genres, '(no genres listed)'), '|') as genre_array,
    m.genres as raw_genres,
    l.imdb_id,
    l.tmdb_id,

    -- SCD Type 2 Timeline Metadata from the snapshot
    m.dbt_valid_from as valid_from,
    coalesce(m.dbt_valid_to, '9999-12-31'::timestamp) as valid_to,

    -- Current Version Flag
    case 
        when m.dbt_valid_to is null then true 
        else false 
    end as is_current

from src_movies m
left join src_links l
    on m.movie_id = l.movie_id
