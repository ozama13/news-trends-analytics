WITH enriched AS (
    SELECT * FROM {{ ref('int_posts_enriched') }}
)

SELECT
    published_date,
    section_name,
    COUNT(*)                                        AS articles_published,
    ROUND(AVG(word_count), 0)                       AS avg_word_count,
    SUM(CASE WHEN is_long_form THEN 1 ELSE 0 END)   AS long_form_count,
    SUM(CASE WHEN is_weekend THEN 1 ELSE 0 END)     AS weekend_count,
    MAX(content_score)                              AS max_content_score
FROM enriched
GROUP BY published_date, section_name
ORDER BY published_date DESC, articles_published DESC