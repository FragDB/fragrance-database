# Use Cases

This document describes common use cases for the FragDB fragrance database, demonstrating how different industries and applications can leverage this comprehensive dataset.

## Table of Contents

- [E-commerce & Retail](#e-commerce--retail)
- [Mobile Applications](#mobile-applications)
- [Data Science & Research](#data-science--research)
- [Content & Media](#content--media)
- [Beauty Tech](#beauty-tech)
- [Enterprise Solutions](#enterprise-solutions)

---

## E-commerce & Retail

### Product Catalog Enhancement

**Scenario**: An online fragrance retailer wants to enrich their product listings with detailed information.

**Application**:
- Match existing products to FragDB by name/brand
- Add comprehensive accord breakdowns
- Display notes pyramid (top, middle, base)
- Show longevity and sillage data
- Include community ratings

**Data Used**:
- `accords` - Visual accord breakdown
- `notes_pyramid` - Complete notes hierarchy
- `longevity`, `sillage` - Performance metrics
- `rating` - Community ratings
- `main_photo`, `info_card` - Product visuals

### Product Recommendations

**Scenario**: Implement "Customers who liked this also liked..." feature.

**Application**:
```python
# Use pre-computed "also like" fragrances
also_like_ids = row['also_like'].split(';')[:5]
recommendations = df[df['pid'].isin(also_like_ids)]
```

**Data Used**:
- `also_like` - Pre-computed "users also like" data
- `reminds_of` - "This reminds me of" suggestions
- `accords` - For custom similarity algorithms

### Search & Filtering

**Scenario**: Build an advanced search interface for fragrance discovery.

**Filters to Implement**:
- Brand (7,300+ brands)
- Gender (for women, for men, unisex)
- Year of release (1900-2026+)
- Price range (based on community votes)
- Longevity (weak to eternal)
- Sillage (intimate to enormous)
- Season (spring, summer, fall, winter)
- Time of day (day, night)
- Accords (woody, floral, citrus, etc.)
- Notes (specific ingredients)

---

## Mobile Applications

### Fragrance Collection Manager

**Scenario**: App for users to catalog and manage their fragrance collection.

**Features**:
- Scan barcode → match to database
- Track owned fragrances
- Wishlist management
- Usage logging
- Collection statistics

**Data Used**:
- `pid` - Unique identifier
- `name`, `brand`, `year` - Basic info
- `main_photo` - Visual display
- `rating` - Community feedback

### Fragrance Discovery App

**Scenario**: Tinder-like swipe interface for discovering new fragrances.

**Features**:
- Swipe through fragrances
- Learn preferences from swipes
- Recommend based on liked accords
- Show seasonal recommendations

**Data Used**:
- `accords` - For preference learning
- `season` - Seasonal appropriateness
- `gender` - Target audience
- `also_like` - Recommendations

### Price Comparison App

**Scenario**: Compare prices across retailers for specific fragrances.

**Features**:
- Match user searches to database
- Display fragrance details
- Link to retailer prices (external API)

**Data Used**:
- `pid`, `name`, `brand` - Identification
- `url` - Original source link

---

## Data Science & Research

### Market Analysis

**Scenario**: Analyze fragrance industry trends for business intelligence.

**Analyses**:
```python
# Release trends over time
df.groupby('year').size().plot()

# Brand market share
df['brand_name'].value_counts().head(20)

# Accord popularity trends
# (Compare accords in 2010 vs 2020 releases)

# Rating vs votes correlation
df.plot.scatter(x='rating_votes', y='rating_average')
```

**Insights Available**:
- Industry growth patterns
- Seasonal release patterns
- Brand proliferation
- Accord trend shifts
- Rating patterns

### Sentiment Analysis

**Scenario**: Analyze fragrance descriptions to understand marketing language.

**Application**:
```python
from textblob import TextBlob

# Analyze description sentiment
df['sentiment'] = df['description'].apply(
    lambda x: TextBlob(x).sentiment.polarity if x else 0
)

# Compare sentiment by brand tier
```

**Data Used**:
- `description` - Marketing text
- `brand` - Brand information

### Machine Learning

**Scenario**: Build predictive models for fragrance success.

**Models**:
1. **Rating Prediction**: Predict rating from accords and notes
2. **Gender Classification**: Predict target gender from composition
3. **Price Tier Prediction**: Estimate price category
4. **Seasonal Classification**: Predict best seasons

**Features for ML**:
- Accord percentages (numeric)
- Note presence (binary)
- Brand (categorical)
- Year (numeric)
- Perfumer (categorical)

---

## Content & Media

### Editorial Content

**Scenario**: Fragrance blog or magazine needs data for articles.

**Content Ideas**:
- "Top 10 Vanilla Fragrances of 2026"
- "Most Versatile Unisex Fragrances"
- "Hidden Gems Under 1000 Votes"
- "Perfumer Spotlight: [Name]"
- "Brand Evolution: [Brand] Through the Years"

**Data Used**:
- All fields for filtering and ranking
- `perfumers` - For creator features
- `collection` - For themed articles

### Video Content

**Scenario**: YouTube fragrance reviewer needs data for videos.

**Applications**:
- Generate comparison charts
- Create "vs" graphics
- Build tier lists
- Accord visualization overlays

**Data Used**:
- `accords` with colors for visual charts
- `rating`, `longevity`, `sillage` for comparisons
- `main_photo` for thumbnails

### Podcast/Audio

**Scenario**: Fragrance podcast needs show prep data.

**Applications**:
- Episode research
- Fact-checking
- Guest preparation
- Listener Q&A research

---

## Beauty Tech

### AI Fragrance Recommendation

**Scenario**: Build an AI-powered fragrance recommendation system.

**Implementation**:
```python
# Content-based filtering using accords
from sklearn.metrics.pairwise import cosine_similarity

# Collaborative filtering using related fragrances
# (Use 'also_like' and 'reminds_of' fields)

# Hybrid approach combining both
```

**Data Used**:
- `accords` - Content features
- `also_like`, `reminds_of` - Collaborative signals
- `rating` - Popularity weighting

### Virtual Fragrance Wardrobe

**Scenario**: AR/VR application for trying fragrances virtually.

**Features**:
- Visual accord breakdown in 3D
- Notes pyramid visualization
- Seasonal/occasion matching
- Collection organization

**Data Used**:
- `accords` with colors
- `notes_pyramid`
- `season`, `time_of_day`

### Scent Matching Technology

**Scenario**: Match physical scent samples to database entries.

**Application**:
- GC-MS analysis → note matching
- Chemical compound mapping
- Similar fragrance identification

**Data Used**:
- `notes_pyramid` - Note ingredients
- `accords` - Scent categories
- `also_like`, `reminds_of` - Known similarities

---

## Enterprise Solutions

### Retailer Inventory Management

**Scenario**: Large retailer needs to standardize fragrance data across systems.

**Application**:
- Master data management
- SKU enrichment
- Cross-reference matching
- Data quality improvement

**Data Used**:
- `pid` - Universal identifier
- `name`, `brand`, `year` - Matching keys
- All metadata fields for enrichment

### Brand Intelligence Platform

**Scenario**: Fragrance brand wants competitive intelligence.

**Analyses**:
- Competitor portfolio analysis
- Market positioning (accord space)
- Rating benchmarking
- Release timing patterns
- Perfumer talent mapping

**Data Used**:
- Full database for competitive landscape
- `perfumers` for talent analysis
- `rating` for benchmarking

### Insurance & Valuation

**Scenario**: Valuation of fragrance collections for insurance.

**Application**:
- Identify fragrances in collection
- Cross-reference market data
- Assess rarity by vote counts
- Document condition/completeness

**Data Used**:
- `pid`, `name`, `brand` - Unique identification
- `rating`, `reviews_count` - Popularity and rarity indicators
- `year` - Age determination

---

## Quick Start by Use Case

| Use Case | Recommended Languages | Key Fields |
|----------|----------------------|------------|
| E-commerce | Python, JavaScript | all |
| Mobile App | Swift, Kotlin, React Native | pid, name, brand, accords, rating |
| Data Science | Python, R | all |
| Content | Any | all |
| ML/AI | Python | accords, notes_pyramid, rating |
| Enterprise | SQL, Python | all |

## Sample Queries by Use Case

### E-commerce: Best Sellers
```sql
SELECT * FROM fragrances
WHERE rating_votes > 10000
ORDER BY rating_average DESC
LIMIT 100;
```

### Mobile: Light Data Load
```sql
SELECT pid, name, brand_name, year, rating_average
FROM fragrances
WHERE main_photo IS NOT NULL;
```

### Research: Market Analysis
```sql
SELECT year, COUNT(*) as releases, AVG(rating_average) as avg_rating
FROM fragrances
WHERE year >= 2000
GROUP BY year
ORDER BY year;
```

---

## Need the Full Database?

The free sample contains 10 rows. The full FragDB database includes:

- **123,000+** fragrances
- **7,300+** brands
- **67** data fields across 5 files
- Regular updates

**Purchase Options**:
- One-Time Purchase: $200
- Annual Subscription: $1,000/year
- Lifetime Access: $2,000

Visit [fragdb.net](https://fragdb.net) to purchase.
