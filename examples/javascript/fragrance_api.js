/**
 * FragDB - Simple REST API Example (v2.0)
 *
 * Demonstrates how to create a basic fragrance API using Express.
 * Run: npm install && node fragrance_api.js
 * Then visit: http://localhost:3000/api/fragrances
 */

const express = require('express');
const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

const app = express();
const PORT = 3000;

// Database state
let fragrances = [];
let brands = [];
let perfumers = [];
let brandsMap = new Map();
let perfumersMap = new Map();

/**
 * Load a CSV file.
 */
function loadCSV(filename, samplesDir = '../../samples') {
  const filepath = path.join(__dirname, samplesDir, filename);
  const content = fs.readFileSync(filepath, 'utf-8');
  return parse(content, {
    columns: true,
    delimiter: '|',
    skip_empty_lines: true,
    trim: true
  });
}

/**
 * Load all database files.
 */
function loadDatabase() {
  fragrances = loadCSV('fragrances.csv');
  brands = loadCSV('brands.csv');
  perfumers = loadCSV('perfumers.csv');

  // Create lookup maps
  brandsMap = new Map(brands.map(b => [b.id, b]));
  perfumersMap = new Map(perfumers.map(p => [p.id, p]));

  console.log(`Loaded ${fragrances.length} fragrances, ${brands.length} brands, ${perfumers.length} perfumers`);
}

/**
 * Parse brand field (v2.0 format: name;brand_id).
 */
function parseBrand(brandStr) {
  if (!brandStr) return { name: '', id: '' };
  const [name, id] = brandStr.split(';');
  return { name: name || '', id: id || '' };
}

/**
 * Parse rating field.
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
 * Parse accords field.
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
 * Parse perfumers field (v2.0 format: name1;id1;name2;id2;...).
 */
function parsePerfumers(perfumersStr) {
  if (!perfumersStr) return [];
  const parts = perfumersStr.split(';');
  const result = [];
  for (let i = 0; i < parts.length; i += 2) {
    if (i + 1 < parts.length) {
      const id = parts[i + 1];
      const details = perfumersMap.get(id) || {};
      result.push({
        name: parts[i],
        id: id,
        company: details.company || null,
        status: details.status || null
      });
    }
  }
  return result;
}

/**
 * Transform raw fragrance to API format.
 */
function transformFragrance(f, includeDetails = false) {
  const brandInfo = parseBrand(f.brand);
  const brandDetails = brandsMap.get(brandInfo.id) || {};

  const result = {
    id: parseInt(f.pid, 10),
    name: f.name,
    brand: {
      name: brandInfo.name,
      id: brandInfo.id
    },
    year: parseInt(f.year, 10) || null,
    gender: f.gender,
    rating: parseRating(f.rating),
    url: f.url
  };

  if (includeDetails) {
    result.brand.country = brandDetails.country || null;
    result.brand.website = brandDetails.website || null;
    result.brand.logo = brandDetails.logo_url || null;
    result.accords = parseAccords(f.accords);
    result.perfumers = parsePerfumers(f.perfumers);
  }

  return result;
}

// Routes

/**
 * GET /api/fragrances
 * Returns all fragrances with optional filtering.
 *
 * Query params:
 *   - q: Search by name
 *   - brand: Filter by brand name
 *   - brand_id: Filter by brand ID
 *   - gender: Filter by gender
 *   - country: Filter by brand country (v2.0)
 *   - year_min: Minimum year
 *   - year_max: Maximum year
 *   - limit: Max results (default 100)
 *   - offset: Skip results (default 0)
 */
app.get('/api/fragrances', (req, res) => {
  let results = [...fragrances];

  // Search by name
  if (req.query.q) {
    const q = req.query.q.toLowerCase();
    results = results.filter(f =>
      f.name && f.name.toLowerCase().includes(q)
    );
  }

  // Filter by brand name
  if (req.query.brand) {
    const brand = req.query.brand.toLowerCase();
    results = results.filter(f => {
      const brandName = f.brand ? f.brand.split(';')[0].toLowerCase() : '';
      return brandName.includes(brand);
    });
  }

  // Filter by brand ID (v2.0)
  if (req.query.brand_id) {
    results = results.filter(f =>
      f.brand && f.brand.endsWith(`;${req.query.brand_id}`)
    );
  }

  // Filter by gender
  if (req.query.gender) {
    results = results.filter(f => f.gender === req.query.gender);
  }

  // Filter by country (v2.0)
  if (req.query.country) {
    const country = req.query.country.toLowerCase();
    results = results.filter(f => {
      const brandId = f.brand ? f.brand.split(';')[1] : '';
      const brandDetails = brandsMap.get(brandId);
      return brandDetails && brandDetails.country &&
        brandDetails.country.toLowerCase().includes(country);
    });
  }

  // Filter by year range
  if (req.query.year_min) {
    const minYear = parseInt(req.query.year_min, 10);
    results = results.filter(f => parseInt(f.year, 10) >= minYear);
  }
  if (req.query.year_max) {
    const maxYear = parseInt(req.query.year_max, 10);
    results = results.filter(f => parseInt(f.year, 10) <= maxYear);
  }

  // Pagination
  const limit = Math.min(parseInt(req.query.limit, 10) || 100, 1000);
  const offset = parseInt(req.query.offset, 10) || 0;

  const total = results.length;
  results = results.slice(offset, offset + limit);

  res.json({
    total,
    limit,
    offset,
    data: results.map(f => transformFragrance(f, false))
  });
});

/**
 * GET /api/fragrances/:id
 * Returns a single fragrance by ID with full details.
 */
app.get('/api/fragrances/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const fragrance = fragrances.find(f => parseInt(f.pid, 10) === id);

  if (!fragrance) {
    return res.status(404).json({ error: 'Fragrance not found' });
  }

  res.json(transformFragrance(fragrance, true));
});

/**
 * GET /api/brands
 * Returns all brands.
 */
app.get('/api/brands', (req, res) => {
  let results = [...brands];

  // Filter by country
  if (req.query.country) {
    const country = req.query.country.toLowerCase();
    results = results.filter(b =>
      b.country && b.country.toLowerCase().includes(country)
    );
  }

  // Pagination
  const limit = Math.min(parseInt(req.query.limit, 10) || 100, 1000);
  const offset = parseInt(req.query.offset, 10) || 0;

  const total = results.length;
  results = results.slice(offset, offset + limit);

  res.json({
    total,
    limit,
    offset,
    data: results.map(b => ({
      id: b.id,
      name: b.name,
      country: b.country,
      main_activity: b.main_activity,
      website: b.website,
      parent_company: b.parent_company,
      fragrance_count: parseInt(b.brand_count, 10) || 0
    }))
  });
});

/**
 * GET /api/brands/:id
 * Returns a single brand by ID.
 */
app.get('/api/brands/:id', (req, res) => {
  const brand = brandsMap.get(req.params.id);

  if (!brand) {
    return res.status(404).json({ error: 'Brand not found' });
  }

  res.json({
    id: brand.id,
    name: brand.name,
    url: brand.url,
    logo_url: brand.logo_url,
    country: brand.country,
    main_activity: brand.main_activity,
    website: brand.website,
    parent_company: brand.parent_company,
    fragrance_count: parseInt(brand.brand_count, 10) || 0
  });
});

/**
 * GET /api/perfumers
 * Returns all perfumers.
 */
app.get('/api/perfumers', (req, res) => {
  let results = [...perfumers];

  // Filter by company
  if (req.query.company) {
    const company = req.query.company.toLowerCase();
    results = results.filter(p =>
      p.company && p.company.toLowerCase().includes(company)
    );
  }

  // Pagination
  const limit = Math.min(parseInt(req.query.limit, 10) || 100, 1000);
  const offset = parseInt(req.query.offset, 10) || 0;

  const total = results.length;
  results = results.slice(offset, offset + limit);

  res.json({
    total,
    limit,
    offset,
    data: results.map(p => ({
      id: p.id,
      name: p.name,
      status: p.status,
      company: p.company,
      fragrance_count: parseInt(p.perfumes_count, 10) || 0
    }))
  });
});

/**
 * GET /api/perfumers/:id
 * Returns a single perfumer by ID.
 */
app.get('/api/perfumers/:id', (req, res) => {
  const perfumer = perfumersMap.get(req.params.id);

  if (!perfumer) {
    return res.status(404).json({ error: 'Perfumer not found' });
  }

  res.json({
    id: perfumer.id,
    name: perfumer.name,
    url: perfumer.url,
    photo_url: perfumer.photo_url,
    status: perfumer.status,
    company: perfumer.company,
    also_worked: perfumer.also_worked,
    education: perfumer.education,
    web: perfumer.web,
    fragrance_count: parseInt(perfumer.perfumes_count, 10) || 0
  });
});

/**
 * GET /api/stats
 * Returns database statistics.
 */
app.get('/api/stats', (req, res) => {
  const uniqueBrands = new Set(fragrances.map(f => f.brand ? f.brand.split(';')[0] : ''));
  const genders = new Set(fragrances.map(f => f.gender));
  const years = fragrances.map(f => parseInt(f.year, 10)).filter(y => !isNaN(y));
  const countries = new Set(brands.map(b => b.country).filter(Boolean));

  res.json({
    total_fragrances: fragrances.length,
    total_brands: brands.length,
    total_perfumers: perfumers.length,
    unique_brands_in_fragrances: uniqueBrands.size,
    countries: Array.from(countries).sort(),
    genders: Array.from(genders).filter(Boolean),
    year_range: {
      min: Math.min(...years),
      max: Math.max(...years)
    }
  });
});

// Start server
loadDatabase();
app.listen(PORT, () => {
  console.log(`FragDB v2.0 API running at http://localhost:${PORT}`);
  console.log('\nEndpoints:');
  console.log('  GET /api/fragrances      - List fragrances (with filters)');
  console.log('  GET /api/fragrances/:id  - Get single fragrance');
  console.log('  GET /api/brands          - List brands');
  console.log('  GET /api/brands/:id      - Get single brand');
  console.log('  GET /api/perfumers       - List perfumers');
  console.log('  GET /api/perfumers/:id   - Get single perfumer');
  console.log('  GET /api/stats           - Database statistics');
});
