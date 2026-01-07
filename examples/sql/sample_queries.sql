-- FragDB Sample SQL Queries
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

-- Filter by brand
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

-- Rating distribution
SELECT
    CASE
        WHEN rating_average >= 4.5 THEN '4.5-5.0 (Excellent)'
        WHEN rating_average >= 4.0 THEN '4.0-4.5 (Very Good)'
        WHEN rating_average >= 3.5 THEN '3.5-4.0 (Good)'
        WHEN rating_average >= 3.0 THEN '3.0-3.5 (Average)'
        ELSE 'Below 3.0'
    END AS rating_tier,
    COUNT(*) AS fragrance_count
FROM fragrances
WHERE rating_average IS NOT NULL
GROUP BY rating_tier
ORDER BY rating_tier DESC;

-- =============================================================================
-- LONGEVITY & SILLAGE QUERIES
-- =============================================================================

-- Fragrances with "eternal" longevity rating
SELECT f.pid, f.name, f.brand_name, fl.percentage AS eternal_percentage
FROM fragrances f
JOIN fragrance_longevity fl ON f.pid = fl.fragrance_id
WHERE fl.category = 'eternal'
  AND fl.percentage >= 30
ORDER BY fl.percentage DESC
LIMIT 20;

-- Strong sillage fragrances
SELECT f.pid, f.name, f.brand_name, fs.percentage AS strong_percentage
FROM fragrances f
JOIN fragrance_sillage fs ON f.pid = fs.fragrance_id
WHERE fs.category = 'enormous'
  AND fs.percentage >= 20
ORDER BY fs.percentage DESC
LIMIT 20;

-- =============================================================================
-- PERFUMER QUERIES
-- =============================================================================

-- Fragrances by specific perfumer
SELECT f.pid, f.name, f.brand_name, f.year
FROM fragrances f
JOIN fragrance_perfumers fp ON f.pid = fp.fragrance_id
JOIN perfumers p ON fp.perfumer_id = p.id
WHERE p.name LIKE '%Jacques Polge%'
ORDER BY f.year DESC;

-- Most prolific perfumers
SELECT p.name, COUNT(*) AS fragrance_count
FROM perfumers p
JOIN fragrance_perfumers fp ON p.id = fp.perfumer_id
GROUP BY p.id, p.name
ORDER BY fragrance_count DESC
LIMIT 20;

-- =============================================================================
-- RELATED FRAGRANCES QUERIES
-- =============================================================================

-- Find "also like" fragrances (users who like this also like...)
SELECT f2.pid, f2.name, f2.brand_name
FROM fragrances f1
JOIN fragrance_also_like fal ON f1.pid = fal.fragrance_id
JOIN fragrances f2 ON fal.related_fragrance_id = f2.pid
WHERE f1.name = 'Aventus'
LIMIT 10;

-- Find "reminds of" fragrances (this fragrance reminds users of...)
SELECT f2.pid, f2.name, f2.brand_name
FROM fragrances f1
JOIN fragrance_reminds_of fro ON f1.pid = fro.fragrance_id
JOIN fragrances f2 ON fro.related_fragrance_id = f2.pid
WHERE f1.name = 'Aventus'
LIMIT 10;

-- =============================================================================
-- COMPLEX / RECOMMENDATION QUERIES
-- =============================================================================

-- Find highly-rated fragrances similar to user preferences
-- (woody accords, for men, good longevity)
SELECT DISTINCT f.pid, f.name, f.brand_name,
       f.rating_average, f.rating_votes
FROM fragrances f
JOIN fragrance_accords fa ON f.pid = fa.fragrance_id
JOIN accords a ON fa.accord_id = a.id
JOIN fragrance_longevity fl ON f.pid = fl.fragrance_id
WHERE f.gender = 'for men'
  AND a.name = 'woody'
  AND fa.percentage >= 20
  AND fl.category IN ('long lasting', 'very long lasting', 'eternal')
  AND fl.percentage >= 30
  AND f.rating_average >= 4.0
  AND f.rating_votes >= 100
ORDER BY f.rating_average DESC
LIMIT 20;

-- Niche vs Designer comparison
SELECT
    CASE
        WHEN brand_name IN ('Creed', 'Tom Ford', 'Byredo', 'Le Labo', 'Amouage', 'Xerjoff')
        THEN 'Niche'
        ELSE 'Designer'
    END AS category,
    COUNT(*) AS fragrance_count,
    ROUND(AVG(rating_average), 2) AS avg_rating,
    ROUND(AVG(rating_votes), 0) AS avg_votes
FROM fragrances
WHERE brand_name IS NOT NULL
GROUP BY category;
