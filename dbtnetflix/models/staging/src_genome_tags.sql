WITH raw_genome_tags AS (
    SELECT * FROM movielens.raw.raw_genome_tags
)

SELECT 
    tagId as tag_id,
    tag,
FROM raw_genome_tags