/**
 * FragDB - Parse CSV Example (v3.0)
 *
 * Demonstrates how to load and parse the FragDB multi-file database in Node.js.
 * Now includes 5 CSV files: fragrances, brands, perfumers, notes, accords.
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
 * @returns {Object} Object with fragrances, brands, perfumers, notes, accords arrays
 */
function loadFragDB(samplesDir = '../../samples') {
  return {
    fragrances: loadCSV('fragrances.csv', samplesDir),
    brands: loadCSV('brands.csv', samplesDir),
    perfumers: loadCSV('perfumers.csv', samplesDir),
    notes: loadCSV('notes.csv', samplesDir),
    accords: loadCSV('accords.csv', samplesDir)
  };
}

/**
 * Parse the accords field into an array of objects (v3.0 format).
 * @param {string} accordsStr - Raw accords string (format: accord_id:percent;...)
 * @param {Map} accordsMap - Optional map of accord IDs to accord objects
 * @returns {Array<Object>} Parsed accords
 */
function parseAccords(accordsStr, accordsMap = null) {
  if (!accordsStr) return [];

  return accordsStr.split(';').map(accord => {
    const [id, percentage] = accord.split(':');
    const result = {
      id,
      percentage: parseInt(percentage, 10) || 0
    };

    // Look up name and colors from accords.csv if map provided
    if (accordsMap && accordsMap.has(id)) {
      const accordInfo = accordsMap.get(id);
      result.name = accordInfo.name;
      result.barColor = accordInfo.bar_color;
      result.fontColor = accordInfo.font_color;
    }

    return result;
  }).filter(a => a.id);
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
 * Parse the brand field.
 * @param {string} brandStr - Raw brand string (format: name;brand_id)
 * @returns {Object} Parsed brand info
 */
function parseBrand(brandStr) {
  if (!brandStr) return { name: '', id: '' };

  const [name, id] = brandStr.split(';');
  return { name: name || '', id: id || '' };
}

/**
 * Parse the perfumers field.
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
 * Parse voting fields (v3.0 format: category:votes:percent).
 * @param {string} fieldStr - Raw voting field string
 * @returns {Object} Object with category as key and {votes, percent} as value
 */
function parseVotingField(fieldStr) {
  if (!fieldStr) return {};

  const result = {};
  fieldStr.split(';').forEach(item => {
    const parts = item.split(':');
    if (parts.length >= 3) {
      result[parts[0]] = {
        votes: parseInt(parts[1], 10) || 0,
        percent: parseFloat(parts[2]) || 0
      };
    }
  });
  return result;
}

/**
 * Parse reminds_of field (v3.0 format: pid:likes:dislikes).
 * @param {string} remindsStr - Raw reminds_of string
 * @returns {Array<Object>} Array of {pid, likes, dislikes} objects
 */
function parseRemindsOf(remindsStr) {
  if (!remindsStr) return [];

  return remindsStr.split(';').map(item => {
    const parts = item.split(':');
    if (parts.length >= 3) {
      return {
        pid: parseInt(parts[0], 10) || 0,
        likes: parseInt(parts[1], 10) || 0,
        dislikes: parseInt(parts[2], 10) || 0
      };
    }
    return null;
  }).filter(Boolean);
}

/**
 * Create lookup maps for brands, perfumers, notes, and accords.
 * @param {Object} db - Database object from loadFragDB()
 * @returns {Object} Object with lookup maps
 */
function createLookupMaps(db) {
  return {
    brandsMap: new Map(db.brands.map(b => [b.id, b])),
    perfumersMap: new Map(db.perfumers.map(p => [p.id, p])),
    notesMap: new Map(db.notes.map(n => [n.id, n])),
    accordsMap: new Map(db.accords.map(a => [a.id, a]))
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
  const { fragrances, brands, perfumers, notes, accords } = db;
  const { brandsMap, perfumersMap, notesMap, accordsMap } = createLookupMaps(db);

  console.log('=== FragDB v4.3 Database ===\n');
  console.log(`Fragrances: ${fragrances.length} records`);
  console.log(`Brands: ${brands.length} records`);
  console.log(`Perfumers: ${perfumers.length} records`);
  console.log(`Notes: ${notes.length} records`);
  console.log(`Accords: ${accords.length} records\n`);

  // Display sample fragrances
  console.log('=== Sample Fragrances ===\n');
  fragrances.slice(0, 5).forEach(f => {
    const brand = parseBrand(f.brand);
    const rating = parseRating(f.rating);
    console.log(`${f.name} by ${brand.name}`);
    console.log(`  Brand ID: ${brand.id} (lookup in brands.csv)`);
    console.log(`  Year: ${f.year}, Gender: ${f.gender}`);
    console.log(`  Rating: ${rating.average.toFixed(2)} (${rating.votes.toLocaleString()} votes)`);
    console.log(`  Reviews: ${f.reviews_count || 0}`);
    console.log();
  });

  // Parse accords example (v3.0 format with lookup)
  console.log('=== Accords Example (v3.0) ===\n');
  const firstFragrance = fragrances[0];
  const accordsList = parseAccords(firstFragrance.accords, accordsMap);
  console.log(`Top accords for ${firstFragrance.name}:`);
  accordsList.slice(0, 5).forEach(a => {
    const name = a.name || a.id;
    const color = a.barColor ? ` ${a.barColor}` : '';
    console.log(`  ${name}: ${a.percentage}%${color}`);
  });
  console.log();

  // Parse voting fields (v3.0 format)
  console.log('=== Voting Fields (v3.0 format) ===\n');
  const longevity = parseVotingField(firstFragrance.longevity);
  console.log('Longevity:');
  Object.entries(longevity).forEach(([cat, data]) => {
    console.log(`  ${cat}: ${data.votes} votes (${data.percent}%)`);
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

  // Display sample notes (NEW in v3.0)
  console.log('=== Sample Notes (NEW in v3.0) ===\n');
  notes.slice(0, 5).forEach(n => {
    console.log(`${n.id}: ${n.name} (${n.group || 'N/A'}) - ${n.fragrance_count} fragrances`);
  });
  console.log();

  // Display sample accords (NEW in v3.0)
  console.log('=== Sample Accords (NEW in v3.0) ===\n');
  accords.slice(0, 5).forEach(a => {
    console.log(`${a.id}: ${a.name} ${a.bar_color} - ${a.fragrance_count} fragrances`);
  });
}

main();
