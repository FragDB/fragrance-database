-- FragDB v2.0 MySQL Schema
--
-- This schema demonstrates how to import and structure the FragDB
-- multi-file fragrance database in MySQL/MariaDB.
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

-- =============================================================================
-- MAIN FRAGRANCES TABLE (from fragrances.csv - 28 fields)
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

    -- Brand reference (v2.0: uses brand_id from brands table)
    brand_id VARCHAR(20),
    brand_name VARCHAR(255),  -- Denormalized for performance

    -- Rating (parsed from rating field: average;votes)
    rating_average DECIMAL(3,2),
    rating_votes INT DEFAULT 0,

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

    -- Full-text index for searching
    FULLTEXT INDEX idx_search (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SUPPORTING TABLES
-- =============================================================================

-- Accords reference table
CREATE TABLE accords (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fragrance-Accord relationship (from accords field)
CREATE TABLE fragrance_accords (
    fragrance_id INT NOT NULL,
    accord_id INT NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    bg_color VARCHAR(20),
    text_color VARCHAR(20),
    sort_order TINYINT UNSIGNED,
    PRIMARY KEY (fragrance_id, accord_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (accord_id) REFERENCES accords(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Notes reference table
CREATE TABLE notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    url TEXT,
    image TEXT,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fragrance-Note relationship (from notes_pyramid field)
CREATE TABLE fragrance_notes (
    fragrance_id INT NOT NULL,
    note_id INT NOT NULL,
    layer ENUM('top', 'mid', 'base', 'notes') NOT NULL,
    sort_order TINYINT UNSIGNED,
    PRIMARY KEY (fragrance_id, note_id, layer),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Fragrance-Perfumer relationship (from perfumers field)
-- Format (v2.0): name1;id1;name2;id2;...
CREATE TABLE fragrance_perfumers (
    fragrance_id INT NOT NULL,
    perfumer_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (fragrance_id, perfumer_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (perfumer_id) REFERENCES perfumers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Longevity votes (from longevity field)
CREATE TABLE fragrance_longevity (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sillage votes (from sillage field)
CREATE TABLE fragrance_sillage (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Gender votes (from gender_votes field)
CREATE TABLE fragrance_gender_votes (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Price value votes (from price_value field)
CREATE TABLE fragrance_price_votes (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    votes INT DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Season recommendations (from season field)
CREATE TABLE fragrance_seasons (
    fragrance_id INT NOT NULL,
    season VARCHAR(20) NOT NULL,
    percentage DECIMAL(5,2) DEFAULT 0,
    PRIMARY KEY (fragrance_id, season),
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
CREATE TABLE fragrance_reminds_of (
    fragrance_id INT NOT NULL,
    related_fragrance_id INT NOT NULL,
    PRIMARY KEY (fragrance_id, related_fragrance_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (related_fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

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
-- WHERE MATCH(name, description) AGAINST('vanilla sweet' IN NATURAL LANGUAGE MODE);
