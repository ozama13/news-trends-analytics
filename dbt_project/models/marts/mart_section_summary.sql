WITH enriched AS (
    SELECT * FROM {{ ref('int_posts_enriched') }}
)

SELECT
    section_name,
    COUNT(*)                                    AS total_articles,
    ROUND(AVG(word_count), 0)                   AS avg_word_count,
    SUM(CASE WHEN is_long_form THEN 1 ELSE 0 END) AS long_form_count,
    ROUND(AVG(content_score), 2)                AS avg_content_score,
    MIN(published_date)                         AS earliest_article,
    MAX(published_date)                         AS latest_article
FROM enriched
GROUP BY section_name
ORDER BY total_articles DESC