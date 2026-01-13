# FragDB Version 2.0 Release Notes

**Release Date**: January 2026

## Overview

Version 2.0 introduces a **multi-file database structure** that significantly expands the available data. The database now consists of **3 CSV files** instead of a single file, providing comprehensive information about fragrances, brands, and perfumers.

### What's New

- **2 new reference files**: `brands.csv` and `perfumers.csv`
- **10 new brand fields**: logo, country, business activity, website, parent company, description
- **11 new perfumer fields**: photo, status, company, education, biography
- **Relational structure**: Link fragrances to full brand/perfumer profiles via IDs
- **Total data**: 128,000+ rows across all files

---

## Database Statistics

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| `fragrances.csv` | ~120,000 | 28 | Main fragrance database |
| `brands.csv` | ~7,200 | 10 | Brand/designer reference table |
| `perfumers.csv` | ~2,800 | 11 | Perfumer (nose) reference table |
| **Total** | **~130,000** | **49** | |

---

## File Structure

### fragrances.csv (Main Database)

The main fragrance file remains largely unchanged, with **two field format updates** to support the new relational structure:

#### Changed Fields

##### `brand` field (UPDATED FORMAT)

**Old format (v1.x)**:
```
brand_name;brand_page_url;brand_logo_url
Creed;https://www.fragrantica.com/designers/Creed.html;https://fimgs.net/mdimg/dizajneri/o.37.jpg
```

**New format (v2.0)**:
```
brand_name;brand_id
Creed;b1
```

**Migration**: Use `brand_id` to look up full brand details in `brands.csv`. The ID format is `bN` where N is a unique integer (e.g., `b1`, `b42`, `b1503`).

##### `perfumers` field (UPDATED FORMAT)

**Old format (v1.x)**:
```
name,page_url,photo_url;name,page_url,photo_url
Erwin Creed,https://www.fragrantica.com/noses/Erwin_Creed.html,https://frgs.me/mdimg/nosevi/fit.865.jpg
```

**New format (v2.0)**:
```
name1;id1;name2;id2;...
Erwin Creed;p1;Jean-Claude Ellena;p5
```

**Migration**: Use `perfumer_id` to look up full perfumer details in `perfumers.csv`. The ID format is `pN` where N is a unique integer (e.g., `p1`, `p42`, `p865`).

---

### brands.csv (NEW FILE)

Reference table containing detailed brand/designer information.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique brand identifier | `b1` |
| `name` | String | Brand name | `Creed` |
| `url` | URL | Fragrantica brand page | `https://www.fragrantica.com/designers/Creed.html` |
| `logo_url` | URL | Brand logo image | `https://fimgs.net/mdimg/designers/g195.png` |
| `country` | String | Country of origin | `France` |
| `main_activity` | String | Primary business activity | `Fragrance house` |
| `website` | URL | Official brand website | `https://www.creed.com` |
| `parent_company` | String | Parent/holding company | `Kering` |
| `description` | HTML | Brand description text | `<p>Creed is a French fragrance house...</p>` |
| `brand_count` | Integer | Number of fragrances in database | `847` |

#### Field Details

##### id
- **Format**: `bN` where N is a positive integer
- **Examples**: `b1`, `b42`, `b1503`
- **Notes**: Primary key. Use to join with `brand` field in `fragrances.csv`

##### name
- **Notes**: Never empty. Official brand/designer name.

##### url
- **Notes**: Absolute URL to brand's profile page on Fragrantica. May be empty for some brands.

##### logo_url
- **Notes**: URL to brand logo image (PNG format). May be empty.

##### country
- **Notes**: Country where the brand is based or originated. May be empty.

##### main_activity
- **Values**: "Fragrance house", "Fashion house", "Celebrity", "Niche", etc.
- **Notes**: Primary business category. May be empty.

##### website
- **Notes**: Official brand website URL. May be empty.

##### parent_company
- **Notes**: Parent company or conglomerate (e.g., LVMH, Estée Lauder, Coty). May be empty.

##### description
- **Format**: HTML text with `<p>`, `<br>` tags
- **Notes**: Brand history and description. Sanitize before rendering. May be empty.

##### brand_count
- **Notes**: Total number of fragrances by this brand in the database.

---

### perfumers.csv (NEW FILE)

Reference table containing detailed perfumer (nose) information.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique perfumer identifier | `p1` |
| `name` | String | Perfumer full name | `Alberto Morillas` |
| `url` | URL | Fragrantica perfumer page | `https://www.fragrantica.com/noses/Alberto_Morillas.html` |
| `photo_url` | URL | Perfumer portrait photo | `https://fimgs.net/mdimg/nosevi/fit.123.jpg` |
| `status` | String | Professional status/title | `Master Perfumer` |
| `company` | String | Current employer | `Firmenich` |
| `also_worked` | String | Previous companies | `Quest International, Givaudan` |
| `education` | String | Educational background | `ISIPCA` |
| `web` | URL | Personal/professional website | `https://www.perfumer.com` |
| `perfumes_count` | Integer | Number of fragrances created | `538` |
| `biography` | HTML | Perfumer biography | `<p>Alberto Morillas is a Spanish perfumer...</p>` |

#### Field Details

##### id
- **Format**: `pN` where N is a positive integer
- **Examples**: `p1`, `p42`, `p865`
- **Notes**: Primary key. Use to join with `perfumers` field in `fragrances.csv`

##### name
- **Notes**: Never empty. Perfumer's full name.

##### url
- **Notes**: Absolute URL to perfumer's profile page on Fragrantica. May be empty.

##### photo_url
- **Notes**: URL to perfumer's portrait photo. May be empty.

##### status
- **Values**: "Master Perfumer", "Senior Perfumer", "Perfumer", "Independent Perfumer", etc.
- **Notes**: Professional title or status. May be empty.

##### company
- **Notes**: Current employer (fragrance house). May be empty for independent perfumers.

##### also_worked
- **Format**: Comma-separated list of companies
- **Notes**: Previous employers. May be empty.

##### education
- **Notes**: Educational institution (commonly ISIPCA, Givaudan School, GIP). May be empty.

##### web
- **Notes**: Personal or professional website URL. May be empty.

##### perfumes_count
- **Notes**: Total number of fragrances created by this perfumer in the database.

##### biography
- **Format**: HTML text with `<p>`, `<br>` tags
- **Notes**: Perfumer's biographical information. Sanitize before rendering. May be empty.

---

## Data Relationships

```
┌─────────────────────────────────────────────────────────────────────┐
│                         fragrances.csv                               │
│                                                                      │
│  pid | brand          | perfumers                    | ...           │
│  ────┼────────────────┼──────────────────────────────┼───           │
│  9828│ Creed;b1       │ Erwin Creed;p1;J.C. Hérault;p5│              │
│      │      │         │            │              │   │              │
└──────┼──────┼─────────┼────────────┼──────────────┼───┘
       │      │         │            │              │
       │      ▼         │            ▼              ▼
       │  ┌─────────────┴──┐    ┌─────────────────────┐
       │  │  brands.csv    │    │   perfumers.csv     │
       │  │                │    │                     │
       │  │  id   | name   │    │  id  | name         │
       │  │  ─────┼─────── │    │  ────┼───────────── │
       │  │  b1   | Creed  │    │  p1  | Erwin Creed  │
       │  │  ...  | ...    │    │  p5  | J.C. Hérault │
       │  └────────────────┘    └─────────────────────┘
       │
       └──────────────────────────────────────────────────────────────
```

### Joining Tables

#### Python Example

```python
import pandas as pd

# Load all three files
fragrances = pd.read_csv('fragrances.csv', sep='|', encoding='utf-8')
brands = pd.read_csv('brands.csv', sep='|', encoding='utf-8')
perfumers = pd.read_csv('perfumers.csv', sep='|', encoding='utf-8')

# Extract brand_id from brand field
fragrances['brand_id'] = fragrances['brand'].apply(
    lambda x: x.split(';')[1] if pd.notna(x) and ';' in str(x) else None
)

# Join with brands
fragrances_with_brands = fragrances.merge(
    brands,
    left_on='brand_id',
    right_on='id',
    how='left',
    suffixes=('', '_brand')
)

# Now you have access to:
# - logo_url, country, main_activity, website, parent_company, description
```

#### SQL Example

```sql
-- Join fragrances with brands
SELECT
    f.pid,
    f.name AS fragrance_name,
    b.name AS brand_name,
    b.country,
    b.logo_url,
    b.website
FROM fragrances f
LEFT JOIN brands b ON SUBSTRING_INDEX(f.brand, ';', -1) = b.id;

-- Join fragrances with perfumers (requires parsing)
-- Note: perfumers field contains multiple IDs, requires special handling
```

#### JavaScript Example

```javascript
// Parse brand field and lookup
function getBrandDetails(brandField, brandsMap) {
    if (!brandField) return null;
    const [name, id] = brandField.split(';');
    return brandsMap.get(id) || { name, id };
}

// Parse perfumers field and lookup all
function getPerfumersDetails(perfumersField, perfumersMap) {
    if (!perfumersField) return [];
    const parts = perfumersField.split(';');
    const result = [];
    for (let i = 0; i < parts.length; i += 2) {
        const name = parts[i];
        const id = parts[i + 1];
        const details = perfumersMap.get(id) || { name, id };
        result.push(details);
    }
    return result;
}
```

---

## Migration Guide (v1.x → v2.0)

### Breaking Changes

1. **`brand` field format changed**
   - v1.x: `brand_name;brand_page_url;brand_logo_url`
   - v2.0: `brand_name;brand_id`
   - **Action**: Update parsing logic, use `brands.csv` for additional data

2. **`perfumers` field format changed**
   - v1.x: `name,page_url,photo_url;name,page_url,photo_url`
   - v2.0: `name1;id1;name2;id2;...`
   - **Action**: Update parsing logic, use `perfumers.csv` for additional data

### Migration Steps

1. **Download all 3 files** instead of just `fragrances.csv`
2. **Update your data loading code** to handle multiple files
3. **Update brand parsing**:
   ```python
   # Old (v1.x)
   brand_name, brand_url, logo_url = brand_field.split(';')

   # New (v2.0)
   brand_name, brand_id = brand_field.split(';')
   # Then lookup in brands.csv for url, logo_url, etc.
   ```
4. **Update perfumers parsing**:
   ```python
   # Old (v1.x)
   for perfumer in perfumers_field.split(';'):
       name, url, photo = perfumer.split(',')

   # New (v2.0)
   parts = perfumers_field.split(';')
   for i in range(0, len(parts), 2):
       name, perfumer_id = parts[i], parts[i+1]
       # Then lookup in perfumers.csv for url, photo, etc.
   ```

### Benefits of New Structure

- **More data**: 10 additional brand fields, 11 additional perfumer fields
- **Smaller file sizes**: Brand/perfumer details stored once, not repeated
- **Easier updates**: Reference tables can be updated independently
- **Better normalization**: Proper relational database structure

---

## File Format Specifications

All three files share the same format:

| Property | Value |
|----------|-------|
| Format | CSV |
| Separator | Pipe `\|` |
| Encoding | UTF-8 |
| Quote Character | `"` (double quote) |
| Line Ending | Unix (LF) |
| Header | Yes (first row) |

### Sample File Structure

The free sample includes:
- `fragrances.csv` - 10 fragrance records
- `brands.csv` - 7 related brands (matching fragrances)
- `perfumers.csv` - 15 related perfumers (matching fragrances)

---

## Changelog

### [2.0.0] - January 2026

#### Added
- New file: `brands.csv` with 10 fields per brand (~7,200 records)
- New file: `perfumers.csv` with 11 fields per perfumer (~2,800 records)
- Brand fields: id, name, url, logo_url, country, main_activity, website, parent_company, description, brand_count
- Perfumer fields: id, name, url, photo_url, status, company, also_worked, education, web, perfumes_count, biography

#### Changed
- `brand` field format: now contains `brand_name;brand_id` instead of full URLs
- `perfumers` field format: now contains `name;id` pairs instead of full details

#### Database Statistics
- **Total fragrances**: ~120,000
- **Total brands**: ~7,200
- **Total perfumers**: ~2,800
- **Total records**: ~130,000
- **Total fields**: 49 (28 + 10 + 11)

---

## Questions & Support

For questions about the new multi-file structure or migration assistance:
- Email: support@fragdb.net
- Website: https://fragdb.net

---

*Last updated: January 2026*
