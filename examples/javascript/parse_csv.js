/**
 * FragDB - Parse CSV Example
 *
 * Demonstrates how to load and parse the FragDB fragrance database in Node.js.
 */

const fs = require('fs');
const { parse } = require('csv-parse/sync');

/**
 * Load the FragDB database from CSV file.
 * @param {string} filepath - Path to the CSV file
 * @returns {Array<Object>} Array of fragrance records
 */
function loadFragDB(filepath = '../../SAMPLE.csv') {
  const content = fs.readFileSync(filepath, 'utf-8');

  const records = parse(content, {
    columns: true,
    delimiter: '|',
    skip_empty_lines: true,
    trim: true
  });

  return records;
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
 * Parse the brand field.
 * @param {string} brandStr - Raw brand string (format: name;url;logo)
 * @returns {Object} Parsed brand info
 */
function parseBrand(brandStr) {
  if (!brandStr) return { name: '', url: '', logo: '' };

  const [name, url, logo] = brandStr.split(';');
  return { name: name || '', url: url || '', logo: logo || '' };
}

// Main execution
function main() {
  // Load database
  const fragrances = loadFragDB();
  console.log(`Loaded ${fragrances.length} fragrances\n`);

  // Display sample
  console.log('=== Sample Fragrances ===\n');
  fragrances.slice(0, 5).forEach(f => {
    const brand = parseBrand(f.brand);
    const rating = parseRating(f.rating);
    console.log(`${f.name} by ${brand.name}`);
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
}

main();
