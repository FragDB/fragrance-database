# Sample Data Preview

Preview of the FragDB v5.16 sample data. All files are interconnected via IDs. Includes 23 language translations.

## Files Overview

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| [fragrances.csv](samples/fragrances.csv) | 10 | 30 | Top-rated fragrances |
| [brands.csv](samples/brands.csv) | 10 | 54 | Brand profiles + 22 lang translations |
| [perfumers.csv](samples/perfumers.csv) | 10 | 42 | Perfumer profiles + 22 lang translations + 9 name transliterations |
| [notes.csv](samples/notes.csv) | 10 | 55 | Fragrance notes + 22 lang translations |
| [accords.csv](samples/accords.csv) | 10 | 27 | Accords + 22 lang translations |
| [translations.csv](samples/translations.csv) | 34 | 25 | Gender & voting label vocabulary (full) |

## Parquet samples (Full tier preview)

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| [comments_sample.parquet](samples/comments_sample.parquet) | 25 | 8 | User reviews preview |
| [news_sample.parquet](samples/news_sample.parquet) | 20 | 16 | Editorial articles preview |
| [news_comments_sample.parquet](samples/news_comments_sample.parquet) | 20 | 9 | News comments preview |
| [SPEC.md](SPEC.md) | — | — | Parquet schema documentation |

Parquet datasets ship in all paid tiers except $200 Core.

---

## fragrances.csv

### Key Fields

| PID | Name | Brand | Year | Gender |
|-----|------|-------|------|--------|
| 485 | Light Blue | Dolce&Gabbana;b72 | 2001 | for women |
| 707 | Alien | Mugler;b92 | 2005 | for women |
| 14982 | La Vie Est Belle | Lancôme;b31 | 2012 | for women |
| 704 | Angel | Mugler;b92 | 1992 | for women |
| 25324 | Black Opium | Yves Saint Laurent;b15 | 2014 | for women |
| 31861 | Sauvage | Dior;b3 | 2015 | for men |
| 611 | Coco Mademoiselle | Chanel;b6 | 2001 | for women |
| 1018 | Black Orchid | Tom Ford;b139 | 2006 | for women |
| 1825 | Tobacco Vanille | Tom Ford;b139 | 2007 | for women and men |
| 16657 | Eros | Versace;b83 | 2012 | for men |

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

Example: `Dolce&Gabbana;b72` — use `b72` to join with brands.csv

### Accords Field Format (v3.0+)

```
accord_id:percentage;...
```

Example: `a24:100;a91:75;a33:63;a35:59`

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
| b2723 | The Dua Brand | United States |
| b91 | Avon | United States |
| b627 | Zara | Spain |
| b207 | Victoria's Secret | United States |
| b383 | Bath & Body Works | United States |
| b1945 | Jequiti | Brazil |
| b436 | O Boticário | Brazil |
| b7 | Guerlain | France |
| b567 | Natura | Brazil |
| b1205 | Dzintars | Latvia |

**Fields**: `id`, `name`, `url`, `logo_url`, `country`, `main_activity`, `website`, `parent_company`, `description`, `brand_count`

---

## perfumers.csv

| ID | Name | Company |
|----|------|---------|
| p1141 | Mahsam Raza | — |
| p24 | Alberto Morillas | dsm-firmenich |
| p2 | Dominique Ropion | IFF |
| p39 | Olivier Cresp | dsm-firmenich, Akro |
| p383 | Verônica Kato | Natura |
| p93 | Bertrand Duchaufour | TechnicoFlor |
| p85 | Christian Provenzano | CPL Aromas |
| p283 | Jérôme Epinette | Robertet |
| p25 | Nathalie Lorson | dsm-firmenich |
| p608 | Chris Maurice | C De La Niche |

**Fields**: `id`, `name`, `url`, `photo_url`, `status`, `company`, `also_worked`, `education`, `web`, `perfumes_count`, `biography`

---

## notes.csv

| ID | Name | Group |
|----|------|-------|
| n2260 | Musk | Musk, amber, animalic smells |
| n54 | Amber | Musk, amber, animalic smells |
| n2480 | Vanilla | Spices |
| n75 | Bergamot | Citrus smells |
| n2401 | Sandalwood | Woods and mosses |
| n2185 | Jasmine | White flowers |
| n2304 | Patchouli | Woods and mosses |
| n2384 | Rose | Flowers |
| n1985 | Cedar | Woods and mosses |
| n2490 | Vetiver | Woods and mosses |

**Fields**: `id`, `name`, `url`, `latin_name`, `other_names`, `group`, `odor_profile`, `main_icon`, `alt_icons`, `background`, `fragrance_count`

---

## accords.csv

| ID | Name | Bar Color | Font Color |
|----|------|-----------|------------|
| a91 | woody | #774414 | #FFFFFF |
| a62 | powdery | #EEDDCC | #000000 |
| a75 | sweet | #EE363B | #FFFFFF |
| a24 | citrus | #F9FF52 | #000000 |
| a8 | aromatic | #37A089 | #000000 |
| a86 | warm spicy | #CC3300 | #FFFFFF |
| a34 | fresh spicy | #83C928 | #000000 |
| a4 | amber | #BC4D10 | #FFFFFF |
| a31 | floral | #FF5F8D | #000000 |
| a53 | musky | #E7D8EA | #000000 |

**Fields**: `id`, `name`, `bar_color`, `font_color`, `fragrance_count`

---

## Joining Tables

> **The preview files are independent slices.** Each one holds the top 10 rows of its own
> table, so an id taken from `fragrances.csv` usually has no matching row in this 10-row
> `brands.csv` — 10 of the 31 accord ids resolve, none of the 8 brand ids do. The snippets
> below are the joins you run against the full database; on the preview they will return few
> rows or none, and that is the sample being small, not the data being broken.

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
