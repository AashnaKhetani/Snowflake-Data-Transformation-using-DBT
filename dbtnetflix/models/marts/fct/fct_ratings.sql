{#
  fct_ratings: incremental model, one row per (user, movie).

  materialized       build the full table once, then only add new data
  unique_key         a rating row is identified by user + movie; if the key already
                     exists, update that row instead of adding a duplicate
  on_schema_change   stop the run if columns change, instead of guessing
#}

{{ config(
    materialized = 'incremental',
    unique_key = ['user_id', 'movie_id'],
    on_schema_change = 'fail'
) }}

-- the two timestamps do different jobs

--loading_timestamp answers “is this row new to me?”, so it’s the right filter for what to read.
--rating_timestamp answers “which version is the real current one?”, so it should decide which row wins.

-- dropping stale rows before the merge, and deduplicate inside the batch
with src_ratings as (
    select * from {{ ref('src_ratings') }}
    where rating is not null
    {% if is_incremental() %}
    {# runs only after the 1st build, when the table already exists 
    'this' is themodel's own table 
    compare the arrival_time(time when snowflake reads the file records i.e. loading_timestamp
    so a backfilled row with an old rating date is still picked up #}
      and loading_timestamp > (select max(loading_timestamp) from {{ this }})
    {% endif %}
),

fresh as (
    select s.*
    from src_ratings s
    {% if is_incremental() %}
    where not exists (
        select 1 from {{ this }} t
        where t.user_id = s.user_id
          and t.movie_id = s.movie_id
          and t.rating_timestamp > s.rating_timestamp
    )
    {% endif %}
)

select user_id, movie_id, rating, rating_timestamp, loading_timestamp
from fresh
qualify row_number() over (
    partition by user_id, movie_id
    order by rating_timestamp desc, loading_timestamp desc
) = 1