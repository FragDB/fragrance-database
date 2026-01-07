/**
 * FragDB - Search Example
 *
 * Demonstrates how to search and filter fragrances in Node.js.
 */

const fs = require('fs');
const { parse } = require('csv-parse/sync');

/**
 * Load the FragDB database from CSV file.
 */
function loadFragDB(filepath = '../../SAMPLE.csv') {
  const content = fs.readFileSync(filepath, 'utf-8');
  return parse(content, {
    columns: true,
    delimiter: '|',
    skip_empty_lines: true,
    trim: true
  });
}

/**
 * Search fragrances by name (case-insensitive).
 */
function searchByName(fragrances, query) {
  const lowerQuery = query.toLowerCase();
  return fragrances.filter(f =>
    f.name && f.name.toLowerCase().includes(lowerQuery)
  );
}

/**
 * Search fragrances by brand name.
 */
function searchByBrand(fragrances, brand) {
  const lowerBrand = brand.toLowerCase();
  return fragrances.filter(f => {
    if (!f.brand) return false;
    const brandName = f.brand.split(';')[0].toLowerCase();
    return brandName.includes(lowerBrand);
  });
}

/**
 * Filter fragrances by gender.
 */
function filterByGender(fragrances, gender) {
  return fragrances.filter(f => f.gender === gender);
}

/**
 * Filter fragrances by year range.
 */
function filterByYearRange(fragrances, startYear, endYear) {
  return fragrances.filter(f => {
    const year = parseInt(f.year, 10);
    return year >= startYear && year <= endYear;
  });
}

/**
 * Filter fragrances by minimum rating.
 */
function filterByRating(fragrances, minRating) {
  return fragrances.filter(f => {
    if (!f.rating) return false;
    const rating = parseFloat(f.rating.split(';')[0]);
    return rating >= minRating;
  });
}

/**
 * Get top rated fragrances.
 */
function getTopRated(fragrances, n = 10) {
  return [...fragrances]
    .map(f => ({
      ...f,
      ratingValue: f.rating ? parseFloat(f.rating.split(';')[0]) : 0
    }))
    .sort((a, b) => b.ratingValue - a.ratingValue)
    .slice(0, n);
}

/**
 * Search fragrances by accord.
 */
function searchByAccord(fragrances, accord) {
  const lowerAccord = accord.toLowerCase();
  return fragrances.filter(f => {
    if (!f.accords) return false;
    return f.accords.toLowerCase().includes(lowerAccord);
  });
}

/**
 * Helper to format brand name.
 */
function getBrandName(brandStr) {
  if (!brandStr) return '';
  return brandStr.split(';')[0];
}

// Main execution
function main() {
  const fragrances = loadFragDB();
  console.log(`Loaded ${fragrances.length} fragrances\n`);

  // Search by name
  console.log('=== Search by Name ===');
  const nameResults = searchByName(fragrances, 'eau');
  console.log(`Found ${nameResults.length} fragrances with "eau" in name:`);
  nameResults.slice(0, 3).forEach(f => {
    console.log(`  - ${f.name} by ${getBrandName(f.brand)}`);
  });
  console.log();

  // Search by brand
  console.log('=== Search by Brand ===');
  const brandResults = searchByBrand(fragrances, 'Dior');
  console.log(`Found ${brandResults.length} Dior fragrances:`);
  brandResults.slice(0, 3).forEach(f => {
    console.log(`  - ${f.name} (${f.year})`);
  });
  console.log();

  // Filter by gender
  console.log('=== Filter by Gender ===');
  const unisex = filterByGender(fragrances, 'for women and men');
  console.log(`Found ${unisex.length} unisex fragrances`);
  console.log();

  // Top rated
  console.log('=== Top Rated ===');
  const topRated = getTopRated(fragrances, 5);
  topRated.forEach((f, i) => {
    console.log(`${i + 1}. ${f.name} - Rating: ${f.ratingValue.toFixed(2)}`);
  });
  console.log();

  // Search by accord
  console.log('=== Search by Accord ===');
  const woodyFragrances = searchByAccord(fragrances, 'woody');
  console.log(`Found ${woodyFragrances.length} fragrances with woody accords`);
}

main();
