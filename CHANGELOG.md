# Changelog

All notable changes to the FragDB database will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
