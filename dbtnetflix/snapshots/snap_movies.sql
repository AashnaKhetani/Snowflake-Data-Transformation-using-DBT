{% snapshot snap_movies %}

{{
    config(
      target_schema='snapshots',
      unique_key='movie_id',
      strategy='check',
      check_cols=['title', 'genres'],
      hard_deletes='invalidate'
    )
}}

select
    movie_id,
    title,
    genres
from {{ ref('src_movies') }}

{% endsnapshot %}