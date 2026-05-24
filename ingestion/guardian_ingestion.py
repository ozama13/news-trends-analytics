import requests
import pandas as pd
import snowflake.connector
from datetime import datetime, timezone

# Guardian API config
GUARDIAN_API_KEY = "90590c41-d153-4af1-a4c8-664b717d5c1b"
BASE_URL = "https://content.guardianapis.com/search"

# Snowflake config
SNOWFLAKE_CONFIG = {
    "user":      "ozama13",
    "password":  "vypzidgiPfym1fizru",
    "account":   "XRYSOFH-KA99414",
    "warehouse": "news_wh",
    "database":  "news_analytics",
    "schema":    "raw"
}

SECTIONS = [
    "technology",
    "business",
    "politics",
    "environment",
    "science"
]

def fetch_articles(section, page_size=100):
    params = {
        "section":       section,
        "page-size":     page_size,
        "show-fields":   "wordcount,byline",
        "show-tags":     "contributor",
        "order-by":      "newest",
        "api-key":       GUARDIAN_API_KEY
    }
    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()
    return response.json()["response"]["results"]

def parse_articles(articles, section):
    parsed = []
    for a in articles:
        fields = a.get("fields", {})
        parsed.append({
            "article_id":           a.get("id"),
            "web_title":            a.get("webTitle"),
            "section_name":         a.get("sectionName"),
            "pillar_name":          a.get("pillarName"),
            "web_publication_date": a.get("webPublicationDate"),
            "web_url":              a.get("webUrl"),
            "word_count":           int(fields.get("wordcount", 0) or 0),
            "author":               fields.get("byline"),
            "ingested_at":          datetime.now(timezone.utc).isoformat()
        })
    return parsed

def load_to_snowflake(articles):
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()

    insert_sql = """
        INSERT INTO news_analytics.raw.guardian_articles
        (article_id, web_title, section_name, pillar_name,
         web_publication_date, web_url, word_count, author, ingested_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    for a in articles:
        cursor.execute(insert_sql, (
            a["article_id"],
            a["web_title"],
            a["section_name"],
            a["pillar_name"],
            a["web_publication_date"],
            a["web_url"],
            a["word_count"],
            a["author"],
            a["ingested_at"]
        ))

    conn.commit()
    cursor.close()
    conn.close()
    print(f"Loaded {len(articles)} articles to Snowflake")

def main():
    all_articles = []
    for section in SECTIONS:
        print(f"Fetching section: {section}")
        articles = fetch_articles(section)
        parsed = parse_articles(articles, section)
        all_articles.extend(parsed)
        print(f"  {len(parsed)} articles fetched")

    print(f"\nTotal articles: {len(all_articles)}")
    load_to_snowflake(all_articles)
    print("Done!")

if __name__ == "__main__":
    main()