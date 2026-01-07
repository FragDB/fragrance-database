# FragDB Database - Data Dictionary

Generated: 2026-01-06 11:27

## Overview

- **Total fragrances**: 119,376
- **Unique brands**: 7,202
- **Unique collections**: 5,680
- **Unique accords**: 92
- **Unique notes**: 2,440
- **Total images**: 550,551
  - Main photos: 119,376
  - Info cards: 79,125
  - User photos: 352,050
- **Total description words**: 9,399,732
- **Total gender votes**: 7,239,723
- **Total ownership votes**: 11,737,650
- **Years range**: 1533 - 2026

## File Format

- **Format**: CSV with pipe `|` separator
- **Encoding**: UTF-8
- **Quote character**: `"` (for fields containing newlines or separators)

## Fields

### pid

**Description**: Unique perfume identifier

**Format**: Integer

**Example**: `9828`

**Notes**: Primary key

### url

**Description**: Direct link to the fragrance page on Fragrantica

**Format**: URL string

**Example**: `https://www.fragrantica.com/perfume/Creed/Aventus-9828.html`

**Notes**: Contains pid between last '-' and '.html'

### brand

**Description**: Perfume house / brand name with page URL and logo URL

**Format**: brand_name;brand_page_url;brand_logo_url

**Example**: `Creed;https://www.fragrantica.com/designers/Creed.html;https://fimgs.net/mdimg/dizajneri/o.37.jpg`

**Notes**: Brand information including name, profile page URL, and logo image URL.

**Structure:**
- `brand_name` - brand/designer name (e.g., Creed, Chanel)
- `brand_page_url` - link to brand's profile page on Fragrantica
- `brand_logo_url` - link to brand's logo image

**Parsing example (Python):**
```python
parts = value.split(';')
brand_name = parts[0]
brand_page_url = parts[1] if len(parts) > 1 else ''
brand_logo_url = parts[2] if len(parts) > 2 else ''
```

**Note**: URLs may not be available for all brands.

### name

**Description**: Fragrance name

**Format**: Text

**Example**: `Aventus`

### year

**Description**: Release year

**Format**: Integer or empty

**Example**: `2010`

### gender

**Description**: Target gender

**Format**: One of: 'for men', 'for women', 'for women and men', or empty

**Example**: `for men`

### collection

**Description**: Collection name within the brand

**Format**: Text or empty

**Example**: `Aventus`

### main_photo

**Description**: Main product photo of the fragrance bottle

**Format**: URL or empty

**Example**: `https://fimgs.net/mdimg/perfume/375x500.9828.jpg`

**Notes**: Single URL to the main fragrance bottle image.

### info_card

**Description**: Social card image with fragrance summary

**Format**: URL or empty

**Example**: `https://www.fragrantica.com/mdimg/perfume-social-cards/en-p_c_9828.jpeg`

**Notes**: URL to an image containing general fragrance information (social media card).

### user_photoes

**Description**: User-submitted photos of the fragrance

**Format**: Semicolon-separated URLs or empty

**Example**: `https://fimgs.net/photogram/p1200/zs/st/7orHFuKl1uqAYhBM.jpg;https://fimgs.net/photogram/p1200/yb/dz/AQh7prYtQAGQVDAI.jpg`

### accords

**Description**: Main fragrance accords with strength percentage and display colors

**Format**: Semicolon-separated list of accords. Each accord: name:percentage:bg_color:text_color

**Example**: `fruity:100:#FC4B29:#000000;sweet:68:#EE363B:#FFFFFF;woody:67:#774414:#FFFFFF`

**Notes**: Sorted by strength (percentage) descending.

**Structure of each accord:**
- `name` - accord name (e.g., fruity, woody, citrus)
- `percentage` - strength from 0 to 100
- `bg_color` - background/bar color in HEX (e.g., #FC4B29)
- `text_color` - text color in HEX (#000000 for dark, #FFFFFF for light)

**Parsing example (Python):**
```python
accords = value.split(';')
for accord in accords:
    name, pct, bg, text = accord.split(':')
    print(f"{name}: {pct}%")
```

### notes_pyramid

**Description**: Fragrance notes pyramid with page URLs and image URLs

**Format**: level(note,url,img;note,url,img)level(...) - levels concatenated without separator

**Example**: `top(Bergamot,https://www.fragrantica.com/notes/Bergamot-75.html,https://fimgs.net/mdimg/sastojci/t.75.jpg;Lemon,url,img)middle(...)base(...)`

**Notes**: Contains fragrance notes organized by pyramid level.

**Two formats:**
1. **With levels** (traditional pyramid): `top(...)middle(...)base(...)`
2. **Without levels** (flat list): `notes(...)`

**Structure:**
- Level names: `top`, `middle`, `base`, or `notes` (for flat list)
- Each level contains notes in parentheses
- Notes separated by `;`
- Each note: `name,page_url,image_url`

**Parsing example (Python):**
```python
import re
levels = re.findall(r'(\w+)\(([^)]+)\)', value)
for level_name, notes_str in levels:
    notes = notes_str.split(';')
    for note in notes:
        name, url, img = note.split(',')
        print(f"{level_name}: {name}")
```

### perfumers

**Description**: Perfumers (noses) who created the fragrance

**Format**: Semicolon-separated perfumer entries. Each entry: name,page_url,photo_url

**Example**: `Erwin Creed,https://www.fragrantica.com/noses/Erwin_Creed.html,https://frgs.me/mdimg/nosevi/fit.865.jpg`

**Notes**: Perfumers who created or collaborated on this fragrance.

**Structure:**
- Multiple perfumers separated by `;`
- Each perfumer: `name,page_url,photo_url`
  - `name` - perfumer's full name
  - `page_url` - link to perfumer's profile page
  - `photo_url` - link to perfumer's photo

**Parsing example (Python):**
```python
perfumers = []
for entry in value.split(';'):
    name, page_url, photo_url = entry.split(',')
    perfumers.append({'name': name, 'page': page_url, 'photo': photo_url})
```

### description

**Description**: Fragrance description text with HTML markup

**Format**: HTML text or empty

**Example**: `<p>Aventus by Creed is a Chypre Fruity fragrance for men...</p>`

**Notes**: Contains HTML tags like <p>, <br>.

### rating

**Description**: Overall fragrance rating

**Format**: average_rating;vote_count

**Example**: `4.33;24561`

**Notes**: Aggregated user rating for the fragrance.

**Structure:**
- First value: average rating (typically 1.0 to 5.0 scale)
- Second value: total number of votes

**Parsing example (Python):**
```python
avg_rating, vote_count = value.split(';')
rating = float(avg_rating)
votes = int(vote_count)
# rating = 4.33, votes = 24561
```

### appreciation

**Description**: User votes on fragrance appreciation

**Format**: Semicolon-separated relative values. Each entry: category:value

**Example**: `love:100;like:42.23;ok:11.85;dislike:11.15;hate:3.64`

**Notes**: User-submitted votes on how much they like the fragrance.

**Categories:**
- `love` - strongly appreciate
- `like` - moderately appreciate
- `ok` - neutral opinion
- `dislike` - moderately dislike
- `hate` - strongly dislike

**Values are relative**: the category with the most votes is set to 100, others are scaled proportionally.

**Parsing example (Python):**
```python
ratings = {}
for entry in value.split(';'):
    category, val = entry.split(':')
    ratings[category] = float(val)
# ratings = {'love': 100, 'like': 42.23, 'ok': 11.85, ...}
```

### price_value

**Description**: User votes on fragrance price/value perception

**Format**: Semicolon-separated vote counts. Each entry: category:count

**Example**: `way_overpriced:6658;overpriced:2844;ok:1360;good_value:337;great_value:378`

**Notes**: User-submitted votes on perceived value for money.

**Categories:**
- `way_overpriced` - significantly overpriced
- `overpriced` - somewhat overpriced
- `ok` - fair price
- `good_value` - good value for money
- `great_value` - excellent value for money

**Vote count** represents the number of users who selected that category.

**Parsing example (Python):**
```python
price = {}
for entry in value.split(';'):
    category, count = entry.split(':')
    price[category] = int(count)
# price = {'way_overpriced': 6658, 'overpriced': 2844, ...}
```

### ownership

**Description**: User votes on fragrance ownership status

**Format**: Semicolon-separated percentages. Each entry: category:percentage

**Example**: `have_it:52.82;had_it:12.32;want_it:34.86`

**Notes**: User-submitted votes on their ownership status of the fragrance.

**Categories:**
- `have_it` - currently own this fragrance
- `had_it` - previously owned but no longer have
- `want_it` - wish to acquire this fragrance

**Percentage** represents the proportion of voters who selected that category (values sum to ~100%).

**Parsing example (Python):**
```python
ownership = {}
for entry in value.split(';'):
    category, pct = entry.split(':')
    ownership[category] = float(pct)
# ownership = {'have_it': 52.82, 'had_it': 12.32, 'want_it': 34.86}
```

### gender_votes

**Description**: User votes on fragrance gender suitability

**Format**: Semicolon-separated vote counts. Each entry: category:count

**Example**: `female:149;more_female:44;unisex:866;more_male:2687;male:7977`

**Notes**: User-submitted votes on who the fragrance is best suited for.

**Categories:**
- `female` - strictly for women
- `more_female` - leans feminine
- `unisex` - suitable for any gender
- `more_male` - leans masculine
- `male` - strictly for men

**Vote count** represents the number of users who selected that category.

**Parsing example (Python):**
```python
votes = {}
for entry in value.split(';'):
    category, count = entry.split(':')
    votes[category] = int(count)
# votes = {'female': 149, 'more_female': 44, 'unisex': 866, ...}
```

### longevity

**Description**: User votes on fragrance longevity/lasting power

**Format**: Semicolon-separated vote counts. Each entry: category:count

**Example**: `very_weak:784;weak:1459;moderate:5869;long_lasting:5726;eternal:1614`

**Notes**: User-submitted votes on how long the fragrance lasts.

**Categories:**
- `very_weak` - lasts less than 1 hour
- `weak` - lasts 1-2 hours
- `moderate` - lasts 3-5 hours
- `long_lasting` - lasts 6-12 hours
- `eternal` - lasts more than 12 hours

**Vote count** represents the number of users who selected that category.

**Parsing example (Python):**
```python
longevity = {}
for entry in value.split(';'):
    category, count = entry.split(':')
    longevity[category] = int(count)
# longevity = {'very_weak': 784, 'weak': 1459, 'moderate': 5869, ...}
```

### sillage

**Description**: User votes on fragrance sillage (projection/trail)

**Format**: Semicolon-separated vote counts. Each entry: category:count

**Example**: `intimate:1816;moderate:8139;strong:4289;enormous:1267`

**Notes**: User-submitted votes on how far the fragrance projects.

**Categories:**
- `intimate` - close to skin, barely noticeable
- `moderate` - arm's length projection
- `strong` - noticeable from a distance
- `enormous` - fills the room

**Vote count** represents the number of users who selected that category.

**Parsing example (Python):**
```python
sillage = {}
for entry in value.split(';'):
    category, count = entry.split(':')
    sillage[category] = int(count)
# sillage = {'intimate': 1816, 'moderate': 8139, ...}
```

### season

**Description**: User votes on best seasons to wear the fragrance

**Format**: Semicolon-separated relative values. Each entry: season:value

**Example**: `winter:44.39;spring:97.60;summer:99.48;fall:74.81`

**Notes**: User-submitted votes on seasonal suitability.

**Seasons:**
- `winter` - cold weather
- `spring` - mild warming weather
- `summer` - hot weather
- `fall` - mild cooling weather

**Values are relative**: the season with the most votes is set to 100, others are scaled proportionally.

**Parsing example (Python):**
```python
seasons = {}
for entry in value.split(';'):
    season, val = entry.split(':')
    seasons[season] = float(val)
# seasons = {'winter': 44.39, 'spring': 97.60, ...}
```

### time_of_day

**Description**: User votes on best time of day to wear the fragrance

**Format**: Semicolon-separated relative values. Each entry: time:value

**Example**: `day:100.00;night:68.93`

**Notes**: User-submitted votes on time-of-day suitability.

**Times:**
- `day` - daytime wear
- `night` - evening/nighttime wear

**Values are relative**: the time with the most votes is set to 100, others are scaled proportionally.

**Parsing example (Python):**
```python
times = {}
for entry in value.split(';'):
    time, val = entry.split(':')
    times[time] = float(val)
# times = {'day': 100.00, 'night': 68.93}
```

### by_designer

**Description**: Other fragrances from the same brand/designer (PIDs)

**Format**: Semicolon-separated integers or empty

**Example**: `3805;4262;472;468;111224;12317`

**Notes**: List of PID references to other fragrances by the same brand.

### in_collection

**Description**: Other fragrances from the same collection

**Format**: Semicolon-separated PIDs or empty

**Example**: `9828;12345;67890`

**Notes**: List of PID references to fragrances in the same collection.

### reminds_of

**Description**: Fragrances this one reminds users of

**Format**: Semicolon-separated PIDs or empty

**Example**: `9828;12345;67890`

**Notes**: List of PID references to fragrances that users find similar.

### also_like

**Description**: Fragrances liked by people who like this one

**Format**: Semicolon-separated PIDs or empty

**Example**: `9828;12345;67890`

**Notes**: List of PID references to fragrances that appeal to the same audience.

### news_ids

**Description**: News IDs - references to news articles mentioning this fragrance

**Format**: Semicolon-separated integers or empty

**Example**: `23884;23818;23650;23579`

**Notes**: News article reference IDs.
