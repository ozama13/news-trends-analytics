WITH source AS (
    SELECT * FROM {{ source('raw', 'guardian_articles') }}
),

cleaned AS (
    SELECT
        article_id,
        UPPER(TRIM(web_title))                          AS title,
        UPPER(TRIM(section_name))                       AS section_name,
        UPPER(TRIM(pillar_name))                        AS pillar_name,
        web_publication_date::TIMESTAMP                 AS published_at,
        web_url,
        CASE 
            WHEN word_count = 0 THEN NULL 
            ELSE word_count 
        END                                             AS word_count,
        UPPER(TRIM(author))                             AS author,
        ingested_at::TIMESTAMP                          AS ingested_at,
        DATE(web_publication_date)                      AS published_date,
        DAYNAME(web_publication_date)                   AS day_of_week,
        HOUR(web_publication_date)                      AS hour_posted
    FROM source
    WHERE article_id IS NOT NULL
      AND web_title IS NOT NULL
)

SELECT * FROM cleaned