-- FragDB PostgreSQL Schema
--
-- This schema demonstrates how to import and structure the FragDB
-- fragrance database in PostgreSQL.
--
-- For the full database with 119,000+ fragrances, visit https://fragdb.net

-- Main fragrances table
CREATE TABLE fragrances (
    pid INTEGER PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    url TEXT,
    year SMALLINT,
    gender VARCHAR(50),
    description TEXT,
    main_photo TEXT,
    info_card TEXT,

    -- Brand info (parsed from brand field)
    brand_name VARCHAR(255),
    brand_url TEXT,
    brand_logo TEXT,

    -- Rating (parsed from rating field)
    rating_average DECIMAL(3,2),
    rating_votes INTEGER DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accords table (many-to-many relationship)
CREATE TABLE accords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE fragrance_accords (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    accord_id INTEGER REFERENCES accords(id) ON DELETE CASCADE,
    percentage SMALLINT DEFAULT 0,
    bg_color VARCHAR(20),
    text_color VARCHAR(20),
    sort_order SMALLINT,
    PRIMARY KEY (fragrance_id, accord_id)
);

-- Notes table (many-to-many with layer info)
CREATE TABLE notes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    url TEXT,
    image TEXT
);

CREATE TABLE fragrance_notes (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    note_id INTEGER REFERENCES notes(id) ON DELETE CASCADE,
    layer VARCHAR(10) CHECK (layer IN ('top', 'mid', 'base', 'notes')),
    sort_order SMALLINT,
    PRIMARY KEY (fragrance_id, note_id, layer)
);

-- Longevity votes
CREATE TABLE fragrance_longevity (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    percentage SMALLINT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Sillage votes
CREATE TABLE fragrance_sillage (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    percentage SMALLINT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Gender votes
CREATE TABLE fragrance_gender_votes (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    percentage SMALLINT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Price value votes
CREATE TABLE fragrance_price_votes (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    percentage SMALLINT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category)
);

-- Seasons
CREATE TABLE fragrance_seasons (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    season VARCHAR(20) NOT NULL,
    percentage SMALLINT DEFAULT 0,
    PRIMARY KEY (fragrance_id, season)
);

-- Perfumers
CREATE TABLE perfumers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    url TEXT
);

CREATE TABLE fragrance_perfumers (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    perfumer_id INTEGER REFERENCES perfumers(id) ON DELETE CASCADE,
    PRIMARY KEY (fragrance_id, perfumer_id)
);

-- Collections
CREATE TABLE collections (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE fragrance_collections (
    fragrance_id INTEGER REFERENCES fragrances(pid) ON DELETE CASCADE,
    collection_id INTEGER REFERENCES collections(id) ON DELETE CASCADE,
    PRIMARY KEY (fragrance_id, collection_id)
);

-- User photos
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

-- Indexes for common queries
CREATE INDEX idx_fragrances_name ON fragrances(name);
CREATE INDEX idx_fragrances_brand ON fragrances(brand_name);
CREATE INDEX idx_fragrances_year ON fragrances(year);
CREATE INDEX idx_fragrances_gender ON fragrances(gender);
CREATE INDEX idx_fragrances_rating ON fragrances(rating_average DESC);
CREATE INDEX idx_accords_name ON accords(name);
CREATE INDEX idx_notes_name ON notes(name);

-- Full-text search index (optional)
CREATE INDEX idx_fragrances_search ON fragrances
    USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- Example: Full-text search query
-- SELECT * FROM fragrances
-- WHERE to_tsvector('english', name || ' ' || COALESCE(description, ''))
--       @@ to_tsquery('english', 'vanilla & sweet');
