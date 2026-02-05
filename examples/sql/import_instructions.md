# SQL Import Instructions (v3.1)

This guide explains how to import the FragDB multi-file CSV database into PostgreSQL and MySQL.

## Database Structure

FragDB v3.1 consists of **5 CSV files**:

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| `fragrances.csv` | 121,000+ | 30 | Main fragrance database |
| `brands.csv` | 7,300+ | 10 | Brand/designer profiles |
| `perfumers.csv` | 2,800+ | 11 | Perfumer (nose) profiles |
| `notes.csv` | 2,400+ | 11 | Fragrance notes reference |
| `accords.csv` | 92 | 5 | Accords with colors |

## Prerequisites

- FragDB CSV files (pipe-delimited, UTF-8)
- PostgreSQL 12+ or MySQL 8.0+
- Basic SQL knowledge

## Quick Import (Flat Tables)

### Step 1: Import Reference Tables

```bash
# PostgreSQL - Import brands
psql -d your_database -c "\copy brands FROM 'brands.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"

# PostgreSQL - Import perfumers
psql -d your_database -c "\copy perfumers FROM 'perfumers.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"

# PostgreSQL - Import notes
psql -d your_database -c "\copy notes FROM 'notes.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"

# PostgreSQL - Import accords
psql -d your_database -c "\copy accords FROM 'accords.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"
```

### Step 2: Import Fragrances

```bash
# PostgreSQL
psql -d your_database -c "\copy fragrances FROM 'fragrances.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"
```

## Normalized Import

For production use, we recommend using the normalized schema. See `postgresql_schema.sql` or `mysql_schema.sql`.

### Step 1: Create Schema

```bash
# PostgreSQL
psql -d your_database -f postgresql_schema.sql

# MySQL
mysql -u user -p your_database < mysql_schema.sql
```

### Step 2: Parse Key Fields

#### Brand Field Format

```
brand_name;brand_id
```

Example: `Dior;b3`

```sql
-- PostgreSQL: Extract brand_id
SELECT
    split_part(brand, ';', 1) AS brand_name,
    split_part(brand, ';', 2) AS brand_id
FROM fragrances_raw;
```

#### Accords Field Format (v3.0+)

```
accord_id:percentage;...
```

Example: `a24:100;a34:64;a38:60`

```sql
-- PostgreSQL: Parse accords
SELECT
    split_part(accord, ':', 1) AS accord_id,
    split_part(accord, ':', 2)::INT AS percentage
FROM unnest(string_to_array(accords_field, ';')) AS accord;
```

#### Perfumers Field Format

```
name1;id1;name2;id2;...
```

Example: `Alberto Morillas;p24;Olivier Cresp;p39`

```python
# Python parsing
parts = perfumers_field.split(';')
for i in range(0, len(parts), 2):
    name = parts[i]
    perfumer_id = parts[i + 1] if i + 1 < len(parts) else None
```

## Python Import Script

```python
import pandas as pd

# Load all five files
fragrances = pd.read_csv('fragrances.csv', sep='|', encoding='utf-8')
brands = pd.read_csv('brands.csv', sep='|', encoding='utf-8')
perfumers = pd.read_csv('perfumers.csv', sep='|', encoding='utf-8')
notes = pd.read_csv('notes.csv', sep='|', encoding='utf-8')
accords = pd.read_csv('accords.csv', sep='|', encoding='utf-8')

# Extract brand_id for joining
fragrances['brand_id'] = fragrances['brand'].str.split(';').str[1]

# Join with brands
df = fragrances.merge(brands, left_on='brand_id', right_on='id', suffixes=('', '_brand'))
```

## Performance Tips

1. **Disable indexes** during bulk import, then recreate them
2. **Import in order**: brands → perfumers → notes → accords → fragrances
3. **Use transactions** for batch inserts
4. **Use COPY** instead of INSERT for PostgreSQL

## Troubleshooting

### Encoding Issues

```bash
# Verify file encoding
file -i fragrances.csv

# Convert if needed
iconv -f ISO-8859-1 -t UTF-8 fragrances.csv > fragrances_utf8.csv
```

### Memory Issues

For large files, process in chunks:

```python
for chunk in pd.read_csv('fragrances.csv', sep='|', chunksize=10000):
    process_chunk(chunk)
```

## Next Steps

- See `sample_queries.sql` for example queries with JOINs
- Check [DATA_DICTIONARY.md](../../DATA_DICTIONARY.md) for field descriptions
- Visit [fragdb.net](https://fragdb.net) for the full database
