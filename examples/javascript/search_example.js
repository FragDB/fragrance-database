/**
 * FragDB - Search Example (v2.0)
 *
 * Demonstrates how to search and filter fragrances in Node.js.
 */

const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

/**
 * Load a CSV file.
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
 */
function loadFragDB(samplesDir = '../../samples') {
  return {
    fragrances: loadCSV('fragrances.csv', samplesDir),
    brands: loadCSV('brands.csv', samplesDir),
    perfumers: loadCSV('perfumers.csv', samplesDir)
  };
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
 * Brand field format (v2.0): brand_name;brand_id
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
 * Search fragrances by brand ID.
 */
function searchByBrandId(fragrances, brandId) {
  return fragrances.filter(f => {
    if (!f.brand) return false;
    return f.brand.endsWith(`;${brandId}`);
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
 * Search fragrances by country (requires joining with brands).
 */
function searchByCountry(fragrances, brands, country) {
  // Create brand ID to country map
  const brandCountryMap = new Map(
    brands.map(b => [b.id, b.country])
  );

  return fragrances.filter(f => {
    if (!f.brand) return false;
    const brandId = f.brand.split(';')[1];
    const brandCountry = brandCountryMap.get(brandId);
    return brandCountry && brandCountry.toLowerCase().includes(country.toLowerCase());
  });
}

/**
 * Helper to get brand name from brand field.
 * Brand field format (v2.0): brand_name;brand_id
 */
function getBrandName(brandStr) {
  if (!brandStr) return '';
  return brandStr.split(';')[0];
}

/**
 * Helper to get brand ID from brand field.
 */
function getBrandId(brandStr) {
  if (!brandStr) return '';
  const parts = brandStr.split(';');
  return parts[1] || '';
}

// Main execution
function main() {
  const db = loadFragDB();
  const { fragrances, brands, perfumers } = db;

  console.log('=== FragDB v2.0 Search Examples ===\n');
  console.log(`Loaded ${fragrances.length} fragrances, ${brands.length} brands, ${perfumers.length} perfumers\n`);

  // Search by name
  console.log('=== Search by Name ===');
  const nameResults = searchByName(fragrances, 'black');
  console.log(`Found ${nameResults.length} fragrances with "black" in name:`);
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
  console.log();

  // v2.0 feature: Search by country
  console.log('=== Search by Country (v2.0 feature) ===');
  const frenchBrandFragrances = searchByCountry(fragrances, brands, 'France');
  console.log(`Found ${frenchBrandFragrances.length} fragrances from French brands:`);
  frenchBrandFragrances.slice(0, 3).forEach(f => {
    console.log(`  - ${f.name} by ${getBrandName(f.brand)}`);
  });
}

main();
