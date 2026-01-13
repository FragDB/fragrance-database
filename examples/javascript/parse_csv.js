/**
 * FragDB - Parse CSV Example (v2.0)
 *
 * Demonstrates how to load and parse the FragDB multi-file database in Node.js.
 */

const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

/**
 * Load a CSV file from the samples directory.
 * @param {string} filename - Name of the CSV file
 * @param {string} samplesDir - Path to samples directory
 * @returns {Array<Object>} Array of records
 */
function loadCSV(filename, samplesDir = '../../samples') {
  const filepath = path.join(samplesDir, filename);
  const content = fs.readFileSync(filepath, 'utf-8');

  return parse(content, {
    columns: true,
    delimiter: '|',
    skip_empty_lines: true,
    trim: true
  });
}

/**
 * Load all FragDB database files.
 * @param {string} samplesDir - Path to samples directory
 * @returns {Object} Object with fragrances, brands, and perfumers arrays
 */
function loadFragDB(samplesDir = '../../samples') {
  return {
    fragrances: loadCSV('fragrances.csv', samplesDir),
    brands: loadCSV('brands.csv', samplesDir),
    perfumers: loadCSV('perfumers.csv', samplesDir)
  };
}

/**
 * Parse the accords field into an array of objects.
 * @param {string} accordsStr - Raw accords string
 * @returns {Array<Object>} Parsed accords
 */
function parseAccords(accordsStr) {
  if (!accordsStr) return [];

  return accordsStr.split(';').map(accord => {
    const [name, percentage, bgColor, textColor] = accord.split(':');
    return {
      name,
      percentage: parseInt(percentage, 10) || 0,
      bgColor,
      textColor
    };
  }).filter(a => a.name);
}

/**
 * Parse the rating field.
 * @param {string} ratingStr - Raw rating string (format: average;count)
 * @returns {Object} Parsed rating
 */
function parseRating(ratingStr) {
  if (!ratingStr) return { average: 0, votes: 0 };

  const [average, votes] = ratingStr.split(';');
  return {
    average: parseFloat(average) || 0,
    votes: parseInt(votes, 10) || 0
  };
}

/**
 * Parse the brand field (v2.0 format).
 * @param {string} brandStr - Raw brand string (format: name;brand_id)
 * @returns {Object} Parsed brand info
 */
function parseBrand(brandStr) {
  if (!brandStr) return { name: '', id: '' };

  const [name, id] = brandStr.split(';');
  return { name: name || '', id: id || '' };
}

/**
 * Parse the perfumers field (v2.0 format).
 * @param {string} perfumersStr - Raw perfumers string (format: name1;id1;name2;id2;...)
 * @returns {Array<Object>} Array of perfumer objects
 */
function parsePerfumers(perfumersStr) {
  if (!perfumersStr) return [];

  const parts = perfumersStr.split(';');
  const perfumers = [];

  for (let i = 0; i < parts.length; i += 2) {
    if (i + 1 < parts.length) {
      perfumers.push({
        name: parts[i],
        id: parts[i + 1]
      });
    }
  }

  return perfumers;
}

/**
 * Create lookup maps for brands and perfumers.
 * @param {Object} db - Database object from loadFragDB()
 * @returns {Object} Object with brandsMap and perfumersMap
 */
function createLookupMaps(db) {
  return {
    brandsMap: new Map(db.brands.map(b => [b.id, b])),
    perfumersMap: new Map(db.perfumers.map(p => [p.id, p]))
  };
}

/**
 * Get full brand details for a fragrance.
 * @param {Object} fragrance - Fragrance record
 * @param {Map} brandsMap - Brands lookup map
 * @returns {Object} Brand details
 */
function getBrandDetails(fragrance, brandsMap) {
  const { id } = parseBrand(fragrance.brand);
  return brandsMap.get(id) || { name: parseBrand(fragrance.brand).name };
}

// Main execution
function main() {
  // Load database
  const db = loadFragDB();
  const { fragrances, brands, perfumers } = db;
  const { brandsMap, perfumersMap } = createLookupMaps(db);

  console.log('=== FragDB v2.0 Database ===\n');
  console.log(`Fragrances: ${fragrances.length} records`);
  console.log(`Brands: ${brands.length} records`);
  console.log(`Perfumers: ${perfumers.length} records\n`);

  // Display sample fragrances
  console.log('=== Sample Fragrances ===\n');
  fragrances.slice(0, 5).forEach(f => {
    const brand = parseBrand(f.brand);
    const rating = parseRating(f.rating);
    console.log(`${f.name} by ${brand.name}`);
    console.log(`  Brand ID: ${brand.id} (lookup in brands.csv)`);
    console.log(`  Year: ${f.year}, Gender: ${f.gender}`);
    console.log(`  Rating: ${rating.average.toFixed(2)} (${rating.votes.toLocaleString()} votes)`);
    console.log();
  });

  // Parse accords example
  console.log('=== Accords Example ===\n');
  const firstFragrance = fragrances[0];
  const accords = parseAccords(firstFragrance.accords);
  console.log(`Top accords for ${firstFragrance.name}:`);
  accords.slice(0, 5).forEach(a => {
    console.log(`  ${a.name}: ${a.percentage}%`);
  });
  console.log();

  // Example: Join with brand details
  console.log('=== Brand Details (from brands.csv) ===\n');
  const brandDetails = getBrandDetails(firstFragrance, brandsMap);
  if (brandDetails.country) {
    console.log(`Brand: ${brandDetails.name}`);
    console.log(`Country: ${brandDetails.country}`);
    console.log(`Website: ${brandDetails.website}`);
    console.log(`Fragrances: ${brandDetails.brand_count}`);
  }
  console.log();

  // Display sample brands
  console.log('=== Sample Brands ===\n');
  brands.slice(0, 3).forEach(b => {
    console.log(`${b.id}: ${b.name} (${b.country}) - ${b.brand_count} fragrances`);
  });
  console.log();

  // Display sample perfumers
  console.log('=== Sample Perfumers ===\n');
  perfumers.slice(0, 3).forEach(p => {
    console.log(`${p.id}: ${p.name} - ${p.company || 'Independent'}`);
    console.log(`  Fragrances: ${p.perfumes_count}`);
  });
}

main();
