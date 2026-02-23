# Integration Guide

This guide explains how to integrate the FragDB fragrance database into various applications and platforms.

## Table of Contents

- [Data Import](#data-import)
- [Web Applications](#web-applications)
- [Mobile Applications](#mobile-applications)
- [Data Analysis Platforms](#data-analysis-platforms)
- [Search Implementation](#search-implementation)
- [Recommendation Systems](#recommendation-systems)
- [API Development](#api-development)

## Data Import

### File Format

The FragDB database is provided as a pipe-delimited CSV file:

- **Delimiter**: `|` (pipe character)
- **Encoding**: UTF-8
- **Quote character**: None (fields containing delimiters are properly escaped)
- **Header**: First row contains column names

### Loading the Data

#### Python (Pandas)

```python
import pandas as pd

df = pd.read_csv('fragdb.csv', sep='|', encoding='utf-8')
```

#### JavaScript (Node.js)

```javascript
const { parse } = require('csv-parse/sync');
const fs = require('fs');

const records = parse(fs.readFileSync('fragdb.csv', 'utf-8'), {
  columns: true,
  delimiter: '|',
  skip_empty_lines: true
});
```

#### R

```r
library(tidyverse)
df <- read_delim('fragdb.csv', delim = '|', locale = locale(encoding = 'UTF-8'))
```

#### SQL

See [examples/sql/import_instructions.md](../examples/sql/import_instructions.md) for detailed SQL import guides.

## Web Applications

### React Integration

```jsx
import { useState, useEffect } from 'react';

function FragranceSearch() {
  const [fragrances, setFragrances] = useState([]);
  const [query, setQuery] = useState('');

  useEffect(() => {
    // Load data (from API or pre-processed JSON)
    fetch('/api/fragrances')
      .then(res => res.json())
      .then(data => setFragrances(data));
  }, []);

  const filtered = fragrances.filter(f =>
    f.name.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div>
      <input
        type="text"
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search fragrances..."
      />
      <ul>
        {filtered.slice(0, 20).map(f => (
          <li key={f.pid}>{f.name} by {f.brand_name}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Vue.js Integration

```vue
<template>
  <div>
    <input v-model="query" placeholder="Search fragrances..." />
    <ul>
      <li v-for="f in filteredFragrances" :key="f.pid">
        {{ f.name }} by {{ f.brand_name }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      fragrances: [],
      query: ''
    };
  },
  computed: {
    filteredFragrances() {
      return this.fragrances
        .filter(f => f.name.toLowerCase().includes(this.query.toLowerCase()))
        .slice(0, 20);
    }
  },
  async mounted() {
    const res = await fetch('/api/fragrances');
    this.fragrances = await res.json();
  }
};
</script>
```

### Converting to JSON

For web applications, you may want to convert the CSV to JSON:

```python
import pandas as pd
import json

df = pd.read_csv('fragdb.csv', sep='|')

# Full conversion
df.to_json('fragrances.json', orient='records')

# Selected fields only
df[['pid', 'name', 'brand', 'year', 'rating']].to_json('fragrances_lite.json', orient='records')
```

## Mobile Applications

### iOS (Swift)

```swift
import Foundation

struct Fragrance: Codable {
    let pid: Int
    let name: String
    let brand: String
    let year: Int?
    let gender: String?
}

class FragranceDatabase {
    private var fragrances: [Fragrance] = []

    func load(from url: URL) throws {
        let data = try Data(contentsOf: url)
        fragrances = try JSONDecoder().decode([Fragrance].self, from: data)
    }

    func search(query: String) -> [Fragrance] {
        fragrances.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
}
```

### Android (Kotlin)

```kotlin
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class Fragrance(
    val pid: Int,
    val name: String,
    val brand: String,
    val year: Int? = null,
    val gender: String? = null
)

class FragranceDatabase {
    private var fragrances: List<Fragrance> = emptyList()

    fun load(jsonString: String) {
        fragrances = Json.decodeFromString(jsonString)
    }

    fun search(query: String): List<Fragrance> {
        return fragrances.filter {
            it.name.contains(query, ignoreCase = true)
        }
    }
}
```

## Data Analysis Platforms

### Jupyter Notebook

```python
import pandas as pd
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv('fragdb.csv', sep='|')

# Parse rating
df['rating_avg'] = df['rating'].str.split(';').str[0].astype(float)
df['rating_votes'] = df['rating'].str.split(';').str[1].astype(int)

# Analysis
print(f"Total fragrances: {len(df):,}")
print(f"Year range: {df['year'].min()} - {df['year'].max()}")
print(f"Average rating: {df['rating_avg'].mean():.2f}")

# Visualization
df.groupby('year').size().plot(kind='line', title='Fragrances by Year')
plt.show()
```

### Tableau / Power BI

1. Import the CSV file using pipe delimiter
2. Create calculated fields for parsed data:
   - `Brand Name`: `SPLIT([brand], ';', 1)`
   - `Rating`: `FLOAT(SPLIT([rating], ';', 1))`
   - `Votes`: `INT(SPLIT([rating], ';', 2))`

### Google Sheets

```
=IMPORTDATA("path/to/fragdb.csv")
```

Then use `SPLIT()` function to parse complex fields:
```
=SPLIT(B2, ";")  -- For brand field
```

## Search Implementation

### Full-Text Search with Elasticsearch

```json
PUT /fragrances
{
  "mappings": {
    "properties": {
      "name": { "type": "text", "analyzer": "standard" },
      "brand_name": { "type": "keyword" },
      "description": { "type": "text" },
      "accords": { "type": "keyword" },
      "notes": { "type": "keyword" },
      "year": { "type": "integer" },
      "rating": { "type": "float" }
    }
  }
}
```

### SQLite Full-Text Search

```sql
CREATE VIRTUAL TABLE fragrances_fts USING fts5(
    name, brand_name, description, content='fragrances'
);

-- Search query
SELECT * FROM fragrances_fts WHERE fragrances_fts MATCH 'vanilla sweet';
```

### Algolia Integration

```javascript
const algoliasearch = require('algoliasearch');

const client = algoliasearch('APP_ID', 'API_KEY');
const index = client.initIndex('fragrances');

// Index data
const fragrances = loadFragDB();
index.saveObjects(fragrances.map(f => ({
  objectID: f.pid,
  name: f.name,
  brand: parseBrand(f.brand).name,
  year: f.year,
  gender: f.gender
})));
```

## Recommendation Systems

### Content-Based Filtering

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Create feature vectors from accords
def get_accord_features(df):
    df['accord_text'] = df['accords'].apply(lambda x:
        ' '.join([a.split(':')[0] for a in x.split(';')]) if x else '')

    tfidf = TfidfVectorizer()
    tfidf_matrix = tfidf.fit_transform(df['accord_text'])

    return tfidf_matrix

# Find similar fragrances
def find_similar(df, fragrance_id, n=5):
    tfidf_matrix = get_accord_features(df)
    idx = df[df['pid'] == fragrance_id].index[0]

    sim_scores = cosine_similarity(tfidf_matrix[idx], tfidf_matrix)[0]
    similar_indices = sim_scores.argsort()[::-1][1:n+1]

    return df.iloc[similar_indices][['name', 'brand']]
```

### Collaborative Filtering Preparation

The database includes `also_like` and `reminds_of` fields with pre-computed similar fragrances:

```python
# Parse related fragrances
def get_related_ids(related_str):
    if not related_str:
        return []
    return [int(x) for x in related_str.split(';') if x.isdigit()]

# Build similarity graph
import networkx as nx

G = nx.Graph()
for _, row in df.iterrows():
    pid = row['pid']
    # Combine both similarity fields
    also_like_ids = get_related_ids(row['also_like'])
    reminds_of_ids = get_related_ids(row['reminds_of'])
    for related_id in also_like_ids + reminds_of_ids:
        G.add_edge(pid, related_id)
```

## API Development

See [examples/javascript/fragrance_api.js](../examples/javascript/fragrance_api.js) for a complete Express.js API example.

### REST API Endpoints

Recommended endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/fragrances` | List fragrances (paginated) |
| GET | `/fragrances/:id` | Get single fragrance |
| GET | `/fragrances/search` | Search by name/brand |
| GET | `/brands` | List all brands |
| GET | `/accords` | List all accords |
| GET | `/notes` | List all notes |
| GET | `/stats` | Database statistics |

### GraphQL Schema

```graphql
type Fragrance {
  pid: ID!
  name: String!
  brand: Brand
  year: Int
  gender: String
  rating: Rating
  accords: [Accord!]!
  notes: NotesPyramid
}

type Brand {
  name: String!
  url: String
  logo: String
}

type Rating {
  average: Float!
  votes: Int!
}

type Accord {
  name: String!
  percentage: Int!
  bgColor: String
  textColor: String
}

type NotesPyramid {
  top: [Note!]
  middle: [Note!]
  base: [Note!]
}

type Query {
  fragrance(id: ID!): Fragrance
  fragrances(limit: Int, offset: Int, filter: FragranceFilter): [Fragrance!]!
  searchFragrances(query: String!): [Fragrance!]!
}
```

## Best Practices

1. **Parse complex fields once** - Store parsed data in separate columns/tables
2. **Index frequently searched fields** - name, brand, year, gender, accords
3. **Implement caching** - Cache parsed results and search queries
4. **Use pagination** - Never load all 123,000+ records at once
5. **Validate data** - Some fields may be empty or malformed

## Support

- [DATA_DICTIONARY.md](../DATA_DICTIONARY.md) - Complete field documentation
- [FAQ.md](FAQ.md) - Frequently asked questions
- [fragdb.net](https://fragdb.net) - Purchase the full database
