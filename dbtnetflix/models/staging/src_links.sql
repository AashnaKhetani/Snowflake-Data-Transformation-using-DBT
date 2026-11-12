WITH raw_links AS (
    SELECT * FROM movielens.raw.raw_links
)

SELECT 
    movieId as movie_id,
    imdbId as imdb_id,
    tmdbId as tmdb_id,
FROM raw_links