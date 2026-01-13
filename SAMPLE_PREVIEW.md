# Sample Data Preview

This document previews the FragDB v2.0 sample data. The sample files are interconnected—brands and perfumers match those referenced in the fragrances.

## Files Overview

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| [fragrances.csv](samples/fragrances.csv) | 10 | 28 | Iconic fragrances with all fields |
| [brands.csv](samples/brands.csv) | 7 | 10 | Brands referenced in fragrances.csv |
| [perfumers.csv](samples/perfumers.csv) | 15 | 11 | Perfumers referenced in fragrances.csv |

---

## fragrances.csv Preview

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

### Brand Field Format (v2.0)

The `brand` field now contains `brand_name;brand_id`:

```
Dior;b3
```

Use `brand_id` (e.g., `b3`) to look up full brand details in `brands.csv`.

### Accords Example (Hypnotic Poison)

```
vanilla:100:#FFFEC0:#000000;sweet:86:#EE363B:#FFFFFF;almond:85:#F1E3C5:#000000;...
```

| Accord | Percentage | Background | Text |
|--------|------------|------------|------|
| vanilla | 100% | #FFFEC0 | #000000 |
| sweet | 86% | #EE363B | #FFFFFF |
| almond | 85% | #F1E3C5 | #000000 |
| fruity | 74% | #FC4B29 | #000000 |
| nutty | 69% | #B4955F | #FFFFFF |

### Notes Pyramid Example (Hypnotic Poison)

- **Top**: Coconut, Plum, Apricot
- **Middle**: Brazilian Rosewood, Jasmine, Tuberose, Caraway, Rose, Lily-of-the-Valley
- **Base**: Vanilla, Almond, Sandalwood, Musk

---

## brands.csv Preview

Brands referenced in the sample fragrances.

| ID | Name | Country | Fragrances |
|----|------|---------|------------|
| b3 | Dior | France | 309 |
| b6 | Chanel | France | 150 |
| b15 | Yves Saint Laurent | France | 275 |
| b31 | Lancôme | France | 202 |
| b72 | Dolce&Gabbana | Italy | 139 |
| b92 | Mugler | France | 173 |
| b139 | Tom Ford | United States | 138 |

### All Brand Fields

| Field | Description |
|-------|-------------|
| `id` | Unique identifier (b1, b2, ...) |
| `name` | Brand name |
| `url` | Fragrantica brand page |
| `logo_url` | Brand logo image |
| `country` | Country of origin |
| `main_activity` | Primary business (Fragrances, Cosmetics, Fashion) |
| `website` | Official website |
| `parent_company` | Parent company (LVMH, Coty, etc.) |
| `description` | Brand description (HTML) |
| `brand_count` | Number of fragrances in database |

---

## perfumers.csv Preview

Perfumers (noses) referenced in the sample fragrances.

| ID | Name | Status | Company | Fragrances |
|----|------|--------|---------|------------|
| p2 | Dominique Ropion | Master Perfumer | IFF | 411 |
| p23 | Olivier Polge | In-House Perfumer | Chanel | 167 |
| p25 | Nathalie Lorson | Master Perfumer | Firmenich | 350 |
| p39 | Olivier Cresp | Master Perfumer | Firmenich | 433 |
| p69 | Annick Menardo | Master Perfumer | Symrise | 126 |
| p77 | Jacques Polge | Perfumer | Chanel | 75 |
| p118 | Anne Flipo | Master Perfumer | IFF | 253 |
| p164 | Honorine Blanc | Master Perfumer | Firmenich | 183 |
| p187 | François Demachy | Former in-house | Dior | 211 |
| p203 | Marie Salamagne | Principal Perfumer | Firmenich | 226 |

### All Perfumer Fields

| Field | Description |
|-------|-------------|
| `id` | Unique identifier (p1, p2, ...) |
| `name` | Perfumer full name |
| `url` | Fragrantica perfumer page |
| `photo_url` | Portrait photo |
| `status` | Professional title (Master Perfumer, Perfumer, etc.) |
| `company` | Current employer |
| `also_worked` | Previous companies |
| `education` | Educational background |
| `web` | Personal/professional website |
| `perfumes_count` | Number of fragrances created |
| `biography` | Biography (HTML) |

---

## File Format

All three files share the same format:

| Property | Value |
|----------|-------|
| **Format** | CSV |
| **Separator** | Pipe `\|` |
| **Encoding** | UTF-8 |
| **Quote Character** | `"` (double quote) |
| **Line Ending** | Unix (LF) |
| **Header** | Yes (first row) |

---

## Full Database

This sample demonstrates the data structure. The full FragDB database includes:

| | Sample | Full Database |
|-|--------|---------------|
| Fragrances | 10 | 119,000+ |
| Brands | 7 | 7,200+ |
| Perfumers | 15 | 2,700+ |
| **Total Records** | **32** | **129,000+** |
| **Data Fields** | **49** | **49** |

[Purchase at fragdb.net](https://fragdb.net)

---

See [DATA_DICTIONARY.md](DATA_DICTIONARY.md) for complete field documentation.
