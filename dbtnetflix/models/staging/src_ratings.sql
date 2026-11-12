

WITH raw_ratings AS (
  SELECT * FROM MOVIELENS.RAW.RAW_RATINGS
)

SELECT
  userId AS user_id,
  movieId AS movie_id,
  rating,
  TO_TIMESTAMP_LTZ(rating_ts) AS rating_timestamp,
  TO_TIMESTAMP_LTZ(loaded_at) AS loading_timestamp,
  source_file
FROM raw_ratings