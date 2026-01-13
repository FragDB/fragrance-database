# FragDB Database - Data Dictionary

Complete field documentation for all three database files.

## Overview

| File | Records | Fields | Primary Key |
|------|---------|--------|-------------|
| `fragrances.csv` | 119,000+ | 28 | `pid` |
| `brands.csv` | 7,200+ | 10 | `id` |
| `perfumers.csv` | 2,700+ | 11 | `id` |

### Database Statistics

- **Total Fragrances**: 119,000+
- **Unique Brands**: 7,200+
- **Unique Perfumers**: 2,700+
- **Unique Collections**: 5,700+
- **Unique Accords**: 92
- **Unique Notes**: 2,400+
- **Years Range**: 1533 - 2026

## File Format

All files share the same format:

| Property | Value |
|----------|-------|
| **Format** | CSV |
| **Separator** | Pipe `\|` |
| **Encoding** | UTF-8 |
| **Quote Character** | `"` (double quote) |
| **Line Ending** | Unix (LF) |
| **Header** | Yes (first row) |

---

# fragrances.csv

Main fragrance database with 28 fields per record.

## pid

**Description**: Unique perfume identifier

**Type**: Integer

**Example**: `9828`

**Notes**: Primary key, never empty. Use for cross-references in `by_designer`, `in_collection`, `reminds_of`, `also_like` fields.

---

## url

**Description**: Direct link to the fragrance page on Fragrantica

**Type**: URL

**Example**: `https://www.fragrantica.com/perfume/Creed/Aventus-9828.html`

**Notes**: Contains pid between last `-` and `.html`.

---

## brand

**Description**: Brand name with ID reference for joining with brands.csv

**Type**: String

**Format**: `brand_name;brand_id`

**Example**: `Creed;b1`

**Parsing (Python)**:
```python
parts = value.split(';')
brand_name = parts[0]
brand_id = parts[1] if len(parts) > 1 else ''
# Use brand_id to join with brands.csv
```

**Notes**: Brand name is never empty. Use `brand_id` to look up full brand details (logo, country, website, etc.) in `brands.csv`.

---

## name

**Description**: Fragrance name

**Type**: String

**Example**: `Aventus`

**Notes**: Never empty.

---

## year

**Description**: Release year

**Type**: Integer or empty

**Example**: `2010`

**Notes**: May be empty if release year is unknown.

---

## gender

**Description**: Target gender

**Type**: String

**Values**: `for men`, `for women`, `for women and men`, or empty

**Example**: `for men`

---

## collection

**Description**: Collection name within the brand

**Type**: String or empty

**Example**: `Aventus`

**Notes**: Brand's product line or collection. May be empty.

---

## main_photo

**Description**: Main product photo of the fragrance bottle

**Type**: URL or empty

**Example**: `https://fimgs.net/mdimg/perfume/375x500.9828.jpg`

**Notes**: Single URL to the main fragrance bottle image.

---

## info_card

**Description**: Social card image with fragrance summary

**Type**: URL or empty

**Example**: `https://www.fragrantica.com/mdimg/perfume-social-cards/en-p_c_9828.jpeg`

**Notes**: Optimized for social media sharing.

---

## user_photoes

**Description**: User-submitted photos of the fragrance

**Type**: Semicolon-separated URLs or empty

**Example**: `https://fimgs.net/photogram/p1200/zs/st/7orHFuKl1uqAYhBM.jpg;https://fimgs.net/photogram/p1200/yb/dz/AQh7prYtQAGQVDAI.jpg`

**Parsing (Python)**:
```python
photos = value.split(';') if value else []
```

---

## accords

**Description**: Main fragrance accords with strength percentage and display colors

**Type**: String or empty

**Format**: `accord_name:percentage:bg_color:text_color;...`

**Example**: `fruity:100:#FC4B29:#000000;sweet:68:#EE363B:#FFFFFF;woody:67:#774414:#FFFFFF`

**Parsing (Python)**:
```python
accords = []
for item in value.split(';'):
    name, pct, bg_color, text_color = item.split(':')
    accords.append({
        'name': name,
        'percentage': int(pct),
        'bg_color': bg_color,
        'text_color': text_color
    })
```

**Notes**: Sorted by percentage descending. Use colors for visualization.

---

## notes_pyramid

**Description**: Fragrance notes organized by pyramid level

**Type**: String or empty

**Format**: `level(note,url,img;...)level(...)`

**Example**: `top(Bergamot,https://www.fragrantica.com/notes/Bergamot-75.html,https://fimgs.net/mdimg/sastojci/t.75.jpg;Lemon,url,img)middle(...)base(...)`

**Structure**:
- **With levels**: `top(...)middle(...)base(...)`
- **Flat list**: `notes(...)`

**Parsing (Python)**:
```python
import re
levels = re.findall(r'(\w+)\(([^)]+)\)', value)
for level_name, notes_str in levels:
    for note in notes_str.split(';'):
        name, url, img = note.split(',')
        print(f"{level_name}: {name}")
```

---

## perfumers

**Description**: Perfumers (noses) who created the fragrance

**Type**: String or empty

**Format**: `name1;id1;name2;id2;...`

**Example**: `Erwin Creed;p1;Jean-Claude Ellena;p5`

**Parsing (Python)**:
```python
perfumers = []
parts = value.split(';')
for i in range(0, len(parts), 2):
    if i + 1 < len(parts):
        perfumers.append({
            'name': parts[i],
            'id': parts[i + 1]
        })
# Use id to join with perfumers.csv
```

**Notes**: Use perfumer `id` to look up full details in `perfumers.csv`.

---

## description

**Description**: Fragrance description text

**Type**: HTML or empty

**Example**: `<p>Aventus by Creed is a Chypre Fruity fragrance for men...</p>`

**Notes**: Contains HTML tags (`<p>`, `<br>`). Sanitize before rendering.

---

## rating

**Description**: Overall fragrance rating

**Type**: String or empty

**Format**: `average_rating;vote_count`

**Example**: `4.33;24561`

**Parsing (Python)**:
```python
avg, votes = value.split(';')
rating = float(avg)
vote_count = int(votes)
```

---

## appreciation

**Description**: User appreciation votes (relative values)

**Type**: String or empty

**Format**: `category:value;...`

**Example**: `love:100;like:42.23;ok:11.85;dislike:11.15;hate:3.64`

**Categories**: `love`, `like`, `ok`, `dislike`, `hate`

**Notes**: Values are relative (highest = 100).

---

## price_value

**Description**: Price/value perception votes (absolute counts)

**Type**: String or empty

**Format**: `category:count;...`

**Example**: `way_overpriced:6658;overpriced:2844;ok:1360;good_value:337;great_value:378`

**Categories**: `way_overpriced`, `overpriced`, `ok`, `good_value`, `great_value`

---

## ownership

**Description**: Ownership status votes (percentages)

**Type**: String or empty

**Format**: `category:percentage;...`

**Example**: `have_it:52.82;had_it:12.32;want_it:34.86`

**Categories**: `have_it`, `had_it`, `want_it`

---

## gender_votes

**Description**: Gender suitability votes (absolute counts)

**Type**: String or empty

**Format**: `category:count;...`

**Example**: `female:149;more_female:44;unisex:866;more_male:2687;male:7977`

**Categories**: `female`, `more_female`, `unisex`, `more_male`, `male`

---

## longevity

**Description**: Longevity/lasting power votes (absolute counts)

**Type**: String or empty

**Format**: `category:count;...`

**Example**: `very_weak:784;weak:1459;moderate:5869;long_lasting:5726;eternal:1614`

**Categories**: `very_weak`, `weak`, `moderate`, `long_lasting`, `eternal`

---

## sillage

**Description**: Sillage/projection votes (absolute counts)

**Type**: String or empty

**Format**: `category:count;...`

**Example**: `intimate:1816;moderate:8139;strong:4289;enormous:1267`

**Categories**: `intimate`, `moderate`, `strong`, `enormous`

---

## season

**Description**: Seasonal suitability votes (relative values)

**Type**: String or empty

**Format**: `season:value;...`

**Example**: `winter:44.39;spring:97.60;summer:99.48;fall:74.81`

**Seasons**: `winter`, `spring`, `summer`, `fall`

**Notes**: Values are relative (highest = 100).

---

## time_of_day

**Description**: Day/night suitability votes (relative values)

**Type**: String or empty

**Format**: `time:value;...`

**Example**: `day:100.00;night:68.93`

**Times**: `day`, `night`

---

## by_designer

**Description**: Other fragrances from the same brand

**Type**: Semicolon-separated integers or empty

**Example**: `3805;4262;472;468;111224;12317`

**Notes**: List of `pid` values. Use for "More from this brand" features.

---

## in_collection

**Description**: Other fragrances in the same collection

**Type**: Semicolon-separated integers or empty

**Example**: `9828;12345;67890`

---

## reminds_of

**Description**: Similar fragrances (user-voted)

**Type**: Semicolon-separated integers or empty

**Example**: `9828;12345;67890`

**Notes**: Use for "Similar to" recommendations.

---

## also_like

**Description**: Fragrances liked by people who like this one

**Type**: Semicolon-separated integers or empty

**Example**: `9828;12345;67890`

**Notes**: Collaborative filtering suggestions. Use for "You might also like" features.

---

## news_ids

**Description**: Related news article IDs

**Type**: Semicolon-separated integers or empty

**Example**: `23884;23818;23650;23579`

**Notes**: News URL format: `https://www.fragrantica.com/news/x-{news_id}.html`

---

# brands.csv

Brand/designer reference table with 10 fields per record.

## id

**Description**: Unique brand identifier

**Type**: String

**Format**: `bN` (e.g., `b1`, `b42`, `b1503`)

**Example**: `b1`

**Notes**: Primary key. Use to join with `brand` field in fragrances.csv.

---

## name

**Description**: Brand name

**Type**: String

**Example**: `Creed`

**Notes**: Never empty.

---

## url

**Description**: Fragrantica brand page URL

**Type**: URL or empty

**Example**: `https://www.fragrantica.com/designers/Creed.html`

---

## logo_url

**Description**: Brand logo image URL

**Type**: URL or empty

**Example**: `https://fimgs.net/mdimg/designers/g195.png`

**Notes**: PNG format, suitable for display.

---

## country

**Description**: Country of origin

**Type**: String or empty

**Example**: `France`

---

## main_activity

**Description**: Primary business activity

**Type**: String or empty

**Example**: `Fragrance house`

**Common values**: `Fragrance house`, `Fashion house`, `Celebrity`, `Niche`, `Designer`

---

## website

**Description**: Official brand website

**Type**: URL or empty

**Example**: `https://www.creed.com`

---

## parent_company

**Description**: Parent company or conglomerate

**Type**: String or empty

**Example**: `Kering`

**Common values**: `LVMH`, `Estée Lauder`, `Coty`, `Puig`, `L'Oréal`

---

## description

**Description**: Brand description/history

**Type**: HTML or empty

**Example**: `<p>Creed is a French fragrance house founded in 1760...</p>`

**Notes**: Contains HTML tags. Sanitize before rendering.

---

## brand_count

**Description**: Number of fragrances by this brand

**Type**: Integer

**Example**: `847`

**Notes**: Count of fragrances in the database from this brand.

---

# perfumers.csv

Perfumer (nose) reference table with 11 fields per record.

## id

**Description**: Unique perfumer identifier

**Type**: String

**Format**: `pN` (e.g., `p1`, `p42`, `p865`)

**Example**: `p1`

**Notes**: Primary key. Use to join with `perfumers` field in fragrances.csv.

---

## name

**Description**: Perfumer full name

**Type**: String

**Example**: `Alberto Morillas`

**Notes**: Never empty.

---

## url

**Description**: Fragrantica perfumer page URL

**Type**: URL or empty

**Example**: `https://www.fragrantica.com/noses/Alberto_Morillas.html`

---

## photo_url

**Description**: Perfumer portrait photo URL

**Type**: URL or empty

**Example**: `https://fimgs.net/mdimg/nosevi/fit.123.jpg`

---

## status

**Description**: Professional status/title

**Type**: String or empty

**Example**: `Master Perfumer`

**Common values**: `Master Perfumer`, `Senior Perfumer`, `Perfumer`, `Independent Perfumer`

---

## company

**Description**: Current employer

**Type**: String or empty

**Example**: `Firmenich`

**Common values**: `Firmenich`, `Givaudan`, `IFF`, `Symrise`, `Takasago`

---

## also_worked

**Description**: Previous employers

**Type**: String or empty

**Example**: `Quest International, Givaudan`

**Notes**: Comma-separated list of companies.

---

## education

**Description**: Educational background

**Type**: String or empty

**Example**: `ISIPCA`

**Common values**: `ISIPCA`, `Givaudan Perfumery School`, `GIP`

---

## web

**Description**: Personal/professional website

**Type**: URL or empty

**Example**: `https://www.perfumer.com`

---

## perfumes_count

**Description**: Number of fragrances created

**Type**: Integer

**Example**: `538`

**Notes**: Count of fragrances in the database by this perfumer.

---

## biography

**Description**: Perfumer biography

**Type**: HTML or empty

**Example**: `<p>Alberto Morillas is a Spanish perfumer known for...</p>`

**Notes**: Contains HTML tags. Sanitize before rendering.

---

# Joining Tables

## Python Example

```python
import pandas as pd

# Load all three files
fragrances = pd.read_csv('fragrances.csv', sep='|', encoding='utf-8')
brands = pd.read_csv('brands.csv', sep='|', encoding='utf-8')
perfumers = pd.read_csv('perfumers.csv', sep='|', encoding='utf-8')

# Extract brand_id
fragrances['brand_id'] = fragrances['brand'].str.split(';').str[1]

# Join fragrances with brands
df = fragrances.merge(
    brands,
    left_on='brand_id',
    right_on='id',
    how='left',
    suffixes=('', '_brand')
)

# Now access brand details
print(df[['name', 'name_brand', 'country', 'website']].head())
```

## SQL Example

```sql
-- PostgreSQL
SELECT
    f.pid,
    f.name AS fragrance,
    b.name AS brand,
    b.country,
    b.website
FROM fragrances f
LEFT JOIN brands b ON SPLIT_PART(f.brand, ';', 2) = b.id
WHERE f.name ILIKE '%aventus%';
```

## JavaScript Example

```javascript
// Create lookup maps
const brandsMap = new Map(brands.map(b => [b.id, b]));
const perfumersMap = new Map(perfumers.map(p => [p.id, p]));

// Get brand details
function getBrand(fragrance) {
    const [name, id] = fragrance.brand.split(';');
    return brandsMap.get(id) || { name };
}

// Get all perfumers for a fragrance
function getPerfumers(fragrance) {
    if (!fragrance.perfumers) return [];
    const parts = fragrance.perfumers.split(';');
    const result = [];
    for (let i = 0; i < parts.length; i += 2) {
        const id = parts[i + 1];
        result.push(perfumersMap.get(id) || { name: parts[i], id });
    }
    return result;
}
```

---

# Version History

- **v2.0.0** (2026-01-14): Multi-file structure with brands.csv and perfumers.csv
- **v1.0.0** (2026-01-07): Initial release with single fragrances.csv

See [CHANGELOG.md](CHANGELOG.md) for full version history.
