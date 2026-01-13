# SQL Import Instructions (v2.0)

This guide explains how to import the FragDB multi-file CSV database into PostgreSQL and MySQL.

## v2.0 Database Structure

FragDB v2.0 consists of **3 CSV files**:

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| `fragrances.csv` | 119,000+ | 28 | Main fragrance database |
| `brands.csv` | 7,200+ | 10 | Brand/designer profiles |
| `perfumers.csv` | 2,700+ | 11 | Perfumer (nose) profiles |

## Prerequisites

- FragDB CSV files (pipe-delimited, UTF-8)
- PostgreSQL 12+ or MySQL 8.0+
- Basic SQL knowledge

## Quick Import (Flat Tables)

### Step 1: Import Brands

```bash
# PostgreSQL
psql -d your_database -c "
CREATE TABLE brands_raw (
    id TEXT,
    name TEXT,
    url TEXT,
    logo_url TEXT,
    country TEXT,
    main_activity TEXT,
    website TEXT,
    parent_company TEXT,
    description TEXT,
    brand_count TEXT
);
"

psql -d your_database -c "\copy brands_raw FROM 'brands.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"
```

```sql
-- MySQL
CREATE TABLE brands_raw (
    id VARCHAR(20),
    name VARCHAR(500),
    url TEXT,
    logo_url TEXT,
    country VARCHAR(100),
    main_activity VARCHAR(100),
    website TEXT,
    parent_company VARCHAR(255),
    description TEXT,
    brand_count VARCHAR(20)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

LOAD DATA LOCAL INFILE 'brands.csv'
INTO TABLE brands_raw
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

### Step 2: Import Perfumers

```bash
# PostgreSQL
psql -d your_database -c "
CREATE TABLE perfumers_raw (
    id TEXT,
    name TEXT,
    url TEXT,
    photo_url TEXT,
    status TEXT,
    company TEXT,
    also_worked TEXT,
    education TEXT,
    web TEXT,
    perfumes_count TEXT,
    biography TEXT
);
"

psql -d your_database -c "\copy perfumers_raw FROM 'perfumers.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"
```

### Step 3: Import Fragrances

```bash
# PostgreSQL
psql -d your_database -c "
CREATE TABLE fragrances_raw (
    pid TEXT,
    url TEXT,
    brand TEXT,
    name TEXT,
    year TEXT,
    gender TEXT,
    collection TEXT,
    main_photo TEXT,
    info_card TEXT,
    user_photoes TEXT,
    accords TEXT,
    notes_pyramid TEXT,
    perfumers TEXT,
    description TEXT,
    rating TEXT,
    appreciation TEXT,
    price_value TEXT,
    ownership TEXT,
    gender_votes TEXT,
    longevity TEXT,
    sillage TEXT,
    season TEXT,
    time_of_day TEXT,
    by_designer TEXT,
    in_collection TEXT,
    reminds_of TEXT,
    also_like TEXT,
    news_ids TEXT
);
"

psql -d your_database -c "\copy fragrances_raw FROM 'fragrances.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"
```

## Normalized Import

For production use, we recommend normalizing the data. See `postgresql_schema.sql` or `mysql_schema.sql` for the complete schema.

### Step 1: Create Schema

```bash
# PostgreSQL
psql -d your_database -f postgresql_schema.sql

# MySQL
mysql -u user -p your_database < mysql_schema.sql
```

### Step 2: Import Reference Tables

```sql
-- PostgreSQL: Import brands
INSERT INTO brands (id, name, url, logo_url, country, main_activity, website, parent_company, description, brand_count)
SELECT
    id,
    name,
    url,
    logo_url,
    country,
    main_activity,
    website,
    parent_company,
    description,
    NULLIF(brand_count, '')::INTEGER
FROM brands_raw;

-- PostgreSQL: Import perfumers
INSERT INTO perfumers (id, name, url, photo_url, status, company, also_worked, education, web, perfumes_count, biography)
SELECT
    id,
    name,
    url,
    photo_url,
    status,
    company,
    also_worked,
    education,
    web,
    NULLIF(perfumes_count, '')::INTEGER,
    biography
FROM perfumers_raw;
```

### Step 3: Parse and Insert Fragrances

#### Parse Brand Field (v2.0 Format)

The brand field in v2.0 uses format: `brand_name;brand_id`

```sql
-- PostgreSQL
INSERT INTO fragrances (pid, name, url, year, gender, collection, description,
                        brand_id, brand_name, rating_average, rating_votes)
SELECT
    pid::INTEGER,
    name,
    url,
    NULLIF(year, '')::SMALLINT,
    gender,
    collection,
    description,
    -- Parse brand: name;brand_id (v2.0 format)
    split_part(brand, ';', 2) AS brand_id,
    split_part(brand, ';', 1) AS brand_name,
    -- Parse rating: average;votes
    NULLIF(split_part(rating, ';', 1), '')::DECIMAL(3,2) AS rating_average,
    NULLIF(split_part(rating, ';', 2), '')::INTEGER AS rating_votes
FROM fragrances_raw;
```

#### Parse Perfumers Field (v2.0 Format)

The perfumers field in v2.0 uses format: `name1;id1;name2;id2;...`

```sql
-- PostgreSQL function to parse perfumers (v2.0)
CREATE OR REPLACE FUNCTION parse_perfumers_v2(perfumers_str TEXT)
RETURNS TABLE (name TEXT, id TEXT) AS $$
DECLARE
    parts TEXT[];
    i INTEGER;
BEGIN
    IF perfumers_str IS NULL OR perfumers_str = '' THEN
        RETURN;
    END IF;

    parts := string_to_array(perfumers_str, ';');

    FOR i IN 1..array_length(parts, 1) BY 2 LOOP
        IF i + 1 <= array_length(parts, 1) THEN
            name := parts[i];
            id := parts[i + 1];
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM parse_perfumers_v2('Alberto Morillas;p24;Olivier Cresp;p39');
-- Returns:
--   name            | id
--   ----------------+-----
--   Alberto Morillas| p24
--   Olivier Cresp   | p39
```

```sql
-- Insert fragrance-perfumer relationships
INSERT INTO fragrance_perfumers (fragrance_id, perfumer_id)
SELECT
    fr.pid::INTEGER,
    (pp).id
FROM fragrances_raw fr
CROSS JOIN LATERAL parse_perfumers_v2(fr.perfumers) pp
WHERE fr.perfumers IS NOT NULL AND fr.perfumers != '';
```

#### Parse Accords Field

Accords format: `name:percentage:bg_color:text_color;...`

```sql
-- PostgreSQL function to parse accords
CREATE OR REPLACE FUNCTION parse_accords(accords_str TEXT)
RETURNS TABLE (name TEXT, percentage INT, bg_color TEXT, text_color TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        split_part(accord, ':', 1),
        split_part(accord, ':', 2)::INT,
        split_part(accord, ':', 3),
        split_part(accord, ':', 4)
    FROM unnest(string_to_array(accords_str, ';')) AS accord
    WHERE accord != '';
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM parse_accords('woody:85:#4A3728:#FFFFFF;citrus:70:#FFD700:#000000');
```

## Python Import Script

For complex imports, we recommend using Python:

```python
import pandas as pd
import psycopg2

def import_fragdb_v2(samples_dir, db_config):
    """Import FragDB v2.0 multi-file database."""

    # Load all CSV files
    brands = pd.read_csv(f'{samples_dir}/brands.csv', sep='|', encoding='utf-8')
    perfumers = pd.read_csv(f'{samples_dir}/perfumers.csv', sep='|', encoding='utf-8')
    fragrances = pd.read_csv(f'{samples_dir}/fragrances.csv', sep='|', encoding='utf-8')

    conn = psycopg2.connect(**db_config)
    cur = conn.cursor()

    # Insert brands
    for _, row in brands.iterrows():
        cur.execute("""
            INSERT INTO brands (id, name, country, website, brand_count)
            VALUES (%s, %s, %s, %s, %s)
        """, (row['id'], row['name'], row.get('country'),
              row.get('website'), row.get('brand_count')))

    # Insert perfumers
    for _, row in perfumers.iterrows():
        cur.execute("""
            INSERT INTO perfumers (id, name, company, status, perfumes_count)
            VALUES (%s, %s, %s, %s, %s)
        """, (row['id'], row['name'], row.get('company'),
              row.get('status'), row.get('perfumes_count')))

    # Insert fragrances
    for _, row in fragrances.iterrows():
        # Parse brand (v2.0 format: name;brand_id)
        brand_parts = (row['brand'] or '').split(';')
        brand_name = brand_parts[0] if brand_parts else ''
        brand_id = brand_parts[1] if len(brand_parts) > 1 else None

        # Parse rating
        rating_parts = (row['rating'] or '').split(';')
        rating_avg = float(rating_parts[0]) if rating_parts[0] else None
        rating_votes = int(rating_parts[1]) if len(rating_parts) > 1 else 0

        cur.execute("""
            INSERT INTO fragrances (pid, name, brand_id, brand_name,
                                    rating_average, rating_votes)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (row['pid'], row['name'], brand_id, brand_name,
              rating_avg, rating_votes))

        # Insert perfumer relationships
        perfumers_str = row.get('perfumers', '')
        if perfumers_str:
            parts = perfumers_str.split(';')
            for i in range(0, len(parts), 2):
                if i + 1 < len(parts):
                    perfumer_id = parts[i + 1]
                    cur.execute("""
                        INSERT INTO fragrance_perfumers (fragrance_id, perfumer_id)
                        VALUES (%s, %s)
                        ON CONFLICT DO NOTHING
                    """, (row['pid'], perfumer_id))

    conn.commit()
    cur.close()
    conn.close()
```

## Performance Tips

1. **Disable indexes** during bulk import, then recreate them
2. **Import in order**: brands → perfumers → fragrances (for foreign key constraints)
3. **Use transactions** for batch inserts
4. **Increase work_mem** for PostgreSQL sorting operations
5. **Use COPY** instead of INSERT for PostgreSQL

## Troubleshooting

### Encoding Issues

```bash
# Convert file encoding if needed
iconv -f ISO-8859-1 -t UTF-8 fragrances.csv > fragrances_utf8.csv
```

### Foreign Key Violations

Ensure brands and perfumers are imported before fragrances:

```sql
-- Check for missing brand references
SELECT DISTINCT split_part(brand, ';', 2) AS brand_id
FROM fragrances_raw
WHERE split_part(brand, ';', 2) NOT IN (SELECT id FROM brands);
```

### Memory Issues

For large files, process in chunks:

```python
# Python chunked processing
for chunk in pd.read_csv('fragrances.csv', sep='|', chunksize=10000):
    process_chunk(chunk)
```

## Next Steps

- See `sample_queries.sql` for example queries with JOINs
- Check the [DATA_DICTIONARY.md](../../DATA_DICTIONARY.md) for field descriptions
- Visit [fragdb.net](https://fragdb.net) for the full database
