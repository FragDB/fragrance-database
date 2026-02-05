# Frequently Asked Questions

## General

### What is FragDB?

FragDB is a comprehensive fragrance database containing detailed information on 121,000+ perfumes, colognes, and other fragrances. It includes data on brands, perfumers, notes, accords, ratings, and much more.

### What's included in the free sample?

The free sample on GitHub includes:
- 10 fragrance records with all 30 data fields
- 10 brand profiles
- 10 perfumer profiles
- 10 notes
- 10 accords with display colors
- Complete documentation and data dictionary
- Code examples in Python, JavaScript, SQL, and R
- Integration guides and use cases

### How do I get the full database?

Visit [fragdb.net](https://fragdb.net) to purchase:
- **One-Time Purchase**: $500 - Complete database download
- **Annual Subscription**: $2,000/year - Regular updates throughout the year

### What file format is the database?

The database consists of 5 pipe-delimited (`|`) CSV files with UTF-8 encoding:
- `fragrances.csv` - Main fragrance data (30 fields)
- `brands.csv` - Brand/designer profiles (10 fields)
- `perfumers.csv` - Perfumer (nose) profiles (11 fields)
- `notes.csv` - Fragrance notes reference (11 fields)
- `accords.csv` - Accords with colors (5 fields)

This format was chosen because:
- Pipe characters rarely appear in fragrance data
- Easy to import into any database or programming language
- Human-readable and easy to inspect
- Compatible with all major data tools

### How often is the database updated?

The full database is updated regularly. Annual subscription customers receive all updates during their subscription period.

---

## Technical

### Why pipe-delimited instead of comma-delimited?

Fragrance descriptions and other text fields frequently contain commas. Using pipes (`|`) as delimiters avoids parsing issues and eliminates the need for quote escaping.

### How do I parse the complex fields?

Many fields contain structured data with their own delimiters. See [DATA_DICTIONARY.md](../DATA_DICTIONARY.md) for complete parsing instructions. Quick examples:

**Brand** (`;` separated):
```python
name, brand_id = row['brand'].split(';')
# Look up full details in brands.csv using brand_id
```

**Rating** (`;` separated):
```python
average, votes = row['rating'].split(';')
```

**Accords** (`;` for items, `:` for id:percent):
```python
for accord in row['accords'].split(';'):
    accord_id, percentage = accord.split(':')
    # Look up name and colors in accords.csv using accord_id
```

**Notes Pyramid** (regex pattern):
```python
import re
layers = re.findall(r'(top|mid|base|notes)\(([^)]*)\)', row['notes_pyramid'])
```

### What databases are supported?

The data can be imported into any database:
- **SQL**: PostgreSQL, MySQL, SQLite, SQL Server, Oracle
- **NoSQL**: MongoDB, Elasticsearch, Redis
- **Cloud**: BigQuery, Snowflake, Redshift
- **Files**: JSON, Parquet, Excel

See [examples/sql/](../examples/sql/) for SQL schemas and import scripts.

### What programming languages have examples?

The repository includes examples for:
- Python (pandas, numpy)
- JavaScript (Node.js, Express)
- SQL (PostgreSQL, MySQL)
- R (tidyverse, ggplot2)

The CSV format works with any language that can read text files.

### Can I use this with Excel?

Yes! Import steps:
1. Open Excel
2. Data → From Text/CSV
3. Select the file
4. Set delimiter to "Other" and enter `|`
5. Click Load

Note: Excel has a row limit of ~1 million rows, which is sufficient for the full database.

---

## Data

### What fields are included?

**67 total fields** across 5 files. Fragrances have 30 fields:
- Basic: `pid`, `url`, `brand`, `name`, `year`, `gender`, `collection`
- Media: `main_photo`, `info_card`, `user_photoes`, `video_url`
- Composition: `accords`, `notes_pyramid`, `perfumers`, `description`
- Ratings: `rating`, `reviews_count`, `appreciation`, `price_value`
- Characteristics: `gender_votes`, `longevity`, `sillage`, `season`, `time_of_day`
- AI: `pros_cons`
- Related: `by_designer`, `in_collection`, `reminds_of`, `also_like`, `news_ids`

See [DATA_DICTIONARY.md](../DATA_DICTIONARY.md) for complete field documentation.

### Are images included?

Image URLs are included in the database. The actual image files are not included due to size and copyright considerations. The URLs point to:
- `main_photo` - Primary product photo
- `info_card` - Information card image (social media preview)
- `user_photoes` - Community-submitted photos (semicolon-separated)

### Are videos included?

YouTube video URLs are included in the `video_url` field for fragrances that have related videos.

### Is the data accurate?

The data is aggregated from public sources and community contributions. While we strive for accuracy:
- Ratings reflect community consensus at time of extraction
- Some older fragrances may have limited data
- Recently released fragrances may be missing
- Some fields may be empty for certain entries

### What time period does the database cover?

The database includes fragrances from 1533 to present, with the majority from 1990 onwards. The distribution roughly mirrors industry growth.

### Does the database include older/vintage fragrances?

Yes! The database includes fragrances from 1533 to present. Older fragrances are identified by their `year` field and can be researched using:
- `year` - Release year for historical analysis
- `rating`, `reviews_count` - Community engagement metrics
- `notes_pyramid`, `accords` - Composition details

---

## Licensing & Usage

### Can I use this for commercial projects?

**Free Sample**: Licensed under MIT for the sample data and code examples. You may use the 10-row sample commercially.

**Full Database**: Subject to commercial license terms. One purchase = one project/application. Contact us for enterprise licensing.

### Can I redistribute the data?

**Free Sample**: Yes, with attribution.

**Full Database**: No redistribution allowed. The data is for your internal use only.

### Can I build a public API with this data?

**Free Sample**: Yes, for demonstration purposes.

**Full Database**: You may build internal APIs. Public APIs that effectively redistribute the data require additional licensing.

### Can I use this for academic research?

Yes! Both the sample and full database may be used for academic research. We appreciate citations:

```
FragDB Fragrance Database. (2026). FragDB.net. https://fragdb.net
```

### What about the code examples?

All code examples in this repository are MIT licensed. You may use, modify, and redistribute them freely.

---

## Purchasing

### How do I purchase the full database?

1. Visit [fragdb.net](https://fragdb.net)
2. Create an account
3. Choose your plan (one-time or subscription)
4. Complete payment
5. Download your database

### What payment methods are accepted?

- Credit/debit cards (Visa, Mastercard, Amex)
- Cryptocurrency (Bitcoin, Ethereum, USDT, others)

### Is there a refund policy?

Due to the digital nature of the product, refunds are handled on a case-by-case basis. Please contact support before purchasing if you have concerns.

### Do you offer enterprise pricing?

Yes! For multi-user licenses, API access, or custom data needs, contact us at the email listed on [fragdb.net](https://fragdb.net).

---

## Support

### How do I report issues with the data?

Please open a [GitHub Issue](../../issues) with:
- The fragrance `pid` and `name`
- The field with the issue
- What you expected vs. what you found

### How do I request a new feature?

Open a [GitHub Issue](../../issues) or [Feature Request](../../issues/new?template=feature_request.md) with:
- Description of the feature
- Your use case
- Why it would be valuable

### How do I contact support?

- GitHub Issues (preferred for technical questions)
- Email: contact information on [fragdb.net](https://fragdb.net)

---

## Contributing

### Can I contribute to this repository?

Yes! We welcome contributions:
- Bug fixes for code examples
- New code examples in other languages
- Documentation improvements
- Translation assistance

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### Can I submit corrections to the data?

For the free sample: Open a GitHub Issue.
For the full database: Contact support with correction details.

### Can I add new fragrances to the database?

The database is maintained by the FragDB team. If you notice missing fragrances, please contact us with details.
