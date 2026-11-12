-- Analysis: Top Rated Movies (only movies with at least 100 ratings)

WITH ratings_summary AS (
  SELECT
    movie_id,
    AVG(rating) AS average_rating,
    COUNT(*) AS total_ratings
  FROM {{ ref('fct_ratings') }}
  GROUP BY movie_id
  HAVING COUNT(*) > 100 -- Only movies with at least a 100 ratings
)
SELECT
  m.movie_title,
  rs.average_rating,
  rs.total_ratings
FROM ratings_summary rs
JOIN {{ ref('dim_movies') }} m ON m.movie_id = rs.movie_id
ORDER BY rs.average_rating DESC
LIMIT 200;

 
-- Analysis: Rating Distribution Across Genres
-- Uses the bridge table (one row per movie and genre), so no array unnesting is needed.
-- A movie with three genres counts in each of them. Averages are fine; do not add up counts across genres.
select
    b.genre,
    round(avg(r.rating), 3)        as average_rating,
    count(distinct b.movie_id)     as total_movies
from {{ ref('fct_ratings') }} r
join {{ ref('bridge_movie_genres') }} b
    on r.movie_id = b.movie_id
group by b.genre
order by average_rating desc;
 
 
-- Analysis: User Engagement (Number of Ratings per User)
select
    user_id,
    count(*)                 as number_of_ratings,
    round(avg(rating), 2)    as average_rating_given
from {{ ref('fct_ratings') }}
group by user_id
order by number_of_ratings desc
limit 20;
 
 
-- Analysis: Trends of Movie Releases Over Time
-- Assumes the seed has columns movie_id and release_date. Adjust the names if yours differ.
select
    extract(year from release_date)  as release_year,
    count(distinct movie_id)         as movies_released
from {{ ref('seed_movie_release_dates') }}
group by release_year
order by release_year asc;
 
 
-- Analysis: Tag Relevance Analysis
-- Every movie in the genome has a score for every tag, so counting movies per tag gives the same
-- number for all tags. strong_matches counts only movies where the tag scores 0.5 or more.
select
    t.tag_name,
    round(avg(gs.relevance_score), 4)                                          as avg_relevance,
    count(distinct case when gs.relevance_score >= 0.5 then gs.movie_id end)   as strong_matches
from {{ ref('fct_genome_scores') }} gs
join {{ ref('dim_genome_tags') }} t
    on gs.tag_id = t.tag_id
group by t.tag_name
order by avg_relevance desc
limit 20;
