# Fragrantica News & Comments Datasets — Technical Specification

**Snapshot date:** 2026-05-05
**Source:** `fragrantica.com` and 22 localized domains (`fragrantica.de`, `fragrantica.ru`, etc.)
**Format:** Apache Parquet (Zstandard compression)
**Total combined size:** ~1.36 GB on disk

This document specifies three datasets that complement the existing
Fragrantica perfume database (`merged_database`, `brands_database_v2`,
`perfumers_database_v2`, `notes_database_v2` — already documented and sold
separately):

1. **`comments.parquet`** — user reviews on individual perfumes
2. **`news.parquet`** — editorial articles published on Fragrantica
3. **`news_comments.parquet`** — user comments under those articles

The cross-dataset relationships in §5 explain how to join these with the
existing perfume/brand/perfumer DBs via primary keys.

---

## 1. Overview

| Dataset | Rows | Compressed Size | Distinct entities |
|---|---:|---:|---:|
| `comments.parquet` | 4,643,851 | 1.23 GB | 93,305 perfumes, 23 languages |
| `news.parquet` | 24,440 articles | 101 MB | NID 1..25000 |
| `news_comments.parquet` | 263,798 | 33 MB | 21,820 articles with comments |

All three datasets share the same identifier conventions used by the
existing perfume/brand/perfumer databases:

- **PID** (`int32`) — unique perfume identifier; matches `merged_database.PID`.
- **NID** (`int32`) — unique news article identifier (1..25000 range).
- **lang** (`string`) — ISO 639-1 language code identifying which Fragrantica
  domain the content was sourced from. Each domain hosts independent
  user-generated content (reviews are not translations of one another).

---

## 2. Dataset 1: `comments.parquet`

User-written reviews of individual perfumes, scraped across 23 localized
Fragrantica domains. Each comment is a unique user review, not a translation
or syndication.

### 2.1 Schema (8 fields)

| # | Field | Type | NULL? | Description |
|---:|---|---|---|---|
| 1 | `pid` | `int32` | NO | Foreign key → `merged_database.PID`. Identifies the perfume being reviewed. |
| 2 | `lang` | `string` | NO | Domain language (`en`, `ru`, `de`, …). 23 distinct values. |
| 3 | `comment_id` | `string` | NO | Globally unique deterministic ID, format `{pid}_{lang}_{12hex}` where `12hex` is the first 12 hexadecimal characters of `sha1(author + "|" + date + "|" + text)`. Stable across re-scrapes. |
| 4 | `author` | `string` | NO | Username as displayed on Fragrantica. May contain Unicode (e.g. `Сергей`, `José`). |
| 5 | `date` | `string` | NO | Date published as it appears on the page. Most rows: `MM/DD/YY HH:MM` (e.g., `04/11/26 10:05`). Always present. |
| 6 | `text` | `large_string` (64-bit offsets) | NO | Review body. UTF-8, no HTML tags, paragraph breaks via `\n`. May contain emoji. Length range observed: 1 char (emoji-only) to ~120 KB. |
| 7 | `avatar_url` | `string` | NO | Full URL to the user's avatar image hosted on Fragrantica's CDN. Verified ~100% reachable. |
| 8 | `gradient_class` | `string` | NO | Fragrantica's CSS class for the user's color badge (e.g., `tw-gradient-rose`). 7 distinct values observed (`tw-gradient-amber`/`emerald`/`orange`/`rose`/`sky`/`teal`/`violet`). Useful for UI consistency if displaying. |

### 2.2 Volumetrics

- **Total rows:** 4,643,851
- **Distinct PIDs covered:** 93,305 (70.6% of the 132,160 perfumes in `merged_database`; remaining 38,855 perfumes have zero reviews — verified against Fragrantica's `reviews_count` field)
- **PID range:** 1 — 130,121
- **Languages:** 23 (full list in §2.3)

### 2.3 Language distribution

| Lang | Code | Comments | Distinct PIDs |
|---|---|---:|---:|
| English | `en` | 1,690,055 | 78,715 (60% of perfumes) |
| Russian | `ru` | 889,893 | 52,650 |
| Portuguese (Brazilian) | `pt` | 247,511 | 21,258 |
| Spanish | `es` | 226,451 | 26,586 |
| Korean | `ko` | 214,674 | 11,696 |
| Turkish | `tr` | 191,945 | 11,722 |
| Japanese | `ja` | 186,836 | 10,767 |
| Polish | `pl` | 141,242 | 25,350 |
| Italian | `it` | 115,972 | 22,100 |
| Hungarian | `hu` | 109,204 | 11,565 |
| Serbian | `sr` | 108,945 | 15,048 |
| Swedish | `sv` | 107,666 | 11,155 |
| German | `de` | 100,218 | 15,505 |
| Hebrew | `he` | 81,981 | 10,165 |
| Ukrainian | `uk` | 50,203 | 15,917 |
| French | `fr` | 42,256 | 13,379 |
| Arabic | `ar` | 33,077 | 9,071 |
| Greek | `el` | 28,208 | 8,512 |
| Czech | `cs` | 24,269 | 3,424 |
| Chinese (Simplified) | `zh` | 15,843 | 4,466 |
| Romanian | `ro` | 13,906 | 6,451 |
| Mongolian | `mn` | 12,100 | 2,056 |
| Dutch | `nl` | 11,396 | 5,045 |

Each `lang` represents an independent set of user reviews from the
corresponding national Fragrantica domain. A user reviewing the same
perfume on `fragrantica.com` (en) and `fragrantica.ru` (ru) would write
two distinct reviews; both are included.

### 2.4 ID generation

`comment_id` is content-derived (sha1-based), giving three properties:
- **Globally unique** across all 4.6M rows (verified post-rewrite, 0 collisions).
- **Stable across re-scrapes**: re-fetching the same comment yields the same
  ID. Useful for incremental updates and joining with downstream tables.
- **Idempotent dedup key**: `(nid, comment_id)` and `comment_id` alone are
  both safe primary keys.

---

## 3. Dataset 2: `news.parquet`

Editorial articles from `fragrantica.com/news/` (English-only). Covers the
entire archive 2008-2026 (NID 1..25000), including both archived legacy
articles and modern editorial content.

### 3.1 Schema (16 fields)

| # | Field | Type | NULL? | Description |
|---:|---|---|---|---|
| 1 | `nid` | `int32` | NO | News article ID. Range 1..25000. |
| 2 | `title` | `string` | NO | Article title. Plain text, HTML entities decoded. |
| 3 | `category` | `string` | NO | Editorial category (e.g., `New Fragrances`, `Fragrance Reviews`, `Interviews`). 30+ distinct values. Top 10 in §3.4. |
| 4 | `author` | `string` | YES | Comma-separated list of author names (multi-author articles common). |
| 5 | `description` | `string` | YES | Short summary from `<meta property="og:description">`. Plain text. |
| 6 | `text` | `string` | NO | Full article body. Plain text, paragraph breaks via `\n`. Footer/byline blocks stripped. UTF-8. |
| 7 | `text_html` | `string` | NO | Article body **with original HTML preserved** — `<p>`, `<a>`, `<img>`, embedded videos. Useful for rendering or DOM-aware downstream processing. |
| 8 | `main_image` | `string` | YES | URL to the article's primary image (Fragrantica CDN). Verified reachable. |
| 9 | `article_images` | `string` | NO | **JSON-encoded array** of all image URLs in the article body. Use `json.loads(field)` → `list[str]`. Empty array `'[]'` if none. |
| 10 | `url` | `string` | NO | Canonical article URL (e.g., `https://www.fragrantica.com/news/x-12345.html`). |
| 11 | `is_archived` | `bool` | NO | `True` if article is in Fragrantica's legacy/archived corpus (older HTML template, often missing publication date — see §3.5). |
| 12 | `related_pids` | `string` | NO | **JSON-encoded array** of PIDs (as decimal strings) referenced in the article. Foreign key → `merged_database.PID`. 0% orphan rate (FK-validated). |
| 13 | `related_brands` | `string` | NO | **JSON-encoded array** of brand names. Informational metadata; see §5.4 for canonical resolution. |
| 14 | `related_perfumers` | `string` | NO | **JSON-encoded array** of perfumer names with diacritics preserved (e.g., `François Demachy`, `Carlos Benaïm`). Informational; see §5.5. |
| 15 | `comments_count` | `int32` | NO | Count of comments in `news_comments.parquet` matching this NID. |
| 16 | `date_unix` | `int64` | NO | Publication time as Unix timestamp (seconds since epoch). `0` indicates the date is not extractable from the source HTML — see §3.5. |

### 3.2 Volumetrics

- **Total rows:** 24,440 articles
- **NID range:** 1 — 25,000 (560 NIDs missing — Fragrantica returns HTTP 301 redirect for these — represents truly deleted articles)
- **Archived:** 15,427 / 24,440 (63.1%)
- **Non-archived:** 9,013 / 24,440 (36.9%)
- **With publication date (`date_unix > 0`):** 13,687 (56.0%)

### 3.3 List-fields format note

Four fields hold lists: `article_images`, `related_pids`, `related_brands`,
`related_perfumers`. **All four are stored as JSON-encoded strings** for
consistency. Use:

```python
import json
images = json.loads(row['article_images'])  # → list[str]
```

`related_pids` contains PID values as decimal strings (e.g., `'704'`, not
the int `704`). Cast as needed when joining.

### 3.4 Top categories

| Category | Articles | % |
|---|---:|---:|
| New Fragrances | 8,534 | 34.9% |
| Fragrance Reviews | 5,583 | 22.8% |
| Niche Perfumery | 2,537 | 10.4% |
| Art Books Events | 1,570 | 6.4% |
| Columns | 1,346 | 5.5% |
| Fragrant Horoscope | 851 | 3.5% |
| Fragrance News | 760 | 3.1% |
| Interviews | 682 | 2.8% |
| Vintages | 437 | 1.8% |
| Raw Materials | 384 | 1.6% |

Remaining 1,756 articles span 33 smaller categories.

### 3.5 Date coverage

`date_unix == 0` for 10,753 articles (44%). Distribution by NID range:

| NID range | Articles | with date | % | archived % |
|---|---:|---:|---:|---:|
| 1 — 5,000 | 4,888 | 2 | 0.0% | 100% |
| 5,001 — 10,000 | 4,799 | 0 | 0.0% | 100% |
| 10,001 — 15,000 | 4,890 | 3,822 | 78.2% | 100% |
| 15,001 — 20,000 | 4,900 | 4,900 | 100% | 17.3% |
| 20,001 — 25,000 | 4,963 | 4,963 | 100% | 0% |

The 10,753 articles without date come entirely from the archived legacy
template: 9,685 in NIDs 1–10,000 (effectively all of them) and 1,068 in
NIDs 10,001–15,000 (the remaining 22% of that range — the other 78% have
recoverable visible-text dates). Fragrantica's old archived HTML does not
embed any date marker (no `<time>`, no `<meta>`, no visible date string)
for these. This is an upstream HTML limitation, not a parser issue.
**For all non-archived articles (9,013 of them), `date_unix` is 100%
populated.**

---

## 4. Dataset 3: `news_comments.parquet`

User comments under news articles. Pure UGC; same comment-card schema
Fragrantica uses on perfume pages.

### 4.1 Schema (9 fields)

| # | Field | Type | NULL? | Description |
|---:|---|---|---|---|
| 1 | `nid` | `int32` | NO | Foreign key → `news.parquet.nid` (0% orphan rate). |
| 2 | `comment_id` | `string` | NO | Comment ID as Fragrantica assigns it (page-anchor format). Globally unique within parquet. |
| 3 | `author` | `string` | NO | Commenter username. |
| 4 | `date` | `string` | NO | Date as displayed on page (e.g., `04/11/26 10:05`). |
| 5 | `date_unix` | `int64` | NO | Parsed Unix timestamp. **100% populated** (all rows have `date_unix > 0`). |
| 6 | `text` | `string` | NO | Comment body, plain text. |
| 7 | `avatar_url` | `string` | NO | Full URL to author avatar (Fragrantica CDN). |
| 8 | `gradient` | `string` | NO | CSS class for color badge (same scheme as `comments.parquet.gradient_class`). |
| 9 | `is_reply` | `bool` | NO | `True` if this comment is a reply to another comment (threaded discussion); `False` for root comments. 4.9% of rows are replies (12,898 / 263,798). |

### 4.2 Volumetrics

- **Total rows:** 263,798
- **Distinct NIDs:** 21,820 (89.3% of articles have at least one comment)
- **Replies:** 12,898 (4.9%)
- **Average comments per article (in articles with comments):** 12.1

---

## 5. Cross-dataset relationships

This section is the load-bearing piece for buyers integrating with the
existing perfume/brand/perfumer DBs.

### 5.1 Diagram

```
┌────────────────────────────────────────────────────────┐
│   merged_database.csv  (existing, 132,160 perfumes)   │
│   ─────────────────────                                │
│   PID   ←──────────────────────┐                       │
│   Brand                        │                       │
│   Name                         │                       │
│   noses_f  (perfumers)         │                       │
│   ...30 fields total           │                       │
└────────────────────────────────┼───────────────────────┘
                                 │
                ┌────────────────┴───────────────┐
                │                                │
                ▼                                ▼
   ┌──────────────────────┐         ┌──────────────────────┐
   │ comments.parquet     │         │ news.parquet         │
   │ ──────────────────── │         │ ──────────────────── │
   │ pid    ─────────────►│         │ related_pids ───────►│
   │ lang   (23 langs)    │         │ related_brands       │
   │ comment_id (sha1)    │         │ related_perfumers    │
   │ author/date/text     │         │ nid ◄────┐           │
   │ +avatar/gradient     │         │ ...16 fields total   │
   └──────────────────────┘         └──────────┼───────────┘
                                               │
                                               │
                                    ┌──────────┴───────────┐
                                    │ news_comments.parquet│
                                    │ ──────────────────── │
                                    │ nid ─────────────────│ FK → news.nid
                                    │ comment_id           │
                                    │ author/date/text     │
                                    │ is_reply             │
                                    └──────────────────────┘
```

### 5.2 Linking comments to perfumes (PID)

Foreign key: **`comments.pid → merged_database.PID`** — verified 0% orphan rate.

```sql
-- All English reviews for the perfume "Mugler Angel" (PID 704):
SELECT c.author, c.date, c.text
FROM read_parquet('comments.parquet') c
JOIN read_csv('merged_database.csv', delim='⏸') m ON c.pid = m.PID
WHERE m.Brand = 'Mugler' AND m.Name = 'Angel' AND c.lang = 'en'
ORDER BY c.date DESC LIMIT 100;
```

```python
import pyarrow.parquet as pq
import pyarrow.compute as pc

c = pq.read_table('comments.parquet')
angel_reviews = c.filter(pc.and_(pc.equal(c['pid'], 704),
                                  pc.equal(c['lang'], 'en')))
```

### 5.3 Linking news to perfumes (related_pids)

Foreign key: **`news.related_pids → merged_database.PID`** — JSON-array
field, 0% orphan rate over 119,662 references.

```sql
-- All news mentioning Aventus (PID 9828):
SELECT nid, title, category, date_unix
FROM read_parquet('news.parquet')
WHERE list_contains(json_extract(related_pids, '$'), '9828');
```

```python
import json
n = pq.read_table('news.parquet')
mentions_aventus = []
for i, rp in enumerate(n.column('related_pids').to_pylist()):
    if rp and '9828' in json.loads(rp):
        mentions_aventus.append(i)
```

### 5.4 Linking news to brands

`news.related_brands` is a **JSON array of brand-name strings** (informational).

**Authoritative brand resolution** for any news article uses the PID:
```
news.related_pids → merged_database.PID → merged_database.Brand
```

The `related_brands` field is provided as supplementary metadata. Approx.
12% of strings in `related_brands` will not match `brands_database_v2.name`
exactly because Fragrantica has renamed some brands over time
(e.g., `Christian Dior` → `Dior`, `Annick Goutal` → `Goutal`,
`Paco Rabanne` → `Rabanne`). The original captured name is preserved.

For canonical brand lookup, always join via `related_pids`:

```sql
SELECT DISTINCT m.Brand
FROM read_parquet('news.parquet') n
JOIN read_csv('merged_database.csv', delim='⏸') m
  ON list_contains(json_extract(n.related_pids, '$'), CAST(m.PID AS VARCHAR))
WHERE n.nid = 17644;
```

### 5.5 Linking news to perfumers

Same pattern as brands. `news.related_perfumers` is a **JSON array of perfumer-name
strings** with diacritics preserved (e.g., `François Demachy`, `Carlos Benaïm`,
`Cécile Zarokian` — verified canonical post-fix).

**Authoritative perfumer resolution** uses PID:
```
news.related_pids → merged_database.PID → merged_database.noses_f
```

`merged_database.noses_f` contains the full list of perfumers per perfume in
the project's standard format. Approximately 11% of `related_perfumers`
strings will not exactly match `perfumers_database_v2.name` due to the
upstream perfumer DB not yet covering all names mentioned in news (e.g.,
`Jean Claude Ellena` ×191 mentions). Use the PID-join for guaranteed
matches.

### 5.6 Linking news_comments to articles (NID)

Foreign key: **`news_comments.nid → news.nid`** — 0% orphan rate.

```sql
-- All comments under article NID 17644:
SELECT author, date, text, is_reply
FROM read_parquet('news_comments.parquet')
WHERE nid = 17644
ORDER BY date_unix ASC;
```

### 5.7 Combined query examples

**Q1.** All news articles + their root comments mentioning Creed Aventus
(PID 9828) in 2024:

```sql
SELECT n.nid, n.title, n.date_unix, nc.author, nc.text
FROM read_parquet('news.parquet') n
LEFT JOIN read_parquet('news_comments.parquet') nc ON n.nid = nc.nid
WHERE list_contains(json_extract(n.related_pids, '$'), '9828')
  AND n.date_unix BETWEEN 1704067200 AND 1735689599  -- 2024
  AND nc.is_reply = false
ORDER BY n.date_unix DESC, nc.date_unix ASC;
```

**Q2.** Top-10 most-reviewed perfumes by language:

```sql
SELECT lang, pid, COUNT(*) AS review_count
FROM read_parquet('comments.parquet')
GROUP BY lang, pid
QUALIFY ROW_NUMBER() OVER (PARTITION BY lang ORDER BY COUNT(*) DESC) <= 10;
```

**Q3.** Sentiment correlation between news articles and reviews — pairs of
(news article, perfume reviewed in same time window):

```sql
SELECT n.nid, n.title, m.Brand, m.Name, COUNT(c.comment_id) AS reviews_in_30d
FROM read_parquet('news.parquet') n
JOIN read_csv('merged_database.csv', delim='⏸') m
  ON list_contains(json_extract(n.related_pids, '$'), CAST(m.PID AS VARCHAR))
JOIN read_parquet('comments.parquet') c
  ON c.pid = m.PID
WHERE n.date_unix > 0
  AND c.date_unix BETWEEN n.date_unix AND n.date_unix + 2592000  -- 30 days
GROUP BY n.nid, n.title, m.Brand, m.Name;
```

---

## 6. Format specification

### 6.1 Storage

- **Container:** Apache Parquet 2.x
- **Compression:** Zstandard (`zstd`)
- **Row groups:**
  - `comments.parquet` — 5 row groups
  - `news.parquet` — 1 row group
  - `news_comments.parquet` — 1 row group

### 6.2 String types

PyArrow uses two string types:
- `string` — backed by 32-bit offsets (per-array limit ~2 GB total).
- `large_string` — backed by 64-bit offsets (no practical size limit).

`comments.parquet` uses `large_string` for the `text` column (because the
combined corpus of 4.6M reviews exceeds the 32-bit offset limit). All
other string columns in all three datasets use `string`. Pandas
automatically converts both to its native `object` dtype on load — buyers
generally do not need to distinguish between the two types unless writing
custom Arrow code.

Exact field-level types are listed in the schema tables of §2.1, §3.1, §4.1.

### 6.3 Encoding

- **Character encoding:** UTF-8 throughout.
- **Normalization:** NFC where applicable; original Unicode codepoints
  preserved (including emoji).
- **Newlines:** `\n` only (Unix-style). No `\r`.
- **HTML entities:** decoded (no `&amp;`, `&lt;`, etc. in text fields).
- **Replacement chars (U+FFFD):** zero — rare upstream-broken bytes were
  stripped, with the surrounding text preserved.

### 6.4 List fields (news.parquet)

Four columns store JSON-encoded arrays-as-strings:
- `article_images`: `list[str]` of image URLs
- `related_pids`: `list[str]` of decimal-string PIDs
- `related_brands`: `list[str]` of brand names
- `related_perfumers`: `list[str]` of perfumer names

Empty list is stored as the literal string `'[]'` (not NULL, not empty
string). This makes parsing branchless:

```python
items = json.loads(row[field])  # always returns a list
```

---

## 7. Data quality

The datasets passed a multi-track validation audit (full report:
`reports/data_quality/POST_FIX_VALIDATION.md`). Summary:

| Check | Result |
|---|:---:|
| Duplicate rows by primary key (all 3 datasets) | 0 |
| FK integrity (`comments.pid → PID`) | 0 orphans |
| FK integrity (`news.related_pids → PID`) | 0 orphans (over 119,662 refs) |
| FK integrity (`news_comments.nid → nid`) | 0 orphans |
| `comment_id` global uniqueness (`comments.parquet`) | 0 collisions over 4.6M rows |
| HTML/CSS pollution in text fields | 0 |
| Cloudflare challenge pages in data | 0 |
| Mojibake / replacement char (U+FFFD) | 0 |
| Language attribution accuracy (langdetect on sample) | >95% per language |
| `news_comments.date_unix > 0` populated | 100% |
| `news.date_unix > 0` populated (non-archived) | 100% |

### 7.1 Provenance

Data scraped via headless browser fingerprinting (chrome120 impersonation
through curl_cffi) over a residential proxy network. Each page was
individually fetched, parsed by a custom HTML parser, and post-processed
through a content sanitization pipeline. Re-scrapes are idempotent thanks
to deterministic comment IDs (§2.4).

---

## 8. Known limitations (transparent disclosure)

1. **Archived news articles without dates (10,753 / 24,440 = 44%).**
   Fragrantica's archived HTML template does not embed any date marker
   (`<time>`, meta tag, or visible string). For these articles, `date_unix`
   is `0`. The no-date subset is concentrated in NIDs 1–15,000: 9,685 of
   9,687 archived articles in NIDs 1–10,000 and 1,068 of 4,890 in NIDs
   10,001–15,000. (850 archived articles in NIDs 15,001–20,000 do have
   dates.) **All non-archived articles (9,013 of them) have 100% date
   coverage.**

2. **`related_brands` matching gap (~12%).** Fragrantica has renamed
   ~50 brands over the years (e.g., `Christian Dior → Dior`); the captured
   name in news may be the older form, while `brands_database_v2.csv`
   carries only the canonical (post-rename) name. Use `related_pids` for
   authoritative brand resolution (§5.4).

3. **`related_perfumers` matching gap (~11%).** Some perfumer names
   referenced in news (e.g., `Jean Claude Ellena` ×191) are not yet in the
   companion `perfumers_database_v2.csv`. The names in news are
   diacritic-correct; the gap is in the reference DB coverage. Use
   `related_pids → merged_database.noses_f` for authoritative resolution
   (§5.5).

4. **Cross-language mirrored short comments (~0.014%).** Approximately
   650 short, identical-text comments appear in multiple languages
   (e.g., a "5/10" rating posted by the same author on multiple subdomains).
   These are real (Fragrantica's display behavior), not parser duplicates.

5. **Comments PID coverage gap.** 38,855 perfumes (29%) have zero comments
   in any language. Verified against Fragrantica's `reviews_count` field:
   99.8% of these perfumes truly have zero reviews on the platform. A
   targeted re-collection of the 73 PIDs flagged as `reviews_count > 0`
   yet missing comments recovered 68 of them (305 new comments added);
   the remaining 5 PIDs have `reviews_count > 0` in Fragrantica's metadata
   but the page returns no review HTML — treated as upstream
   metadata/page mismatch.

---

## 9. Loading examples

### 9.1 Python (PyArrow + Pandas)

```python
import pyarrow.parquet as pq
import json

# Comments
comments = pq.read_table('comments.parquet')
df = comments.to_pandas()
print(df.head())

# News list-field unpack
news = pq.read_table('news.parquet').to_pandas()
news['related_pids'] = news['related_pids'].apply(json.loads)
news['related_brands'] = news['related_brands'].apply(json.loads)
```

### 9.2 DuckDB (zero-copy SQL on Parquet)

```sql
-- Direct query, no import needed
SELECT lang, COUNT(*) FROM 'comments.parquet' GROUP BY lang ORDER BY 2 DESC;

-- Multi-file join
SELECT n.title, COUNT(nc.comment_id) AS replies
FROM 'news.parquet' n
LEFT JOIN 'news_comments.parquet' nc ON n.nid = nc.nid AND nc.is_reply = true
GROUP BY n.nid, n.title HAVING replies > 10;
```

### 9.3 Polars

```python
import polars as pl
df = pl.read_parquet('comments.parquet')
df.filter(pl.col('lang') == 'en').head()
```

---

## 10. Sample files

The `samples/` directory contains three small Parquet files that
demonstrate the cross-dataset relationships using real production data:

| File | Rows | Content |
|---|---:|---|
| `comments_sample.parquet` | 25 | Reviews of 5 popular perfumes (Mugler Angel, Guerlain Shalimar, Creed Aventus, JPG Le Male, Dior Poison), each in 5 languages (en/ru/de/es/fr). |
| `news_sample.parquet` | 20 | News articles that reference these 5 perfumes via `related_pids`. Diverse categories and archived/recent mix. |
| `news_comments_sample.parquet` | 20 | Comments from 7 of the news articles in `news_sample.parquet`, mix of root and replies. |

The samples are produced by `scripts/build_sales_samples.py` and use the
**identical Parquet schema and Zstandard compression as the production
files** — buyers can verify their loading code against the samples before
committing to the full datasets.

### 10.1 Cross-link verification (using the samples)

```python
import pyarrow.parquet as pq
import json

c = pq.read_table('samples/comments_sample.parquet')
n = pq.read_table('samples/news_sample.parquet')
nc = pq.read_table('samples/news_comments_sample.parquet')

sample_pids = set(c.column('pid').to_pylist())
print(f"Comment-sample PIDs: {sorted(sample_pids)}")
# {53, 218, 430, 704, 9828}

# Find news rows that reference these PIDs:
for i, rp in enumerate(n.column('related_pids').to_pylist()):
    pids = set(int(p) for p in json.loads(rp) if p.isdigit())
    if pids & sample_pids:
        nid = n.column('nid').to_pylist()[i]
        title = n.column('title').to_pylist()[i]
        print(f"  NID {nid} ({title[:60]}...) references PIDs {pids & sample_pids}")

# All news_comments NIDs are subset of news_sample NIDs:
sample_nids = set(n.column('nid').to_pylist())
nc_nids = set(nc.column('nid').to_pylist())
assert nc_nids <= sample_nids, "FK integrity holds in samples"
print(f"\nAll news_comments_sample NIDs link back to news_sample: {nc_nids <= sample_nids}")
```

Running this script on the supplied samples will print a verification
trace and confirm relational integrity.

---

## 11. Versioning and updates

| Field | Value |
|---|---|
| Snapshot date | 2026-05-05 |
| Comments PID range | 1 — 130,121 |
| News NID range | 1 — 25,000 |
| Schema version | v1 (8 / 16 / 9 fields respectively) |
| Compression | zstd |
| Format | Parquet 2.x |

Updates to these datasets are produced as full snapshots; incremental
diffs (per-PID / per-NID delta exports) are available on request.
