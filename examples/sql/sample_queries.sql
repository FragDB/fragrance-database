-- FragDB v4.3 Sample SQL Queries
--
-- These queries work with both PostgreSQL and MySQL schemas.
-- Adjust syntax as needed for your specific database.

-- =============================================================================
-- BASIC QUERIES
-- =============================================================================

-- Get all fragrances (limited)
SELECT pid, name, brand_name, year, gender, rating_average
FROM fragrances
LIMIT 100;

-- Search by name (case-insensitive)
SELECT pid, name, brand_name, year
FROM fragrances
WHERE LOWER(name) LIKE '%aventus%';

-- Filter by brand (using denormalized brand_name)
SELECT pid, name, year, gender, rating_average
FROM fragrances
WHERE brand_name = 'Chanel'
ORDER BY rating_average DESC;

-- Filter by gender
SELECT pid, name, brand_name, year
FROM fragrances
WHERE gender = 'for women and men'
ORDER BY year DESC;

-- Filter by year range
SELECT pid, name, brand_name, year, rating_average
FROM fragrances
WHERE year BETWEEN 2020 AND 2026
ORDER BY rating_average DESC;

-- =============================================================================
-- JOIN QUERIES (v2.0 - using brands and perfumers tables)
-- =============================================================================

-- Get fragrances with full brand details
SELECT f.pid, f.name, b.name AS brand, b.country, b.website, b.parent_company
FROM fragrances f
JOIN brands b ON f.brand_id = b.id
LIMIT 50;

-- Filter by brand country
SELECT f.pid, f.name, f.year, b.name AS brand, b.country
FROM fragrances f
JOIN brands b ON f.brand_id = b.id
WHERE b.country = 'France'
ORDER BY f.rating_average DESC
LIMIT 20;

-- Filter by parent company (e.g., all LVMH brands)
SELECT f.pid, f.name, b.name AS brand, f.rating_average
FROM fragrances f
JOIN brands b ON f.brand_id = b.id
WHERE b.parent_company LIKE '%LVMH%'
ORDER BY f.rating_average DESC;

-- Get fragrances with perfumer details
SELECT f.pid, f.name, p.name AS perfumer, p.company, p.status
FROM fragrances f
JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
JOIN perfumers p ON fp.perfumer_id = p.id
LIMIT 50;

-- Filter by perfumer company
SELECT f.pid, f.name, f.year, p.name AS perfumer
FROM fragrances f
JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
JOIN perfumers p ON fp.perfumer_id = p.id
WHERE p.company = 'Firmenich'
ORDER BY f.year DESC;

-- =============================================================================
-- TOP RATED QUERIES
-- =============================================================================

-- Top 10 rated fragrances (minimum 1000 votes)
SELECT pid, name, brand_name, year, rating_average, rating_votes
FROM fragrances
WHERE rating_votes >= 1000
ORDER BY rating_average DESC
LIMIT 10;

-- Top rated by brand
SELECT pid, name, year, rating_average, rating_votes
FROM fragrances
WHERE brand_name = 'Dior'
  AND rating_votes >= 100
ORDER BY rating_average DESC
LIMIT 10;

-- Top rated by gender category
SELECT pid, name, brand_name, rating_average, rating_votes
FROM fragrances
WHERE gender = 'for men'
  AND rating_votes >= 500
ORDER BY rating_average DESC
LIMIT 10;

-- =============================================================================
-- BRAND STATISTICS (v2.0)
-- =============================================================================

-- Top brands by fragrance count
SELECT b.id, b.name, b.country, b.brand_count
FROM brands b
ORDER BY b.brand_count DESC
LIMIT 20;

-- Brands by country
SELECT b.country, COUNT(*) AS brand_count, SUM(b.brand_count) AS total_fragrances
FROM brands b
WHERE b.country IS NOT NULL
GROUP BY b.country
ORDER BY total_fragrances DESC;

-- Top brands by average rating
SELECT b.name, b.country,
       COUNT(*) AS fragrance_count,
       ROUND(AVG(f.rating_average), 2) AS avg_rating
FROM brands b
JOIN fragrances f ON b.id = f.brand_id
WHERE f.rating_average IS NOT NULL
GROUP BY b.id, b.name, b.country
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC
LIMIT 20;

-- =============================================================================
-- PERFUMER STATISTICS (v2.0)
-- =============================================================================

-- Top perfumers by creation count
SELECT p.id, p.name, p.company, p.status, p.perfumes_count
FROM perfumers p
ORDER BY p.perfumes_count DESC
LIMIT 20;

-- Perfumers by company
SELECT p.company, COUNT(*) AS perfumer_count, SUM(p.perfumes_count) AS total_fragrances
FROM perfumers p
WHERE p.company IS NOT NULL
GROUP BY p.company
ORDER BY total_fragrances DESC;

-- Master Perfumers
SELECT p.name, p.company, p.perfumes_count
FROM perfumers p
WHERE p.status = 'Master Perfumer'
ORDER BY p.perfumes_count DESC;

-- =============================================================================
-- ACCORD QUERIES
-- =============================================================================

-- Find fragrances with specific accord
SELECT f.pid, f.name, f.brand_name, a.name AS accord, fa.percentage
FROM fragrances f
JOIN fragrance_accords fa ON f.pid = fa.fragrance_id
JOIN accords a ON fa.accord_id = a.id
WHERE a.name = 'woody'
ORDER BY fa.percentage DESC
LIMIT 20;

-- Fragrances with multiple specific accords
SELECT f.pid, f.name, f.brand_name, COUNT(*) AS matching_accords
FROM fragrances f
JOIN fragrance_accords fa ON f.pid = fa.fragrance_id
JOIN accords a ON fa.accord_id = a.id
WHERE a.name IN ('citrus', 'fresh', 'aromatic')
GROUP BY f.pid, f.name, f.brand_name
HAVING COUNT(*) >= 2
ORDER BY matching_accords DESC;

-- Top accords across all fragrances
SELECT a.name, COUNT(*) AS fragrance_count, AVG(fa.percentage) AS avg_percentage
FROM accords a
JOIN fragrance_accords fa ON a.id = fa.accord_id
GROUP BY a.id, a.name
ORDER BY fragrance_count DESC
LIMIT 20;

-- =============================================================================
-- NOTE QUERIES
-- =============================================================================

-- Find fragrances with specific top note
SELECT f.pid, f.name, f.brand_name, n.name AS note
FROM fragrances f
JOIN fragrance_notes fn ON f.pid = fn.fragrance_id
JOIN notes n ON fn.note_id = n.id
WHERE fn.layer = 'top'
  AND n.name = 'bergamot'
LIMIT 20;

-- Fragrances with specific base note
SELECT f.pid, f.name, f.brand_name
FROM fragrances f
JOIN fragrance_notes fn ON f.pid = fn.fragrance_id
JOIN notes n ON fn.note_id = n.id
WHERE fn.layer = 'base'
  AND LOWER(n.name) LIKE '%vanilla%';

-- Most common notes by layer
SELECT fn.layer, n.name, COUNT(*) AS occurrence
FROM fragrance_notes fn
JOIN notes n ON fn.note_id = n.id
GROUP BY fn.layer, n.name
ORDER BY fn.layer, occurrence DESC;

-- =============================================================================
-- STATISTICS QUERIES
-- =============================================================================

-- Count by brand
SELECT brand_name, COUNT(*) AS fragrance_count
FROM fragrances
WHERE brand_name IS NOT NULL
GROUP BY brand_name
ORDER BY fragrance_count DESC
LIMIT 20;

-- Count by year
SELECT year, COUNT(*) AS fragrance_count
FROM fragrances
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year DESC;

-- Count by gender
SELECT gender, COUNT(*) AS fragrance_count
FROM fragrances
GROUP BY gender
ORDER BY fragrance_count DESC;

-- Average rating by brand (minimum 10 fragrances)
SELECT brand_name,
       COUNT(*) AS fragrance_count,
       ROUND(AVG(rating_average), 2) AS avg_rating,
       SUM(rating_votes) AS total_votes
FROM fragrances
WHERE brand_name IS NOT NULL
GROUP BY brand_name
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC
LIMIT 20;

-- =============================================================================
-- PERFUMER QUERIES
-- =============================================================================

-- Fragrances by specific perfumer
SELECT f.pid, f.name, f.brand_name, f.year, p.status
FROM fragrances f
JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
JOIN perfumers p ON fp.perfumer_id = p.id
WHERE p.name LIKE '%Alberto Morillas%'
ORDER BY f.year DESC;

-- Most prolific perfumers (calculated from junction table)
SELECT p.name, p.company, COUNT(*) AS fragrance_count
FROM perfumers p
JOIN fragrance_perfumers fp ON p.id = fp.perfumer_id
GROUP BY p.id, p.name, p.company
ORDER BY fragrance_count DESC
LIMIT 20;

-- Perfumer collaborations (fragrances with multiple perfumers)
SELECT f.pid, f.name,
       GROUP_CONCAT(p.name ORDER BY p.name SEPARATOR ', ') AS perfumers
FROM fragrances f
JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
JOIN perfumers p ON fp.perfumer_id = p.id
GROUP BY f.pid, f.name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;

-- =============================================================================
-- COMPLEX / RECOMMENDATION QUERIES
-- =============================================================================

-- Find highly-rated fragrances similar to user preferences
-- (woody accords, for men, good longevity, French brand)
SELECT DISTINCT f.pid, f.name, f.brand_name, b.country,
       f.rating_average, f.rating_votes
FROM fragrances f
JOIN brands b ON f.brand_id = b.id
JOIN fragrance_accords fa ON f.pid = fa.fragrance_id
JOIN accords a ON fa.accord_id = a.id
JOIN fragrance_longevity fl ON f.pid = fl.fragrance_id
WHERE f.gender = 'for men'
  AND a.name = 'woody'
  AND fa.percentage >= 20
  AND fl.category IN ('long lasting', 'very long lasting', 'eternal')
  AND fl.votes >= 30
  AND f.rating_average >= 4.0
  AND f.rating_votes >= 100
  AND b.country = 'France'
ORDER BY f.rating_average DESC
LIMIT 20;

-- Find fragrances by Master Perfumers from specific company
SELECT f.pid, f.name, f.brand_name, f.year,
       p.name AS perfumer, p.company
FROM fragrances f
JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
JOIN perfumers p ON fp.perfumer_id = p.id
WHERE p.status = 'Master Perfumer'
  AND p.company = 'Firmenich'
  AND f.rating_average >= 4.0
ORDER BY f.rating_average DESC
LIMIT 20;

-- Compare niche vs designer brands
SELECT
    CASE
        WHEN b.parent_company IS NULL OR b.parent_company = '' THEN 'Niche/Independent'
        ELSE 'Designer/Corporate'
    END AS category,
    COUNT(*) AS fragrance_count,
    ROUND(AVG(f.rating_average), 2) AS avg_rating,
    ROUND(AVG(f.rating_votes), 0) AS avg_votes
FROM fragrances f
JOIN brands b ON f.brand_id = b.id
WHERE f.rating_average IS NOT NULL
GROUP BY category;
