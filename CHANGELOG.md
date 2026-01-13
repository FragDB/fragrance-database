# Changelog

All notable changes to the FragDB database will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
