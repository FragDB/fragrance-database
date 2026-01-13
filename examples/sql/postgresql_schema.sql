-- FragDB v2.0 PostgreSQL Schema
--
-- This schema demonstrates how to import and structure the FragDB
-- multi-file fragrance database in PostgreSQL.
--
-- Files: fragrances.csv, brands.csv, perfumers.csv
-- For the full database with 129,000+ records, visit https://fragdb.net

-- =============================================================================
-- REFERENCE TABLES (from brands.csv and perfumers.csv)
-- =============================================================================

-- Brands table (from brands.csv - 10 fields)
CREATE TABLE brands (
    id VARCHAR(20) PRIMARY KEY,  -- e.g., 'b1', 'b42', 'b1503'
    name VARCHAR(500) NOT NULL,
    url TEXT,
    logo_url TEXT,
    country VARCHAR(100),
    main_activity VARCHAR(100),
    website TEXT,
    parent_company VARCHAR(255),
    description TEXT,
    brand_count INTEGER DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Perfumers table (from perfumers.csv - 11 fields)
CREATE TABLE perfumers (
    id VARCHAR(20) PRIMARY KEY,  -- e.g., 'p1', 'p42', 'p865'
    name VARCHAR(255) NOT NULL,
    url TEXT,
    photo_url TEXT,
    status VARCHAR(100),         -- 'Master Perfumer', 'Senior Perfumer', etc.
    company VARCHAR(255),
    also_worked TEXT,            -- Previous companies (comma-separated)
    education VARCHAR(255),
    web TEXT,
    perfumes_count INTEGER DEFAULT 0,
    biography TEXT,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- MAIN FRAGRANCES TABLE (from fragrances.csv - 28 fields)
-- =============================================================================

CREATE TABLE fragrances (
    pid INTEGER PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    url TEXT,
    year SMALLINT,
    gender VARCHAR(50),
    collection VARCHAR(500),
    description TEXT,
    main_photo TEXT,
    info_card TEXT,

    -- Brand reference (v2.0: uses brand_id from brands table)
    brand_id VARCHAR(20) REFERENCES brands(id),
    brand_name VARCHAR(255),  -- Denormalized for performance

    -- Rating (parsed from rating field: average;votes)
    rating_average DECIMAL(3,2),
    rating_votes INTEGER DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SUPPORTING TABLES
-- =============================================================================

-- Accords reference table
CREATE TABLE accords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- Fragrance-Accord relationship (from accords field)
CREATE TABLE fragrance_accords (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    accord_id INTEGER REFERENCES accords(id) ON DELETE CASCADE,
    percentage SMALLINT DEFAULT 0,
    bg_color VARCHAR(20),
    text_color VARCHAR(20),
    sort_order SMALLINT,
    PRIMARY KEY (fragrance_id, accord_id)
);

-- Notes reference table
CREATE TABLE notes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    url TEXT,
    image TEXT
);

-- Fragrance-Note relationship (from notes_pyramid field)
CREATE TABLE fragrance_notes (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    note_id INTEGER REFERENCES notes(id) ON DELETE CASCADE,
    layer VARCHAR(10) CHECK (layer IN ('top', 'mid', 'base', 'notes')),
    sort_order SMALLINT,
    PRIMARY KEY (fragrance_id, note_id, layer)
);

-- Fragrance-Perfumer relationship (from perfumers field)
-- Format (v2.0): name1;id1;name2;id2;...
CREATE TABLE fragrance_perfumers (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    perfumer_id VARCHAR(20) REFERENCES perfumers(id) ON DELETE CASCADE,
    PRIMARY KEY (fragrance_id, perfumer_id)
);

-- Longevity votes (from longevity field)
CREATE TABLE fragrance_longevity (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    votes INTEGER DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Sillage votes (from sillage field)
CREATE TABLE fragrance_sillage (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    votes INTEGER DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Gender votes (from gender_votes field)
CREATE TABLE fragrance_gender_votes (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    votes INTEGER DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Price value votes (from price_value field)
CREATE TABLE fragrance_price_votes (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    votes INTEGER DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Season recommendations (from season field)
CREATE TABLE fragrance_seasons (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    season VARCHAR(20) NOT NULL,
    percentage DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, season)
);

-- User photos (from user_photoes field)
CREATE TABLE fragrance_photos (
    id SERIAL PRIMARY KEY,
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    photo_url TEXT NOT NULL
);

-- "Also like" relationships (from also_like field)
CREATE TABLE fragrance_also_like (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    related_fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    PRIMARY KEY (fragrance_id, related_fragrance_id)
);

-- "Reminds of" relationships (from reminds_of field)
CREATE TABLE fragrance_reminds_of (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    related_fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    PRIMARY KEY (fragrance_id, related_fragrance_id)
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Fragrances indexes
CREATE INDEX idx_fragrances_name ON fragrances(name);
CREATE INDEX idx_fragrances_brand_id ON fragrances(brand_id);
CREATE INDEX idx_fragrances_brand_name ON fragrances(brand_name);
CREATE INDEX idx_fragrances_year ON fragrances(year);
CREATE INDEX idx_fragrances_gender ON fragrances(gender);
CREATE INDEX idx_fragrances_rating ON fragrances(rating_average DESC);

-- Brands indexes
CREATE INDEX idx_brands_name ON brands(name);
CREATE INDEX idx_brands_country ON brands(country);
CREATE INDEX idx_brands_parent ON brands(parent_company);

-- Perfumers indexes
CREATE INDEX idx_perfumers_name ON perfumers(name);
CREATE INDEX idx_perfumers_company ON perfumers(company);
CREATE INDEX idx_perfumers_status ON perfumers(status);

-- Other indexes
CREATE INDEX idx_accords_name ON accords(name);
CREATE INDEX idx_notes_name ON notes(name);

-- Full-text search index (optional)
CREATE INDEX idx_fragrances_search ON fragrances
    USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- =============================================================================
-- EXAMPLE QUERIES (v2.0 with JOINs)
-- =============================================================================

-- Get fragrances with brand details
-- SELECT f.pid, f.name, b.name AS brand, b.country, b.website
-- FROM fragrances f
-- LEFT JOIN brands b ON f.brand_id = b.id
-- WHERE b.country = 'France';

-- Get fragrances with perfumer details
-- SELECT f.pid, f.name, p.name AS perfumer, p.company, p.status
-- FROM fragrances f
-- JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
-- JOIN perfumers p ON fp.perfumer_id = p.id
-- WHERE p.company = 'Firmenich';

-- Full-text search
-- SELECT * FROM fragrances
-- WHERE to_tsvector('english', name || ' ' || COALESCE(description, ''))
--       @@ to_tsquery('english', 'vanilla & sweet');
