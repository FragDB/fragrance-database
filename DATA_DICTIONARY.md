# FragDB Database - Data Dictionary

Complete field documentation for all five database files.

## Overview

| File | Records | Fields | Primary Key |
|------|---------|--------|-------------|
| `fragrances.csv` | 122,367 | 30 | `pid` |
| `brands.csv` | 7,344 | 10 | `id` |
| `perfumers.csv` | 2,825 | 11 | `id` |
| `notes.csv` | 2,459 | 11 | `id` |
| `accords.csv` | 92 | 5 | `id` |

### Database Statistics

- **Total Fragrances**: 122,367
- **Unique Brands**: 7,344
- **Unique Perfumers**: 2,825
- **Unique Notes**: 2,459
- **Unique Accords**: 92
- **Unique Collections**: 5,781
- **Total Data Fields**: 67

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

Main fragrance database with 30 fields per record.

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

## video_url

**Description**: YouTube video URLs related to the fragrance

**Type**: Semicolon-separated URLs or empty

**Example**: `https://www.youtube.com/watch?v=I-7qaA6I7OE`

**Parsing (Python)**:
```python
videos = value.split(';') if value else []
```

**Notes**: YouTube videos about the fragrance. May contain multiple URLs separated by semicolons. Empty for most fragrances.

---

## accords

**Description**: Main fragrance accords with intensity percentages

**Type**: String or empty

**Format**: `accord_id:percent;...`

**Example**: `a24:100;a34:64;a38:60;a75:54`

**Parsing (Python)**:
```python
accords = []
for item in value.split(';'):
    accord_id, pct = item.split(':')
    accords.append({
        'id': accord_id,
        'percentage': int(pct)
    })
# Use accord_id to join with accords.csv for name and colors
```

**Notes**: Sorted by percentage descending. Use `accord_id` to look up name, `bar_color`, and `font_color` in `accords.csv`.

---

## notes_pyramid

**Description**: Fragrance notes organized by pyramid level with significance data

**Type**: String or empty

**Format**: `level(name,note_id,img,opacity,weight;...)level(...)`

**Example**: `top(Orange,n80,https://fimgs.net/mdimg/sastojci/t.80.jpg,1.0,5.0;Bergamot,n75,img.jpg,0.95,3.65)middle(...)base(...)`

**Structure**:
- **With levels**: `top(...)middle(...)base(...)`
- **Flat list**: `notes(...)`

**Fields per note**:
- `name` — Note name
- `note_id` — ID for joining with notes.csv (e.g., n80, n75)
- `img` — Note icon URL
- `opacity` — Note dominance (0.0-1.0, higher = more prominent)
- `weight` — Visual size in rem (2.5-5.0)

**Parsing (Python)**:
```python
import re
levels = re.findall(r'(\w+)\(([^)]+)\)', value)
for level_name, notes_str in levels:
    for note in notes_str.split(';'):
        parts = note.split(',')
        name, note_id, img = parts[0], parts[1], parts[2]
        opacity = float(parts[3]) if len(parts) > 3 else 1.0
        weight = float(parts[4]) if len(parts) > 4 else 5.0
        print(f"{level_name}: {name} (id={note_id}, opacity={opacity})")
```

**Notes**: Use `note_id` to join with `notes.csv` for full note details (latin name, group, odor profile).

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

## reviews_count

**Description**: Total number of user reviews for this fragrance

**Type**: Integer or empty

**Example**: `793`

**Notes**: Indicates fragrance popularity and data reliability. Higher count = more reliable ratings.

---

## appreciation

**Description**: User appreciation votes with counts and percentages

**Type**: String or empty

**Format**: `category:votes:percent;...`

**Example**: `love:12:13.19;like:48:52.75;ok:1:1.1;dislike:28:30.77;hate:2:2.2`

**Categories**: `love`, `like`, `ok`, `dislike`, `hate`

**Parsing (Python)**:
```python
def parse_votes(value):
    result = {}
    for item in value.split(';'):
        cat, votes, pct = item.split(':')
        result[cat] = {'votes': int(votes), 'percent': float(pct)}
    return result
```

**Notes**: Format is `category:votes:percent`. Use votes for statistical analysis, percent for display.

---

## price_value

**Description**: Price/value perception votes with counts and percentages

**Type**: String or empty

**Format**: `category:votes:percent;...`

**Example**: `way_overpriced:0:0;overpriced:2:29;ok:2:29;good_value:2:29;great_value:1:14`

**Categories**: `way_overpriced`, `overpriced`, `ok`, `good_value`, `great_value`

---

## gender_votes

**Description**: Gender suitability votes with counts and percentages

**Type**: String or empty

**Format**: `category:votes:percent;...`

**Example**: `female:5:63;more_female:1:13;unisex:2:25;more_male:0:0;male:0:0`

**Categories**: `female`, `more_female`, `unisex`, `more_male`, `male`

---

## longevity

**Description**: Longevity/lasting power votes with counts and percentages

**Type**: String or empty

**Format**: `category:votes:percent;...`

**Example**: `very_weak:4:18;weak:4:18;moderate:8:36;long_lasting:3:14;eternal:3:14`

**Categories**: `very_weak`, `weak`, `moderate`, `long_lasting`, `eternal`

---

## sillage

**Description**: Sillage/projection votes with counts and percentages

**Type**: String or empty

**Format**: `category:votes:percent;...`

**Example**: `intimate:5:19;moderate:11:42;strong:5:19;enormous:5:19`

**Categories**: `intimate`, `moderate`, `strong`, `enormous`

---

## season

**Description**: Seasonal suitability votes with counts and percentages

**Type**: String or empty

**Format**: `season:votes:percent;...`

**Example**: `winter:8:18;spring:15:33;summer:30:67;fall:12:27`

**Seasons**: `winter`, `spring`, `summer`, `fall`

**Notes**: Percentages may sum to more than 100% as users can select multiple seasons.

---

## time_of_day

**Description**: Day/night suitability votes with counts and percentages

**Type**: String or empty

**Format**: `time:votes:percent;...`

**Example**: `day:45:100;night:5:11`

**Times**: `day`, `night`

---

## pros_cons

**Description**: AI-generated pros and cons with user voting

**Type**: String or empty

**Format**: `pros(text,likes,dislikes;...)cons(text,likes,dislikes;...)`

**Example**: `pros(Long-lasting,149,3;Elegant,141,11)cons(Overpriced,92,20;Batch variations,45,12)`

**Parsing (Python)**:
```python
import re
sections = re.findall(r'(pros|cons)\(([^)]+)\)', value)
for section_type, items_str in sections:
    for item in items_str.split(';'):
        parts = item.rsplit(',', 2)
        text, likes, dislikes = parts[0], int(parts[1]), int(parts[2])
        print(f"{section_type}: {text} (+{likes}/-{dislikes})")
```

**Notes**: AI-generated summary of fragrance pros and cons, validated by user votes. May be empty for older fragrances.

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

**Description**: Similar fragrances with user voting

**Type**: String or empty

**Format**: `pid:likes:dislikes;...`

**Example**: `7025:5:4;9:2:0;1928:1:0`

**Parsing (Python)**:
```python
similar = []
for item in value.split(';'):
    pid, likes, dislikes = item.split(':')
    similar.append({'pid': int(pid), 'likes': int(likes), 'dislikes': int(dislikes)})
# Sort by likes descending for best recommendations
similar.sort(key=lambda x: x['likes'], reverse=True)
```

**Notes**: Use for "Similar to" recommendations. Sort by likes for best matches.

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

# notes.csv

Note reference table with 11 fields per record (2,459 notes).

## id

**Description**: Unique note identifier

**Type**: String

**Format**: `nN` (e.g., `n1`, `n80`, `n2448`)

**Example**: `n80`

**Notes**: Primary key. Use to join with `notes_pyramid` field in fragrances.csv.

---

## name

**Description**: Note name

**Type**: String

**Example**: `Orange`

---

## url

**Description**: Fragrantica note page URL

**Type**: URL or empty

**Example**: `https://www.fragrantica.com/notes/Orange-80.html`

---

## latin_name

**Description**: Latin/botanical name

**Type**: String or empty

**Example**: `Citrus sinensis`

---

## other_names

**Description**: Alternative names for the note

**Type**: String or empty

**Example**: `Sweet Orange, Naranja`

---

## group

**Description**: Note category/group

**Type**: String or empty

**Example**: `Citrus smells`

**Common values**: `Flowers`, `Woods and mosses`, `Citrus smells`, `Musk amber animalic smells`, `Spices`, `Fruits vegetables and nuts`

---

## odor_profile

**Description**: Detailed description of the scent

**Type**: String or empty

**Example**: `Fresh, sweet, zesty citrus scent with juicy undertones`

---

## main_icon

**Description**: Primary note icon URL

**Type**: URL or empty

**Example**: `https://fimgs.net/mdimg/sastojci/t.80.jpg`

---

## alt_icons

**Description**: Alternative note icon URLs

**Type**: Semicolon-separated URLs or empty

**Example**: `https://fimgs.net/mdimg/sastojci/m.80.jpg;https://fimgs.net/mdimg/sastojci/o.80.jpg`

---

## background

**Description**: Full-size background image URL

**Type**: URL or empty

**Example**: `https://fimgs.net/mdimg/sastojci/splash.80.jpg`

**Notes**: Large splash image suitable for detail pages.

---

## fragrance_count

**Description**: Number of fragrances containing this note

**Type**: Integer

**Example**: `12847`

---

# accords.csv

Accord reference table with 5 fields per record (92 accords).

## id

**Description**: Unique accord identifier

**Type**: String

**Format**: `aN` (e.g., `a1`, `a24`, `a92`)

**Example**: `a24`

**Notes**: Primary key. Use to join with `accords` field in fragrances.csv.

---

## name

**Description**: Accord name

**Type**: String

**Example**: `fruity`

---

## bar_color

**Description**: Background color for visualization (hex)

**Type**: String

**Example**: `#FC4B29`

**Notes**: Use as background color for accord bars in visualizations.

---

## font_color

**Description**: Text color for visualization (hex)

**Type**: String

**Example**: `#000000`

**Notes**: Use for text on top of bar_color background. Either `#000000` (black) or `#FFFFFF` (white) for readability.

---

## fragrance_count

**Description**: Number of fragrances containing this accord

**Type**: Integer

**Example**: `45821`

---

# Version History

- **v4.2.0** (2026-02-12): Data update — 122,367 fragrances, 7,344 brands, 2,825 perfumers, 2,459 notes
- **v3.1.0** (2026-02-05): Added video_url field, removed ownership field
- **v3.0.0** (2026-01-26): Added notes.csv, accords.csv, new voting format, reviews_count, pros_cons
- **v2.0.0** (2026-01-14): Multi-file structure with brands.csv and perfumers.csv
- **v1.0.0** (2026-01-07): Initial release with single fragrances.csv

See [CHANGELOG.md](CHANGELOG.md) for full version history.
