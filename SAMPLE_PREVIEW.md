# Sample Data Preview

Preview of the FragDB v3.1 sample data. All files are interconnected via IDs.

## Files Overview

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| [fragrances.csv](samples/fragrances.csv) | 10 | 30 | Top-rated fragrances |
| [brands.csv](samples/brands.csv) | 10 | 10 | Brand profiles |
| [perfumers.csv](samples/perfumers.csv) | 10 | 11 | Perfumer profiles |
| [notes.csv](samples/notes.csv) | 10 | 11 | Fragrance notes |
| [accords.csv](samples/accords.csv) | 10 | 5 | Accords with colors |

---

## fragrances.csv

### Key Fields

| PID | Name | Brand | Year | Gender |
|-----|------|-------|------|--------|
| 219 | Hypnotic Poison | Dior;b3 | 1998 | for women |
| 485 | Light Blue | Dolce&Gabbana;b72 | 2001 | for women |
| 611 | Coco Mademoiselle | Chanel;b6 | 2001 | for women |
| 704 | Angel | Mugler;b92 | 1992 | for women |
| 707 | Alien | Mugler;b92 | 2005 | for women |
| 1018 | Black Orchid | Tom Ford;b139 | 2006 | for women |
| 1825 | Tobacco Vanille | Tom Ford;b139 | 2007 | for women and men |
| 14982 | La Vie Est Belle | Lancôme;b31 | 2012 | for women |
| 25324 | Black Opium | Yves Saint Laurent;b15 | 2014 | for women |
| 31861 | Sauvage | Dior;b3 | 2015 | for men |

### Field Reference (30 fields)

| Category | Fields |
|----------|--------|
| Identity | `pid`, `url`, `brand`, `name`, `year`, `gender`, `collection` |
| Media | `main_photo`, `info_card`, `user_photoes`, `video_url` |
| Composition | `accords`, `notes_pyramid`, `perfumers`, `description` |
| Ratings | `rating`, `reviews_count`, `appreciation`, `price_value` |
| Votes | `gender_votes`, `longevity`, `sillage`, `season`, `time_of_day` |
| Related | `pros_cons`, `by_designer`, `in_collection`, `reminds_of`, `also_like`, `news_ids` |

### Brand Field Format

```
brand_name;brand_id
```

Example: `Dior;b3` — use `b3` to join with brands.csv

### Accords Field Format (v3.0+)

```
accord_id:percentage;...
```

Example: `a2:100;a6:86;a1:71`

Use accord IDs to join with accords.csv for names and colors.

### Voting Fields Format

All voting fields use: `category:votes:percent;...`

Example (appreciation):
```
love:6380:22.04;like:14455:49.93;ok:4039:13.95;dislike:3271:11.3;hate:808:2.79
```

---

## brands.csv

| ID | Name | Country |
|----|------|---------|
| b3 | Dior | France |
| b6 | Chanel | France |
| b15 | Yves Saint Laurent | France |
| b31 | Lancôme | France |
| b72 | Dolce&Gabbana | Italy |
| b92 | Mugler | France |
| b139 | Tom Ford | United States |

**Fields**: `id`, `name`, `url`, `logo_url`, `country`, `main_activity`, `website`, `parent_company`, `description`, `brand_count`

---

## perfumers.csv

| ID | Name | Company |
|----|------|---------|
| p9 | Olivier Cresp | Firmenich |
| p24 | Jacques Cavallier | Louis Vuitton |
| p43 | Annick Menardo | Firmenich |
| p73 | Olivier Polge | Chanel |
| p186 | Dominique Ropion | IFF |

**Fields**: `id`, `name`, `url`, `photo_url`, `status`, `company`, `also_worked`, `education`, `web`, `perfumes_count`, `biography`

---

## notes.csv

| ID | Name | Group |
|----|------|-------|
| n3 | Vanilla | Musk amber animalic smells |
| n8 | Sandalwood | Woods and mosses |
| n10 | Musk | Musk amber animalic smells |
| n26 | Jasmine | Flowers |
| n80 | Orange | Citrus smells |

**Fields**: `id`, `name`, `url`, `latin_name`, `other_names`, `group`, `odor_profile`, `main_icon`, `alt_icons`, `background`, `fragrance_count`

---

## accords.csv

| ID | Name | Bar Color | Font Color |
|----|------|-----------|------------|
| a1 | amber | #FEAD4C | #000000 |
| a2 | vanilla | #FFFEC0 | #000000 |
| a6 | sweet | #EE363B | #FFFFFF |
| a24 | fruity | #FC4B29 | #000000 |
| a34 | citrus | #F7E733 | #000000 |

**Fields**: `id`, `name`, `bar_color`, `font_color`, `fragrance_count`

---

## Joining Tables

### Python

```python
import pandas as pd

# Load files
fragrances = pd.read_csv('samples/fragrances.csv', sep='|')
brands = pd.read_csv('samples/brands.csv', sep='|')
accords = pd.read_csv('samples/accords.csv', sep='|')

# Extract brand_id
fragrances['brand_id'] = fragrances['brand'].str.split(';').str[1]

# Join with brands
df = fragrances.merge(brands, left_on='brand_id', right_on='id', suffixes=('', '_brand'))
print(df[['name', 'name_brand', 'country']])
```

### JavaScript

```javascript
const brandsMap = new Map(brands.map(b => [b.id, b]));
const accordsMap = new Map(accords.map(a => [a.id, a]));

// Get brand for fragrance
const [brandName, brandId] = fragrance.brand.split(';');
const brand = brandsMap.get(brandId);

// Parse accords with colors
const accordsList = fragrance.accords.split(';').map(a => {
  const [id, pct] = a.split(':');
  const accord = accordsMap.get(id);
  return { name: accord?.name, percentage: +pct, color: accord?.bar_color };
});
```

---

See [DATA_DICTIONARY.md](DATA_DICTIONARY.md) for complete field documentation.
