/**
 * FragDB - Simple REST API Example
 *
 * Demonstrates how to create a basic fragrance API using Express.
 * Run: npm install && node fragrance_api.js
 * Then visit: http://localhost:3000/api/fragrances
 */

const express = require('express');
const fs = require('fs');
const { parse } = require('csv-parse/sync');

const app = express();
const PORT = 3000;

// Load database on startup
let fragrances = [];

function loadDatabase() {
  const content = fs.readFileSync('../../SAMPLE.csv', 'utf-8');
  fragrances = parse(content, {
    columns: true,
    delimiter: '|',
    skip_empty_lines: true,
    trim: true
  });
  console.log(`Loaded ${fragrances.length} fragrances`);
}

/**
 * Parse brand field.
 */
function parseBrand(brandStr) {
  if (!brandStr) return { name: '', url: '', logo: '' };
  const [name, url, logo] = brandStr.split(';');
  return { name: name || '', url: url || '', logo: logo || '' };
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
 * Transform raw fragrance to API format.
 */
function transformFragrance(f) {
  return {
    id: parseInt(f.pid, 10),
    name: f.name,
    brand: parseBrand(f.brand),
    year: parseInt(f.year, 10) || null,
    gender: f.gender,
    rating: parseRating(f.rating),
    accords: parseAccords(f.accords),
    url: f.url
  };
}

// Routes

/**
 * GET /api/fragrances
 * Returns all fragrances with optional filtering.
 *
 * Query params:
 *   - q: Search by name
 *   - brand: Filter by brand
 *   - gender: Filter by gender
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

  // Filter by brand
  if (req.query.brand) {
    const brand = req.query.brand.toLowerCase();
    results = results.filter(f => {
      const brandName = f.brand ? f.brand.split(';')[0].toLowerCase() : '';
      return brandName.includes(brand);
    });
  }

  // Filter by gender
  if (req.query.gender) {
    results = results.filter(f => f.gender === req.query.gender);
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
    data: results.map(transformFragrance)
  });
});

/**
 * GET /api/fragrances/:id
 * Returns a single fragrance by ID.
 */
app.get('/api/fragrances/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const fragrance = fragrances.find(f => parseInt(f.pid, 10) === id);

  if (!fragrance) {
    return res.status(404).json({ error: 'Fragrance not found' });
  }

  res.json(transformFragrance(fragrance));
});

/**
 * GET /api/stats
 * Returns database statistics.
 */
app.get('/api/stats', (req, res) => {
  const brands = new Set(fragrances.map(f => f.brand ? f.brand.split(';')[0] : ''));
  const genders = new Set(fragrances.map(f => f.gender));
  const years = fragrances.map(f => parseInt(f.year, 10)).filter(y => !isNaN(y));

  res.json({
    total_fragrances: fragrances.length,
    unique_brands: brands.size,
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
  console.log(`FragDB API running at http://localhost:${PORT}`);
  console.log('\nEndpoints:');
  console.log('  GET /api/fragrances      - List all fragrances');
  console.log('  GET /api/fragrances/:id  - Get single fragrance');
  console.log('  GET /api/stats           - Database statistics');
});
