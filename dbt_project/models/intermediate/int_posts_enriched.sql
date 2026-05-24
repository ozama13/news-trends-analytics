WITH staging AS (
    SELECT * FROM {{ ref('stg_guardian_articles') }}
),

enriched AS (
    SELECT
        article_id,
        title,
        section_name,
        pillar_name,
        published_at,
        published_date,
        day_of_week,
        hour_posted,
        web_url,
        word_count,
        author,
        ingested_at,

        -- Engagement score based on word count
        CASE
            WHEN word_count IS NULL THEN 'UNKNOWN'
            WHEN word_count < 300   THEN 'SHORT'
            WHEN word_count < 800   THEN 'MEDIUM'
            WHEN word_count < 1500  THEN 'LONG'
            ELSE 'IN-DEPTH'
        END                                             AS article_length_category,

        -- Is it a long form article
        CASE
            WHEN word_count >= 1500 THEN TRUE
            ELSE FALSE
        END                                             AS is_long_form,

        -- Word count score normalized
        ROUND(COALESCE(word_count, 0) / 100.0, 2)      AS content_score,

        -- Time of day category
        CASE
            WHEN hour_posted BETWEEN 6 AND 11  THEN 'MORNING'
            WHEN hour_posted BETWEEN 12 AND 17 THEN 'AFTERNOON'
            WHEN hour_posted BETWEEN 18 AND 21 THEN 'EVENING'
            ELSE 'OFF-HOURS'
        END                                             AS time_of_day,

        -- Weekend flag
        CASE
            WHEN day_of_week IN ('Sat', 'Sun') THEN TRUE
            ELSE FALSE
        END                                             AS is_weekend

    FROM staging
)

SELECT * FROM enriched