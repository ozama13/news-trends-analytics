WITH enriched AS (
    SELECT * FROM {{ ref('int_posts_enriched') }}
)

SELECT
    article_id,
    title,
    section_name,
    pillar_name,
    published_at,
    published_date,
    word_count,
    content_score,
    author,
    web_url,
    article_length_category,
    time_of_day,
    day_of_week
FROM enriched
WHERE is_long_form = TRUE
ORDER BY word_count DESC