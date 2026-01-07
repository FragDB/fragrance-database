-- FragDB MySQL Schema
--
-- This schema demonstrates how to import and structure the FragDB
-- fragrance database in MySQL/MariaDB.
--
-- For the full database with 119,000+ fragrances, visit https://fragdb.net

-- Main fragrances table
CREATE TABLE fragrances (
    pid INT PRIMARY KEY,
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
    rating_votes INT DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_name (name(100)),
    INDEX idx_brand (brand_name),
    INDEX idx_year (year),
    INDEX idx_gender (gender),
    INDEX idx_rating (rating_average DESC),

    -- Full-text index for searching
    FULLTEXT INDEX idx_search (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Accords table (many-to-many relationship)
CREATE TABLE accords (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- Notes table (many-to-many with layer info)
CREATE TABLE notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    url TEXT,
    image TEXT,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fragrance_notes (
    fragrance_id INT NOT NULL,
    note_id INT NOT NULL,
    layer ENUM('top', 'mid', 'base', 'notes') NOT NULL,
    sort_order TINYINT UNSIGNED,
    PRIMARY KEY (fragrance_id, note_id, layer),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Longevity votes
CREATE TABLE fragrance_longevity (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sillage votes
CREATE TABLE fragrance_sillage (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Gender votes
CREATE TABLE fragrance_gender_votes (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Price value votes
CREATE TABLE fragrance_price_votes (
    fragrance_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (fragrance_id, category),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Seasons
CREATE TABLE fragrance_seasons (
    fragrance_id INT NOT NULL,
    season VARCHAR(20) NOT NULL,
    percentage TINYINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (fragrance_id, season),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Perfumers
CREATE TABLE perfumers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    url TEXT,
    INDEX idx_name (name(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fragrance_perfumers (
    fragrance_id INT NOT NULL,
    perfumer_id INT NOT NULL,
    PRIMARY KEY (fragrance_id, perfumer_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (perfumer_id) REFERENCES perfumers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Collections
CREATE TABLE collections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fragrance_collections (
    fragrance_id INT NOT NULL,
    collection_id INT NOT NULL,
    PRIMARY KEY (fragrance_id, collection_id),
    FOREIGN KEY (fragrance_id) REFERENCES fragrances(pid) ON DELETE CASCADE,
    FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- User photos
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

-- Example: Full-text search query
-- SELECT * FROM fragrances
-- WHERE MATCH(name, description) AGAINST('vanilla sweet' IN NATURAL LANGUAGE MODE);
