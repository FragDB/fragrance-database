# Changelog

All notable changes to the FragDB database will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.13.0] - 2026-08-20

### Changed
- Data update from an incremental delta (parser run 260819)
- Fragrances: 136,682 → **137,147** (+465)
- Brands: 8,175 → **8,210** (+35)
- Perfumers: 3,090 → **3,102** (+12)
- Notes: 2,586 → **2,588** (+2)
- Clean delta: 0 canonical-URL changes, 0 records removed (the 9 Aug full recrawl had 59 URL moves)
- New note `Kiwano` arrived with all 22 translations in the same cycle
- Free sample refreshed: 10-record CSV samples in `samples/` rebuilt from v5.13 data

### Unchanged
- CSV + Parquet schema (column counts 30/54/42/55/27/25 identical)
- Accords: 92 · Languages: 23
- Field coverage flat across all 30 columns (max movement 0.22 pp)

## [5.12.0] - 2026-08-11

### Changed
- Data update from a full source recrawl (parser run 260809)
- Fragrances: 135,308 → **136,682** (+1,374)
- Brands: 8,093 → **8,175** (+82)
- Perfumers: 3,057 → **3,090** (+33)
- Notes: 2,573 → **2,586** (+13)
- Covers two upstream releases (v5.11, v5.12) — the previous public snapshot was v5.10
- 784 records restored: a resume-scan defect had marked them done since May, so they carried a three-month drift in votes, ratings and note pyramids
- Free sample refreshed: 10-record CSV samples in `samples/` rebuilt from v5.12 data

### Unchanged
- CSV + Parquet schema (column counts 30/54/42/55/27/25 identical)
- Accords: 92 · Languages: 23

## [5.9.0] - 2026-07-10

### Changed
- Data update from v5.8 source (parser run 260710)
- Fragrances: 134,022 → **134,577** (+555)
- Brands: 8,000 → **8,036** (+36) — **154 brand names canonicalized** (restored `Fragrance(s)` suffix; IDs stable)
- Perfumers: 3,035 → **3,046** (+11)
- Notes: 2,562 → **2,567** (+5)
- URL hygiene: pyramid anchors single-domain (`www.`), photo cache-busters stripped
- Free sample refreshed: 10-record CSV samples in `samples/` rebuilt from v5.9 data

## [5.8.0] - 2026-07-02

### Changed
- Data update from v5.7 source (parser run 260701)
- Fragrances: 133,392 → **134,022** (+630)
- Brands: 7,953 → **8,000** (+47)
- Perfumers: 3,020 → **3,035** (+15)
- Notes: 2,559 → **2,562** (+3)

### Unchanged
- CSV + Parquet schema
- `samples/` CSV files (10-record samples; schema identical)

## [5.7.0] - 2026-06-26

### Changed
- Data update from v5.6 source (parser run 260619)
- Fragrances: 132,858 → **133,392** (+534)
- Brands: 7,927 → **7,953** (+26)
- Perfumers: 3,005 → **3,020** (+15)
- Notes: 2,550 → **2,559** (+9)
- Total records: 146,432 → **146,924** (+492)

### Unchanged
- CSV/Parquet schema (same column structure as v5.6)
- `samples/` files (10-record samples remain from v5.5; schema/structure unchanged)

### Known limitations (unchanged from v5.6)
- Perfumers transliteration coverage: `perfumer_name_ru` 62%, 8 other scripts 36% — parser skips tier-2/3 perfumers (<5 fragrances)
- Brands `country` / `main_activity` coverage: 93% / 90% — upstream data gap

## [5.6.0] - 2026-06-10

### Changed
- Data update from v5.5 source (parser run 260609)
- Fragrances: 132,124 → **132,858** (+734)
- Brands: 7,881 → **7,927** (+46)
- Perfumers: 2,988 → **3,005** (+17)
- Notes: 2,533 → **2,550** (+17)
- Total records: 145,612 → **146,432** (+820)

### Improved
- **Notes multilingual 100% coverage** (was 99.8%) — 6 previously incomplete notes (Cider Apple, Ghaf tree, Barnyard, Black Lemon, Dark cane sugar, Orange Jasmine) now have all 22 language translations
- **Photo URL stability** — source cache-buster query params (`?t=<unix_ts>`) stripped from `main_photo`. Diff between releases no longer shows phantom changes on 2,921 URLs where files are byte-identical.

### Unchanged
- CSV/Parquet schema (same column structure as v5.5)
- `samples/` files (10-record samples remain from v5.5 — schema and structure unchanged)

### Known limitations (unchanged from v5.5)
- Perfumers transliteration coverage: `perfumer_name_ru` 62%, 8 other scripts 36% — parser skips tier-2/3 perfumers (<5 fragrances)
- Brands `country` / `main_activity` coverage: 93% / 90% — upstream data gap

## [5.5.0] - 2026-06-01

### Changed
- Data update from v5.4 source (parser run 260601)
- Fragrances: 130,949 → **132,124** (+1,175)
- Brands: 7,815 → **7,881** (+66)
- Perfumers: 2,968 → **2,988** (+20)
- Notes: 2,522 → **2,533** (+11)
- Year max in dataset: 2026 → **2027** (advance-stamped fragrances)
- Gender distribution refreshed
- License badge updated to reflect CC-BY-NC-4.0 (was MIT in display, actual license was CC-BY-NC-4.0)

### Unchanged
- Schema: column counts identical to v5.4 (30/54/42/55/27/25) — existing scripts work without modification
- Companion parquets: `comments.parquet` (4.6M), `news.parquet` (24.4K), `news_comments.parquet` (264K) — content unchanged since 2026-05-05
- Accords: still 92
- Multilingual: still 23 languages, same 22 translation columns
- Sample 10 F PIDs identical to v5.4 release (Angel, Tobacco Vanille, Eros, Baccarat Rouge 540, Terre d'Hermès, By the Fireplace, Le Male, 1 Million, Euphoria, CK One)

### Database Statistics
- **Total Records**: 145,612 (across 6 CSV files)
- **Fragrances**: 132,124 in `fragrances.csv` (+1,175)
- **Brands**: 7,881 in `brands.csv` (+66)
- **Perfumers**: 2,988 in `perfumers.csv` (+20)
- **Notes**: 2,533 in `notes.csv` (+11)
- **Accords**: 92 in `accords.csv`
- **Translations**: 34 in `translations.csv`
- **Languages**: 23

---

## [5.4.0] - 2026-05-19

### Changed
- Database updated with latest fragrance data
- **perfumers.csv: 42 columns** (was 39) — added 3 new transliteration languages

### Added
- **Perfumer name transliterations**: he, el, mn (Hebrew, Greek, Mongolian)
- Total perfumer transliteration languages: 9 (ru, uk, ja, zh, ko, ar, he, el, mn)

### Database Statistics
- **Total Records**: 144,280 (across 6 files)
- **Fragrances**: 130,949 in `fragrances.csv` (+863)
- **Brands**: 7,815 in `brands.csv` (+39)
- **Perfumers**: 2,968 in `perfumers.csv` (+8)
- **Notes**: 2,522 in `notes.csv` (+5)
- **Accords**: 92 in `accords.csv`
- **Translations**: 34 in `translations.csv`
- **Languages**: 23

### Companion Parquet Datasets (unchanged)
- `comments.parquet` — 4,643,851 user reviews × 23 languages
- `news.parquet` — 24,440 editorial articles
- `news_comments.parquet` — 263,798 threaded news comments

---

## [5.3.1] - 2026-05-11

### Added
- **Companion Parquet datasets** mentioned in README/DATA_DICTIONARY:
  - `comments.parquet` — 4.6M user reviews in 23 languages
  - `news.parquet` — 24,440 editorial articles
  - `news_comments.parquet` — 263,798 threaded news comments
- **Parquet samples** in `samples/` (25 / 20 / 20 records)
- `SPEC.md` — Apache Parquet schema documentation
- Note: parquet datasets ship in all paid tiers except $200 Core

### Changed
- No CSV data changes (v5.3 data is identical)

---

## [5.3.0] - 2026-05-10

### Changed
- Database updated with latest fragrance data
- All translations now 100% complete (no missing values)

### Database Statistics
- **Total Records**: 143,465 (across 6 files)
- **Fragrances**: 130,086 in `fragrances.csv` (+489)
- **Brands**: 7,776 in `brands.csv` (+37)
- **Perfumers**: 2,960 in `perfumers.csv` (+18)
- **Notes**: 2,517 in `notes.csv` (+2)
- **Accords**: 92 in `accords.csv`
- **Translations**: 34 in `translations.csv`
- **Languages**: 23

---

## [5.2.0] - 2026-05-01

### Changed
- Database updated with latest fragrance data
- **perfumers.csv: 39 columns** (was 36) — added 3 new transliteration languages

### Added
- **Perfumer name transliterations**: zh, ko, ar (Chinese, Korean, Arabic)
- Total perfumer transliteration languages: 6 (ru, uk, ja, zh, ko, ar)

### Database Statistics
- **Total Records**: 142,927 (across 6 files)
- **Fragrances**: 129,597 in `fragrances.csv` (+1,351)
- **Brands**: 7,739 in `brands.csv` (+78)
- **Perfumers**: 2,942 in `perfumers.csv` (+22)
- **Notes**: 2,515 in `notes.csv` (+5)
- **Accords**: 92 in `accords.csv`
- **Translations**: 34 in `translations.csv`
- **Languages**: 23

---

## [5.1.0] - 2026-04-19

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 141,463 (across 6 files)
- **Fragrances**: 128,246 in `fragrances.csv` (+667)
- **Brands**: 7,661 in `brands.csv` (+52)
- **Perfumers**: 2,920 in `perfumers.csv` (+15)
- **Notes**: 2,510 in `notes.csv` (+2)
- **Accords**: 92 in `accords.csv`
- **Translations**: 34 in `translations.csv`
- **Languages**: 23

---

## [5.0.0] - 2026-04-14

### Breaking Changes
- **New file: `translations.csv`** — vocabulary for gender values and voting labels in 23 languages (34 entries)
- **`gender` field** now contains translation IDs (`gender_for_women`) instead of text (`for women`)
- **All voting fields** (`appreciation`, `longevity`, `sillage`, `season`, `time_of_day`, `gender_votes`, `price_value`) now use translation IDs (`like_love:15500:59` instead of `love:15500:59`)
- **`notes_pyramid` format** simplified to `note_id,opacity,weight` (was `name,note_id,img_url,opacity,weight`). Name and icon via notes.csv JOIN.

### Added
- **22 language translations** for note names, note groups, accord names, brand countries, brand activities, perfumer statuses
- **Perfumer name transliterations** for Russian, Ukrainian, Japanese
- **2,508 notes** — each name variant (Rose, Damask Rose) gets its own ID with translations (was ~1,834 by URL)
- **Translation ID system** — readable prefixes: `like_`, `longevity_`, `sillage_`, `season_`, `price_`, `gvotes_`, `gender_`

### Changed
- `notes.csv`: 55 columns (was 11), 2,508 rows (was ~1,834)
- `brands.csv`: 54 columns (was 10) — added `country_{lang}`, `main_activity_{lang}`
- `perfumers.csv`: 36 columns (was 11) — added `status_{lang}`, `perfumer_name_ru/uk/ja`
- `accords.csv`: 27 columns (was 5) — added `name_{lang}`
- `notes.csv` `main_icon` now shows icon from perfume pyramid (was from note page)
- `fragrances.csv` reduced from 336 MB to 284 MB (-15%) due to compact pyramid format

### Database Statistics
- **Total Records**: 140,727 (across 6 files)
- **Fragrances**: 127,579 in `fragrances.csv` (+721)
- **Brands**: 7,609 in `brands.csv` (+36)
- **Perfumers**: 2,905 in `perfumers.csv` (+12)
- **Notes**: 2,508 in `notes.csv` (+674)
- **Accords**: 92 in `accords.csv`
- **Translations**: 34 in `translations.csv` (NEW)
- **Languages**: 23 (EN + 22)

---

## [4.7.0] - 2026-04-03

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 139,910 (across 5 files)
- **Fragrances**: 126,858 in `fragrances.csv` (+1,160)
- **Brands**: 7,573 in `brands.csv` (+73)
- **Perfumers**: 2,893 in `perfumers.csv` (+12)
- **Notes**: 2,494 in `notes.csv` (+668)
- **Accords**: 92 in `accords.csv`
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [4.6.0] - 2026-03-20

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 137,997 (across 5 files)
- **Fragrances**: 125,698 in `fragrances.csv` (+969)
- **Brands**: 7,500 in `brands.csv` (+34)
- **Perfumers**: 2,881 in `perfumers.csv` (+12)
- **Notes**: 1,826 in `notes.csv` (-653)
- **Accords**: 92 in `accords.csv`
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [4.5.0] - 2026-03-11

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 137,635 (across 5 files)
- **Fragrances**: 124,729 in `fragrances.csv` (+564)
- **Brands**: 7,466 in `brands.csv` (+33)
- **Perfumers**: 2,869 in `perfumers.csv` (+10)
- **Notes**: 2,479 in `notes.csv` (+9)
- **Accords**: 92 in `accords.csv`
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [4.4.0] - 2026-03-03

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 136,919 (across 5 files)
- **Fragrances**: 124,165 in `fragrances.csv` (+713)
- **Brands**: 7,433 in `brands.csv` (+52)
- **Perfumers**: 2,859 in `perfumers.csv` (+15)
- **Notes**: 2,470 in `notes.csv` (+8)
- **Accords**: 92 in `accords.csv`
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [4.3.0] - 2026-02-23

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 136,231 (across 5 files)
- **Fragrances**: 123,452 in `fragrances.csv` (+1,085)
- **Brands**: 7,381 in `brands.csv` (+37)
- **Perfumers**: 2,844 in `perfumers.csv` (+19)
- **Notes**: 2,462 in `notes.csv` (+3)
- **Accords**: 92 in `accords.csv`
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [4.2.0] - 2026-02-12

### Changed
- Database updated with latest fragrance data

### Database Statistics
- **Total Records**: 135,087 (across 5 files)
- **Fragrances**: 122,367 in `fragrances.csv` (+828)
- **Brands**: 7,344 in `brands.csv` (+28)
- **Perfumers**: 2,825 in `perfumers.csv` (-3)
- **Notes**: 2,459 in `notes.csv` (+6)
- **Accords**: 92 in `accords.csv`
- **User Photos**: 358,181
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [3.1.0] - 2026-02-05

### Added
- **New field: `video_url`** — YouTube video URLs related to the fragrance (semicolon-separated)

### Removed
- **Field: `ownership`** — Ownership status votes (have_it/had_it/want_it) - data no longer available

### Database Statistics
- **Total Records**: 134,228 (across 5 files)
- **Fragrances**: 121,539 in `fragrances.csv` (+668)
- **Brands**: 7,316 in `brands.csv` (+20)
- **Perfumers**: 2,828 in `perfumers.csv` (+13)
- **Notes**: 2,453 in `notes.csv` (+5)
- **Accords**: 92 in `accords.csv`
- **Fragrances with videos**: 1,591
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

---

## [3.0.0] - 2026-01-26

### Breaking Changes
- **Voting field format changed**: All voting fields now use `category:votes:percent` format instead of just percentages or counts
- **`accords` field format changed**: Now contains `accord_id:percent` pairs, use accords.csv for names and colors
- **`notes_pyramid` field format changed**: Now includes `opacity` and `weight` attributes for each note
- **`reminds_of` field format changed**: Now contains `pid:likes:dislikes` instead of just PIDs
- **Database structure**: Now consists of 5 CSV files instead of 3

### Added
- **New file: `notes.csv`** with 11 fields per note (2,448 records)
  - `id`, `name`, `url`, `latin_name`, `other_names` (Identity)
  - `group`, `odor_profile` (Description)
  - `main_icon`, `alt_icons`, `background`, `fragrance_count` (Media)
- **New file: `accords.csv`** with 5 fields per accord (92 records)
  - `id`, `name` (Identity)
  - `bar_color`, `font_color`, `fragrance_count` (Style)
- **New field: `reviews_count`** — Total number of user reviews per fragrance
- **New field: `pros_cons`** — What People Say (pros and cons with user voting)

### Changed
- All voting fields now include absolute vote counts AND percentages:
  - `appreciation`: `love:12:13.19;like:48:52.75;...`
  - `price_value`: `way_overpriced:0:0;overpriced:2:29;...`
  - `ownership`: `have_it:68:22;had_it:102:33;want_it:137:45`
  - `gender_votes`: `female:5:63;more_female:1:13;unisex:2:25;...`
  - `longevity`: `very_weak:4:18;weak:4:18;moderate:8:36;...`
  - `sillage`: `intimate:5:19;moderate:11:42;strong:5:19;...`
  - `season`: `winter:8:18;spring:15:33;summer:30:67;fall:12:27`
  - `time_of_day`: `day:45:100;night:5:11`
- `notes_pyramid` now includes note ID, opacity (0-1), and weight (visual size)
- `accords` now references accords.csv via ID instead of inline colors

### Database Statistics
- **Total Records**: 133,522 (across 5 files)
- **Fragrances**: 120,871 in `fragrances.csv` (+1,871)
- **Brands**: 7,296 in `brands.csv` (+91)
- **Perfumers**: 2,815 in `perfumers.csv` (+110)
- **Notes**: 2,448 in `notes.csv` (NEW, 11 fields)
- **Accords**: 92 in `accords.csv` (NEW)
- **Total Data Fields**: 67 (30 + 10 + 11 + 11 + 5)

### Migration Guide
See [docs/VERSION_3.0_RELEASE.md](docs/VERSION_3.0_RELEASE.md) for detailed migration instructions.

---

## [2.0.0] - 2026-01-14

### Breaking Changes
- **`brand` field format changed**: Now contains `brand_name;brand_id` instead of `brand_name;brand_url;brand_logo_url`
- **`perfumers` field format changed**: Now contains `name;id;name;id;...` pairs instead of `name,url,photo;...`
- **Database structure**: Now consists of 3 CSV files instead of 1

### Added
- **New file: `brands.csv`** with 10 fields per brand (~7,200 records)
  - `id`, `name`, `url`, `logo_url` (Identity)
  - `country`, `main_activity`, `website`, `parent_company` (Business)
  - `description`, `brand_count` (Description)
- **New file: `perfumers.csv`** with 11 fields per perfumer (~2,700 records)
  - `id`, `name`, `url`, `photo_url` (Identity)
  - `status`, `company`, `also_worked`, `education`, `web` (Career)
  - `perfumes_count`, `biography` (Description)
- **Relational structure**: Link fragrances to brand/perfumer profiles via unique IDs

### Database Statistics
- **Total Records**: 129,000+ (across 3 files)
- **Fragrances**: 119,000+ in `fragrances.csv`
- **Brands**: 7,200+ in `brands.csv`
- **Perfumers**: 2,700+ in `perfumers.csv`
- **Total Data Fields**: 49 (28 + 10 + 11)

### Migration Guide
See [docs/VERSION_2.0_RELEASE.md](docs/VERSION_2.0_RELEASE.md) for detailed migration instructions and code examples.

---

## [1.0.0] - 2026-01-07

### Database Statistics
- **Total Fragrances**: 119,000+
- **Unique Brands**: 7,200+
- **Unique Notes**: 2,400+
- **Unique Accords**: 92
- **Data Fields**: 28

### Initial Release
- Complete fragrance database with 119,000+ entries
- 28 data fields per fragrance
- Pipe-delimited CSV format
- UTF-8 encoding

### Data Coverage
- Fragrances from 1900 to 2026
- Designer, niche, and celebrity fragrances
- Community ratings and votes
- Notes pyramid (top/middle/base)
- Accords with percentages
- Longevity and sillage data
- Seasonal recommendations

## Update Schedule

### Annual Subscription
- Updates released up to 3 times per month
- New fragrances added as they launch
- Existing data refreshed with latest community votes
- Email notification sent with each update

### One-Time Purchase
- Snapshot of database at time of purchase
- No automatic updates included
- Upgrade to subscription available

## Version Naming

- **Major** (X.0.0): Significant structural changes or new fields
- **Minor** (1.X.0): New fragrances added, data updates
- **Patch** (1.0.X): Data corrections, bug fixes

## Previous Versions

This is the initial public release. Previous versions were internal only.
