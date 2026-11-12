WITH raw_genome_scores AS (
    SELECT * FROM movielens.raw.raw_genome_scores
)

SELECT 
    movieId as movie_id,
    tagId as tag_id,
    relevance,
FROM raw_genome_scores