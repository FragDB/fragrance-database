-- FragDB v4.2 MySQL Schema
--
-- This schema demonstrates how to import and structure the FragDB
-- multi-file fragrance database in MySQL/MariaDB.
--
-- Files: fragrances.csv, brands.csv, perfumers.csv, notes.csv, accords.csv
-- For the full database with 135,000+ records, visit https://fragdb.net

-- =============================================================================
-- REFERENCE TABLES (from CSV files)
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
    brand_count INT DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_name (name(100)),
    INDEX idx_country (country),
    INDEX idx_parent (parent_company)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
    perfumes_count INT DEFAULT 0,
    biography TEXT,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_name (name(100)),
    INDEX idx_company (company),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notes table (NEW in v3.0 - from notes.csv - 10 fields)
CREATE TABLE notes (
    id VARCHAR(20) PRIMARY KEY,  -- e.g., 'n1', 'n80', 'n2447'
    name VARCHAR(200) NOT NULL,
    url TEXT,
    latin_name VARCHAR(200),
    other_names TEXT,            -- Semicolon-separated alternative names
    note_group VARCHAR(100),     -- 'group' is reserved word, renamed
    odor_profile TEXT,
    main_icon TEXT,
    alt_icons TEXT,              -- Semicolon-separated URLs
    fragrance_count INT DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_name (name),
    INDEX idx_group (note_group)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Accords table (NEW in v3.0 - from accords.csv - 5 fields)
CREATE TABLE accords (
    id VARCHAR(20) PRIMARY KEY,  -- e.g., 'a1', 'a24', 'a92'
    name VARCHAR(100) NOT NULL,
    bar_color VARCHAR(10),       -- Hex color for background
    font_color VARCHAR(10),      -- Hex color for text
    fragrance_count INT DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- MAIN FRAGRANCES TABLE (from fragrances.csv - 30 fields)
-- =============================================================================

CREATE TABLE fragrances (
    pid INT PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    url TEXT,
    year SMALLINT,
    gender VARCHAR(50),
    collection VARCHAR(500),
    description TEXT,
    main_photo TEXT,
    info_card TEXT,
    video_url TEXT,  -- YouTube video URLs (semicolon-separated)

    -- Brand reference (uses brand_id from brands table)
    brand_id VARCHAR(20),
    brand_name VARCHAR(255),  -- Denormalized for performance

    -- Rating (parsed from rating field: average;votes)
    rating_average DECIMAL(3,2),
    rating_votes INT DEFAULT 0,

    -- Reviews (NEW in v3.0)
    reviews_count INT DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign key
    FOREIGN KEY (brand_id) REFERENCES brands(id),

    -- Indexes
    INDEX idx_name (name(100)),
    INDEX idx_brand_id (brand_id),
    INDEX idx_brand_name (brand_name),
    INDEX idx_year (year),
    INDEX idx_gender (gender),
    INDEX idx_rating (rating_average DESC),
    INDEX idx_reviews (reviews_count DESC),

    -- Full-text index for searching
    FULLTEXT INDEX idx_search (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SUPPORTING TABLES
-- =============================================================================

-- Fragrance-Accord relationship (from accords field)
-- v3.0 format: accord_id:percentage;...
CREATE TABLE fragrance_accords (
    fragrance_id INT NOT NULL,
    accord_id VARCHAR(20) NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    sort_order TINYINT UNSIGNED,
    PRIMARY KEY (fragrance_id, accord_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (accord_id) REFERENCES accords(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Fragrance-Note relationship (from notes_pyramid field)
-- v3.0 format includes opacity and weight
CREATE TABLE fragrance_notes (
    fragrance_id INT NOT NULL,
    note_id VARCHAR(20) NOT NULL,
    layer ENUM('top', 'mid', 'base', 'notes') NOT NULL,
    opacity DECIMAL(3,2) DEFAULT 1.0,  -- NEW in v3.0
    weight DECIMAL(5,2) DEFAULT 1.0,   -- NEW in v3.0
    sort_order TINYINT UNSIGNED,
    PRIMARY KEY (fragrance_id, note_id, layer),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Fragrance-Perfumer relationship (from perfumers field)
-- Format: name1;id1;name2;id2;...
CREATE TABLE fragrance_perfumers (
    fragrance_id INT NOT NULL,
    perfumer_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (fragrance_id, perfumer_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (perfumer_id) REFERENCES perfumers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Voting tables (v3.0 format: category:votes:percent)
-- Now store both votes AND percent

-- Longevity votes (from longevity field)
CREATE TABLE fragrance_longevity (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sillage votes (from sillage field)
CREATE TABLE fragrance_sillage (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Gender votes (from gender_votes field)
CREATE TABLE fragrance_gender_votes (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Price value votes (from price_value field)
CREATE TABLE fragrance_price_votes (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Appreciation votes (from appreciation field)
CREATE TABLE fragrance_appreciation (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Season recommendations (from season field)
CREATE TABLE fragrance_seasons (
    fragrance_id INT NOT NULL,
    season VARCHAR(20) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, season),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Time of day (from time_of_day field)
CREATE TABLE fragrance_time_of_day (
    fragrance_id INT NOT NULL,
    time_period VARCHAR(20) NOT NULL,
    votes INT DEFAULT 0,
    percent DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, time_period),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- User photos (from user_photoes field)
CREATE TABLE fragrance_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fragrance_id INT NOT NULL,
    photo_url TEXT NOT NULL,
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    INDEX idx_fragrance (fragrance_id)
) ENGINE=InnoDB;

-- "Also like" relationships (from also_like field)
CREATE TABLE fragrance_also_like (
    fragrance_id INT NOT NULL,
    related_fragrance_id INT NOT NULL,
    PRIMARY KEY (fragrance_id, related_fragrance_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (related_fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- "Reminds of" relationships (from reminds_of field)
-- v3.0 format: pid:likes:dislikes
CREATE TABLE fragrance_reminds_of (
    fragrance_id INT NOT NULL,
    related_fragrance_id INT NOT NULL,
    likes INT DEFAULT 0,      -- NEW in v3.0
    dislikes INT DEFAULT 0,   -- NEW in v3.0
    PRIMARY KEY (fragrance_id, related_fragrance_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (related_fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Pros/Cons (NEW in v3.0 - from pros_cons field)
CREATE TABLE fragrance_pros_cons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fragrance_id INT NOT NULL,
    type ENUM('pros', 'cons') NOT NULL,
    text TEXT NOT NULL,
    likes INT DEFAULT 0,
    dislikes INT DEFAULT 0,
    sort_order TINYINT UNSIGNED,
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    INDEX idx_fragrance (fragrance_id),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- EXAMPLE QUERIES (v3.0 with JOINs)
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

-- Get fragrances with their accords (v3.0)
-- SELECT f.name, a.name AS accord, fa.percentage, a.bar_color
-- FROM fragrances f
-- JOIN fragrance_accords fa ON f.pid = fa.fragrance_id
-- JOIN accords a ON fa.accord_id = a.id
-- WHERE f.pid = 9828
-- ORDER BY fa.percentage DESC;

-- Get fragrances with their notes (v3.0)
-- SELECT f.name, fn.layer, n.name AS note, n.note_group, fn.opacity, fn.weight
-- FROM fragrances f
-- JOIN fragrance_notes fn ON f.pid = fn.fragrance_id
-- JOIN notes n ON fn.note_id = n.id
-- WHERE f.pid = 9828
-- ORDER BY fn.layer, fn.sort_order;

-- Full-text search
-- SELECT * FROM fragrances
-- WHERE MATCH(name, description) AGAINST('vanilla sweet' IN NATURAL LANGUAGE MODE);
