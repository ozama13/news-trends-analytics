WITH enriched AS (
    SELECT * FROM {{ ref('int_posts_enriched') }}
)

SELECT
    section_name,
    day_of_week,
    time_of_day,
    COUNT(*)                        AS total_articles,
    ROUND(AVG(word_count), 0)       AS avg_word_count,
    SUM(CASE WHEN is_weekend 
        THEN 1 ELSE 0 END)          AS weekend_articles
FROM enriched
GROUP BY section_name, day_of_week, time_of_day
ORDER BY section_name, total_articles DESC