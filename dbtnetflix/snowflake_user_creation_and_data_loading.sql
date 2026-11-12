-- Snowflake user creation
-- Step 1: Use an admin role
USE ROLE ACCOUNTADMIN;

-- Step 2: Create the `transform` role and assign it to ACCOUNTADMIN
CREATE ROLE IF NOT EXISTS TRANSFORM;
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN;

-- Step 3: Create a default warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;

-- Step 4: Create the `dbt` user and assign to the transform role
CREATE USER IF NOT EXISTS dbt
  PASSWORD='dbtPassword123'
  LOGIN_NAME='dbt'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE_WH'
  DEFAULT_ROLE=TRANSFORM
  DEFAULT_NAMESPACE='MOVIELENS.RAW'
  COMMENT='DBT user used for data transformation';
ALTER USER dbt SET TYPE = LEGACY_SERVICE;
GRANT ROLE TRANSFORM TO USER dbt;

-- Step 5: Create a database and schema for the MovieLens project
CREATE DATABASE IF NOT EXISTS MOVIELENS;
CREATE SCHEMA IF NOT EXISTS MOVIELENS.RAW;

-- Step 6: Grant permissions to the `transform` role
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;
GRANT ALL ON DATABASE MOVIELENS TO ROLE TRANSFORM;
GRANT ALL ON ALL SCHEMAS IN DATABASE MOVIELENS TO ROLE TRANSFORM;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE MOVIELENS TO ROLE TRANSFORM;
GRANT ALL ON ALL TABLES IN SCHEMA MOVIELENS.RAW TO ROLE TRANSFORM;
GRANT ALL ON FUTURE TABLES IN SCHEMA MOVIELENS.RAW TO ROLE TRANSFORM;

-- creating a staging space for the s3 data
CREATE OR REPLACE STAGE netflixstage
  URL='s3://.....raw-data '
  CREDENTIALS=(AWS_KEY_ID='*******' AWS_SECRET_KEY='*****');

-- script to define/ re-define the DDL structure of 'raw' Tables in staging area
-- movie.csv
CREATE OR REPLACE TABLE raw_movies (
  movieId INTEGER,
  title STRING,
  genres STRING
);

--rating.csv
CREATE OR REPLACE TABLE raw_ratings (
  userId INTEGER,
  movieId INTEGER,
  rating FLOAT,
  rating_ts TIMESTAMP_NTZ,
  loaded_at TIMESTAMP_NTZ,
  source_file VARCHAR
);

-- tag.csv
CREATE OR REPLACE TABLE raw_tags (
  userId INTEGER,
  movieId INTEGER,
  tag STRING,
  tag_ts TIMESTAMP_NTZ
);

-- genome_scores.csv
CREATE OR REPLACE TABLE raw_genome_scores (
  movieId INTEGER,
  tagId INTEGER,
  relevance FLOAT
);

-- genome_tags.csv
CREATE OR REPLACE TABLE raw_genome_tags (
  tagId INTEGER,
  tag STRING
);

-- link.csv
CREATE OR REPLACE TABLE raw_links (
  movieId INTEGER,
  imdbId INTEGER,
  tmdbId INTEGER
);

-- Loading Raw tables in Staging from s3

COPY INTO raw_movies
FROM '@netflixstage/movie.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"' ESCAPE = '\\' );

COPY INTO raw_ratings (userId, movieId, rating, rating_ts, loaded_at, source_file) 
FROM ( 
    SELECT $1, $2, $3, $4, METADATA$START_SCAN_TIME::TIMESTAMP_NTZ, METADATA$FILENAME 
    FROM @netflixstage
    ) 
    --added load time (when snowflake reads source data) and source file (eg s3 for traceability)
    PATTERN = '.*rating.*[.]csv'
    FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"' ESCAPE = '\\');

--select * from movielens.raw.raw_ratings limit 10;

--COPY INTO raw_ratings
--FROM '@netflixstage/rating.csv'
--FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO raw_tags
FROM '@netflixstage/tag.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"' ESCAPE = '\\')
ON_ERROR = 'CONTINUE';


COPY INTO raw_genome_scores
FROM '@netflixstage/genome_scores.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');


COPY INTO raw_genome_tags
FROM '@netflixstage/genome_tags.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');


COPY INTO raw_links
FROM '@netflixstage/link.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');


SHOW TABLES IN SCHEMA MOVIELENS.RAW;
SHOW VIEWS IN SCHEMA MOVIELENS.RAW;
MOVIELENS.RAWMOVIELENS.RAW.RAW_TAGSMOVIELENS.RAW.RAW_TAGS






  
