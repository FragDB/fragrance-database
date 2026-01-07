# SQL Import Instructions

This guide explains how to import the FragDB CSV database into PostgreSQL and MySQL.

## Prerequisites

- FragDB CSV file (pipe-delimited, UTF-8)
- PostgreSQL 12+ or MySQL 8.0+
- Basic SQL knowledge

## Quick Import (Flat Table)

### PostgreSQL

```bash
# Create a simple table
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

# Import CSV (using pipe delimiter)
psql -d your_database -c "\copy fragrances_raw FROM 'fragdb.csv' WITH (FORMAT csv, DELIMITER '|', HEADER true, ENCODING 'UTF8')"
```

### MySQL

```sql
-- Create table
CREATE TABLE fragrances_raw (
    pid VARCHAR(20),
    url TEXT,
    brand TEXT,
    name VARCHAR(500),
    year VARCHAR(10),
    gender VARCHAR(50),
    collection TEXT,
    main_photo TEXT,
    info_card TEXT,
    user_photoes TEXT,
    accords TEXT,
    notes_pyramid TEXT,
    perfumers TEXT,
    description TEXT,
    rating VARCHAR(50),
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
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Import CSV
LOAD DATA LOCAL INFILE 'fragdb.csv'
INTO TABLE fragrances_raw
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

## Normalized Import

For production use, we recommend normalizing the data. See `postgresql_schema.sql` or `mysql_schema.sql` for the complete schema.

### Step 1: Import Raw Data

First, import into the raw table as shown above.

### Step 2: Parse and Insert

Use stored procedures or application code to parse the complex fields.

#### Example: Parse Brand Field

```sql
-- PostgreSQL
INSERT INTO fragrances (pid, name, url, year, gender, description,
                        brand_name, brand_url, brand_logo,
                        rating_average, rating_votes)
SELECT
    pid::INTEGER,
    name,
    url,
    NULLIF(year, '')::SMALLINT,
    gender,
    description,
    -- Parse brand: name;url;logo
    split_part(brand, ';', 1) AS brand_name,
    split_part(brand, ';', 2) AS brand_url,
    split_part(brand, ';', 3) AS brand_logo,
    -- Parse rating: average;votes
    NULLIF(split_part(rating, ';', 1), '')::DECIMAL(3,2) AS rating_average,
    NULLIF(split_part(rating, ';', 2), '')::INTEGER AS rating_votes
FROM fragrances_raw;
```

#### Example: Parse Accords Field

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

#### Example: Parse Notes Pyramid

Notes format: `layer(note,url,img;note,url,img);layer(...)`

```sql
-- PostgreSQL function to parse notes
CREATE OR REPLACE FUNCTION parse_notes_pyramid(notes_str TEXT)
RETURNS TABLE (layer TEXT, note_name TEXT, note_url TEXT, note_image TEXT) AS $$
DECLARE
    layer_match TEXT[];
    layer_name TEXT;
    notes_content TEXT;
    note_parts TEXT[];
BEGIN
    -- Match each layer: top(...), middle(...), base(...), notes(...)
    FOR layer_match IN
        SELECT regexp_matches(notes_str, '(top|middle|base|notes)\(([^)]*)\)', 'g')
    LOOP
        layer_name := layer_match[1];
        notes_content := layer_match[2];

        -- Parse individual notes within the layer
        FOR note_parts IN
            SELECT string_to_array(note, ',')
            FROM unnest(string_to_array(notes_content, ';')) AS note
            WHERE note != ''
        LOOP
            layer := layer_name;
            note_name := note_parts[1];
            note_url := note_parts[2];
            note_image := note_parts[3];
            RETURN NEXT;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### Step 3: Insert Parsed Data

```sql
-- Insert accords
INSERT INTO accords (name)
SELECT DISTINCT (parse_accords(accords)).name
FROM fragrances_raw
WHERE accords IS NOT NULL AND accords != ''
ON CONFLICT (name) DO NOTHING;

-- Insert fragrance-accord relationships
INSERT INTO fragrance_accords (fragrance_id, accord_id, percentage, bg_color, text_color, sort_order)
SELECT
    fr.pid::INTEGER,
    a.id,
    (pa).percentage,
    (pa).bg_color,
    (pa).text_color,
    row_number() OVER (PARTITION BY fr.pid)
FROM fragrances_raw fr
CROSS JOIN LATERAL parse_accords(fr.accords) pa
JOIN accords a ON a.name = (pa).name
WHERE fr.accords IS NOT NULL AND fr.accords != '';
```

## Python Import Script

For complex imports, we recommend using Python:

```python
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values

def import_fragdb(csv_path, db_config):
    # Load CSV
    df = pd.read_csv(csv_path, sep='|', encoding='utf-8')

    conn = psycopg2.connect(**db_config)
    cur = conn.cursor()

    # Insert fragrances
    for _, row in df.iterrows():
        # Parse brand
        brand_parts = (row['brand'] or '').split(';')
        brand_name = brand_parts[0] if brand_parts else ''

        # Parse rating
        rating_parts = (row['rating'] or '').split(';')
        rating_avg = float(rating_parts[0]) if rating_parts[0] else None
        rating_votes = int(rating_parts[1]) if len(rating_parts) > 1 else 0

        cur.execute("""
            INSERT INTO fragrances (pid, name, brand_name, rating_average, rating_votes)
            VALUES (%s, %s, %s, %s, %s)
        """, (row['pid'], row['name'], brand_name, rating_avg, rating_votes))

    conn.commit()
    cur.close()
    conn.close()
```

## Performance Tips

1. **Disable indexes** during bulk import, then recreate them
2. **Use transactions** for batch inserts
3. **Increase work_mem** for PostgreSQL sorting operations
4. **Use COPY** instead of INSERT for PostgreSQL
5. **Enable local_infile** for MySQL LOAD DATA

## Troubleshooting

### Encoding Issues

```bash
# Convert file encoding if needed
iconv -f ISO-8859-1 -t UTF-8 fragdb.csv > fragdb_utf8.csv
```

### Escape Character Issues

The pipe delimiter (`|`) shouldn't conflict with data, but if you encounter issues:

```sql
-- PostgreSQL: Use QUOTE option
\copy table FROM 'file.csv' WITH (FORMAT csv, DELIMITER '|', QUOTE E'\x01')
```

### Memory Issues

For large files, process in chunks:

```python
# Python chunked processing
for chunk in pd.read_csv('fragdb.csv', sep='|', chunksize=10000):
    process_chunk(chunk)
```

## Next Steps

- See `sample_queries.sql` for example queries
- Check the [DATA_DICTIONARY.md](../../DATA_DICTIONARY.md) for field descriptions
- Visit [fragdb.net](https://fragdb.net) for the full database
