# FragDB - Fragrantica Fragrance Database

The most comprehensive fragrance database available — **143,400+ structured records** across six interconnected CSV files with **23 language translations**, plus **4.9M+ user-generated content rows** in Apache Parquet companion datasets covering **user reviews**, **editorial news articles**, and **community discussions**.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Records](https://img.shields.io/badge/Records-143%2C400%2B-blue)](https://fragdb.net)
[![Reviews](https://img.shields.io/badge/User%20Reviews-4.6M-red)](SPEC.md)
[![News](https://img.shields.io/badge/News%20Articles-24K-purple)](SPEC.md)
[![Languages](https://img.shields.io/badge/Languages-23-green)](DATA_DICTIONARY.md)
[![Files](https://img.shields.io/badge/CSV%20Files-6-orange)](DATA_DICTIONARY.md)
[![Parquet](https://img.shields.io/badge/Parquet%20Files-3-blueviolet)](SPEC.md)

**Keywords:** fragrance database · perfume dataset · Fragrantica · user reviews · perfume reviews · fragrance news · perfumery articles · cosmetics dataset · multilingual perfume data · scent recommendation · fragrance recommender system · perfume sentiment analysis · perfumer profiles · accord taxonomy · notes pyramid · NLP fragrance corpus · 23 languages

## Overview

FragDB provides structured data for the fragrance industry:

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| `fragrances.csv` | 130,086 | 30 | Main fragrance database |
| `brands.csv` | 7,776 | 54 | Brand profiles + translations |
| `perfumers.csv` | 2,960 | 39 | Perfumer profiles + translations |
| `notes.csv` | 2,517 | 55 | Fragrance notes + translations |
| `accords.csv` | 92 | 27 | Accords + translations |
| `translations.csv` | 34 | 25 | Vocabulary: gender & voting labels × 23 languages |

### Key Features

- **23 languages** — English + 22 translations for all labels, note names, accords, countries, statuses
- **Relational structure** — Files linked via unique IDs
- **Rich fragrance data** — Notes pyramid, accords, ratings, votes
- **Brand profiles** — Logo, country, website, parent company (country/activity translated)
- **Perfumer profiles** — Photo, status, company, education, biography (status translated)
- **Notes reference** — 2,517 notes with translations, Latin names, groups, odor profiles
- **Accords reference** — Display colors + translated names
- **Translation vocabulary** — 34 entries for gender and voting labels
- **Pipe-delimited CSV** — Easy parsing, UTF-8 encoded

## Preview

### Fragrances

<p align="center">
  <img src="assets/table_view.webp" alt="FragDB Fragrances Table" width="45%">
  &nbsp;&nbsp;
  <img src="assets/detail_view.webp" alt="FragDB Fragrance Detail" width="45%">
</p>

### Brands & Perfumers

<p align="center">
  <img src="assets/brands_table.webp" alt="FragDB Brands Table" width="45%">
  &nbsp;&nbsp;
  <img src="assets/perfumers_table.webp" alt="FragDB Perfumers Table" width="45%">
</p>

### Notes

<p align="center">
  <img src="assets/notes_table.webp" alt="FragDB Notes Table" width="45%">
  &nbsp;&nbsp;
  <img src="assets/notes_detail.webp" alt="FragDB Note Detail" width="45%">
</p>

## Quick Start

### Python

```python
import pandas as pd

# Load all files
fragrances = pd.read_csv('fragrances.csv', sep='|', encoding='utf-8')
brands = pd.read_csv('brands.csv', sep='|', encoding='utf-8')
notes = pd.read_csv('notes.csv', sep='|', encoding='utf-8')
translations = pd.read_csv('translations.csv', sep='|', encoding='utf-8')

# Join fragrances with brands
fragrances['brand_id'] = fragrances['brand'].str.split(';').str[1]
df = fragrances.merge(brands, left_on='brand_id', right_on='id', suffixes=('', '_brand'))

# Translate gender to any language
trans = translations.set_index('id')
df['gender_ru'] = df['gender'].map(lambda x: trans.loc[x, 'ru'] if x in trans.index else x)

# Brand country in Japanese
print(df[['name', 'name_brand', 'country_ja', 'gender_ru']].head())
```

### JavaScript

```javascript
const { parse } = require('csv-parse/sync');
const fs = require('fs');

// Load files
const fragrances = parse(fs.readFileSync('fragrances.csv', 'utf-8'), { columns: true, delimiter: '|' });
const brands = parse(fs.readFileSync('brands.csv', 'utf-8'), { columns: true, delimiter: '|' });
const translations = parse(fs.readFileSync('translations.csv', 'utf-8'), { columns: true, delimiter: '|' });

// Build lookup maps
const brandsMap = new Map(brands.map(b => [b.id, b]));
const transMap = new Map(translations.map(t => [t.id, t]));

// Get fragrance with translated fields
const frag = fragrances[0];
const [brandName, brandId] = frag.brand.split(';');
const brand = brandsMap.get(brandId);
const genderRu = transMap.get(frag.gender)?.ru || frag.gender;

console.log(`${frag.name} by ${brandName} (${brand?.country_ru}), ${genderRu}`);
```

### SQL (PostgreSQL)

```sql
-- Import
COPY fragrances FROM 'fragrances.csv' DELIMITER '|' CSV HEADER ENCODING 'UTF8';
COPY brands FROM 'brands.csv' DELIMITER '|' CSV HEADER ENCODING 'UTF8';
COPY translations FROM 'translations.csv' DELIMITER '|' CSV HEADER ENCODING 'UTF8';

-- Join and translate gender to Russian
SELECT f.name, b.name AS brand, b.country_ru, t.ru AS gender_ru
FROM fragrances f
JOIN brands b ON SPLIT_PART(f.brand, ';', 2) = b.id
JOIN translations t ON f.gender = t.id;
```

See [DATA_DICTIONARY.md](DATA_DICTIONARY.md) for complete field documentation.

## Companion Parquet Datasets — User Reviews, News, and Community Comments

FragDB ships with **three Apache Parquet datasets** containing **4.9 million rows** of user-generated content and editorial coverage — the largest publicly-organized corpus of fragrance reviews and perfumery journalism. Use them for NLP, sentiment analysis, recommendation systems, market research, or training language models on fragrance-specific text.

### `comments.parquet` — 4.6 Million User Reviews in 23 Languages

The world's largest collection of structured fragrance reviews. Every entry includes the perfume ID (joinable with `fragrances.csv`), author username, posting date, full review text, avatar URL, and language code.

- **4,643,851 user reviews** spanning every major perfume on Fragrantica
- **23 languages** — English (1.69M reviews), Russian, Portuguese, Spanish, Korean, Turkish, Japanese, Polish, Italian, Hungarian, Serbian, Swedish, German, Hebrew, Ukrainian, French, Arabic, Greek, Czech, Chinese, Romanian, Mongolian, Dutch
- **Coverage:** 70.6% of all fragrances in the database have at least one review (93,305 of 132,160 PIDs)
- **Deterministic global primary key** — stable comment IDs survive re-scrapes
- **Zero duplicate rows**, **zero foreign key orphans** against `fragrances.csv.pid`
- **Independent UGC per language** — each language is genuine localized content, not machine translation
- **8 fields:** `pid`, `lang`, `comment_id`, `author`, `date`, `text`, `avatar_url`, `gradient_class`
- **PyArrow large_string format** — combined corpus exceeds 32-bit string offset limit

**Use cases:** sentiment analysis · review classification · recommendation systems · perfume similarity from text · language detection benchmark · multilingual NLP training corpus · fragrance market research · author network analysis · trend detection by language

### `news.parquet` — 24,440 Editorial Articles (2008–2026)

Two decades of professional fragrance journalism from Fragrantica's editorial team. Every article includes title, author, full text (plain + HTML), category, related perfumes/brands/perfumers, publication date, and main image. Foreign keys to fragrances, brands, and perfumers make this a powerful resource for content-based recommendation and knowledge graph construction.

- **24,440 editorial articles** from 2008 to 2026 — the complete public archive
- **30+ categories** — top: New Fragrances (34.9%), Fragrance Reviews (22.8%), Niche Perfumery (10.4%), Designer Brands, Interviews, History, Industry News, Niche Houses, and more
- **Bilingual storage** — `text` (plain) for NLP / search, `text_html` (preserved markup) for rich display
- **Linked entities** — `related_pids[]`, `related_brands[]`, `related_perfumers[]` as JSON arrays
- **0% orphans** over 119,662 PID references — clean foreign keys
- **Modern + archived** — 63.1% archived legacy articles, 36.9% modern fully-dated articles
- **16 fields:** `nid`, `title`, `category`, `author`, `url`, `is_archived`, `date_unix`, `description`, `text`, `text_html`, `main_image`, `article_images`, `related_pids`, `related_brands`, `related_perfumers`, `comments_count`
- **List fields stored as JSON-encoded strings** — never null (empty = `"[]"`)

**Use cases:** content recommendation · article search engine · perfume knowledge graph · trend analysis · author influence study · category classification · entity linking · timeline analysis · industry research · niche perfumery research · fragrance journalism corpus

### `news_comments.parquet` — 263,798 Threaded Community Comments

Community discussions attached to editorial articles, with threading support for replies. Joinable with `news.parquet` via `nid`.

- **263,798 threaded comments** across **21,820 articles** (89.3% of news articles have at least one comment)
- **4.9% reply rate** — threaded conversations with reply detection (`is_reply` flag)
- **100% populated timestamps** — `date_unix` parsed for every comment
- **9 fields:** `nid`, `comment_id`, `is_reply`, `author`, `date`, `date_unix`, `text`, `avatar_url`, `gradient`
- **Zero foreign key orphans** against `news.parquet.nid`

**Use cases:** community engagement analysis · threaded discussion mining · reply network construction · comment sentiment · author activity profiles · temporal analysis of community responses

### Tier Availability

The parquet datasets ship with **all paid tiers except the $200 Core**:

| Tier | CSV Core | Parquet Datasets |
|------|----------|------------------|
| **$200 One-Time Core** | ✓ | ✗ |
| **$400 One-Time Full Database** | ✓ | ✓ |
| **Annual Subscription** | ✓ | ✓ (always latest) |
| **Lifetime Access** | ✓ | ✓ (always latest) |

See https://fragdb.net/#pricing for complete tier comparison.

### Free Parquet Samples Included

This repository includes **free parquet preview samples** in `samples/`:

- [`comments_sample.parquet`](samples/comments_sample.parquet) — 25 user reviews (8 fields)
- [`news_sample.parquet`](samples/news_sample.parquet) — 20 editorial articles (16 fields)
- [`news_comments_sample.parquet`](samples/news_comments_sample.parquet) — 20 threaded news comments (9 fields)
- [`SPEC.md`](SPEC.md) — full field-by-field schema documentation (Apache Parquet)

### Quick Start — Reading Parquet Datasets

```python
import pyarrow.parquet as pq
import pandas as pd

# Read user reviews
reviews = pq.read_table('comments.parquet').to_pandas()
print(reviews.head())
print(f"Total reviews: {len(reviews):,}")
print(f"Languages: {reviews['lang'].nunique()}")

# Join with CSV fragrance metadata
fragrances = pd.read_csv('fragrances.csv', sep='|')
reviews_with_frag = reviews.merge(fragrances, on='pid', how='left')

# Read news articles
import json
news = pq.read_table('news.parquet').to_pandas()
# Parse JSON-encoded list fields
news['related_pids_list'] = news['related_pids'].apply(json.loads)
news['related_brands_list'] = news['related_brands'].apply(json.loads)
print(news[['nid', 'title', 'category', 'date_unix']].head())

# Read news comments and join with articles
news_comments = pq.read_table('news_comments.parquet').to_pandas()
discussion = news_comments.merge(news[['nid', 'title']], on='nid')
print(discussion[['nid', 'title', 'author', 'text']].head())
```

Full schema, field types, and audit statistics are documented in [`SPEC.md`](SPEC.md).

## What's New in v5.3

- **23 languages** — all labels, note names, accords, countries, statuses translated
- **translations.csv** — new vocabulary file for gender values and voting labels
- **Compact notes pyramid** — `note_id,opacity,weight` (name/icon via notes.csv JOIN)
- **2,517 notes** — each name variant (Rose, Damask Rose, Turkish Rose) has its own ID
- **Perfumer transliterations expanded to 6 languages** — added Chinese, Korean, Arabic (was: Russian, Ukrainian, Japanese)
- **Gender & voting fields** use translation IDs instead of English text

See [DATA_DICTIONARY.md](DATA_DICTIONARY.md) for complete field documentation with parsing examples.

## Sample Data

The free sample includes **10 records per file** across all six CSV files, plus **parquet samples** and `SPEC.md`:

### CSV samples
| File | Records | Description |
|------|---------|-------------|
| [fragrances.csv](samples/fragrances.csv) | 10 | Iconic fragrances (30 fields) |
| [brands.csv](samples/brands.csv) | 10 | Brand profiles (54 fields, 22 lang) |
| [perfumers.csv](samples/perfumers.csv) | 10 | Perfumer profiles (39 fields, 22 lang) |
| [notes.csv](samples/notes.csv) | 10 | Fragrance notes (55 fields, 22 lang) |
| [accords.csv](samples/accords.csv) | 10 | Accords with colors (27 fields, 22 lang) |
| [translations.csv](samples/translations.csv) | 34 | Gender & voting vocabulary (full, 25 fields) |

### Parquet samples (Full tier preview)
| File | Records | Description |
|------|---------|-------------|
| [comments_sample.parquet](samples/comments_sample.parquet) | 25 | User reviews preview (8 fields) |
| [news_sample.parquet](samples/news_sample.parquet) | 20 | Editorial articles preview (16 fields) |
| [news_comments_sample.parquet](samples/news_comments_sample.parquet) | 20 | News comments preview (9 fields) |
| [SPEC.md](SPEC.md) | — | Parquet schema documentation |

Preview: [SAMPLE_PREVIEW.md](SAMPLE_PREVIEW.md)

## Documentation

- [DATA_DICTIONARY.md](DATA_DICTIONARY.md) — Complete field documentation with parsing examples
- [CHANGELOG.md](CHANGELOG.md) — Version history

## Use Cases

### CSV Core (all tiers)
- **E-commerce** — Enrich product listings with detailed fragrance data, notes, accords
- **Mobile Apps** — Build fragrance collection managers, scent discovery apps, perfume catalog apps
- **Data Analysis** — Analyze fragrance industry trends by brand, country, perfumer, year
- **Recommendations** — Content-based or collaborative filtering systems using accord/note vectors
- **Content Creation** — Power blogs, videos, fragrance reviews with accurate data
- **Multilingual UIs** — Localized perfume catalogs in 23 languages out of the box
- **Knowledge Graphs** — Brand → Perfumer → Fragrance → Notes → Accords graph construction
- **Market Research** — Country-of-origin analysis, parent company portfolios, perfumer productivity stats

### Parquet Datasets ($400+ tiers)
- **NLP & Sentiment Analysis** — Train models on 4.6M multilingual fragrance reviews
- **Recommender Systems** — Hybrid models combining CSV structure with review text similarity
- **Language Models** — Domain-specific corpus for fragrance/perfumery LLM fine-tuning
- **Review Classification** — Identify positive/negative reviews, fake review detection
- **Trend Detection** — News article timeline analysis, emerging fragrance trends
- **Author Networks** — Identify influential reviewers, perfumery journalists, community leaders
- **Content-Based Discovery** — "Articles about this perfume" — JOIN news.related_pids with fragrances.pid
- **Community Analytics** — Reply networks, engagement metrics on editorial content
- **Cross-Language Studies** — Compare review sentiment across 23 languages for the same fragrance
- **Search Engines** — Full-text search across reviews, articles, and structured metadata
- **Entity Resolution** — Match journalist's `related_brands[]` mentions with `brands.csv` IDs
- **Knowledge Extraction** — Mine 24K editorial articles for perfume facts, launch dates, perfumer interviews

## Full Database

The free sample contains 10 records per file. The full FragDB database includes:

| Feature | Free Sample | Full Database |
|---------|-------------|---------------|
| Fragrances | 10 | 130,086 |
| Brands | 10 | 7,776 |
| Perfumers | 10 | 2,960 |
| Notes | 10 | 2,517 |
| Accords | 10 | 92 |
| Translations | 34 (full) | 34 |
| Languages | 23 | 23 |
| Total Records | 84 | 143,465 |
| Updates | None | Regular |
| Commercial Use | Yes (sample) | Yes (licensed) |

**[Purchase at fragdb.net →](https://fragdb.net)**

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- Bug fixes for code examples
- New language examples
- Documentation improvements
- Use case additions

## License

- **Sample Data & Code**: [MIT License](LICENSE.md)
- **Full Database**: Commercial license (see [fragdb.net](https://fragdb.net))

## Links

- **Website**: [fragdb.net](https://fragdb.net)
- **Kaggle**: [kaggle.com/datasets/eriklindqvist/fragdb-fragrance-database](https://www.kaggle.com/datasets/eriklindqvist/fragdb-fragrance-database)
- **Hugging Face**: [huggingface.co/datasets/FragDBnet/fragrance-database](https://huggingface.co/datasets/FragDBnet/fragrance-database)
- **Documentation**: [DATA_DICTIONARY.md](DATA_DICTIONARY.md)
- **Issues**: [GitHub Issues](../../issues)

---

Built with data passion by the FragDB team.
