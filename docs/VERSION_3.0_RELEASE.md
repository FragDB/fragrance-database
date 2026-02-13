# FragDB Version 3.0 Release Notes

**Release Date**: January 2026

## Overview

Version 3.0 introduces **two new reference files** (notes and accords) and **significant field format changes** to provide more detailed voting data and better data normalization.

### What's New

- **2 new reference files**: `notes.csv` and `accords.csv`
- **15 new note fields**: Latin names, odor profiles, groups, images
- **5 new accord fields**: Display colors for visualizations
- **New voting format**: All voting fields now include absolute counts AND percentages
- **New fields**: `reviews_count` and `pros_cons` added to fragrances
- **Total data**: 133,000+ rows across 5 files

---

## Database Statistics

| File | Records | Fields | Description |
|------|---------|--------|-------------|
| `fragrances.csv` | 120,871 | 30 | Main fragrance database |
| `brands.csv` | 7,296 | 10 | Brand/designer reference table |
| `perfumers.csv` | 2,815 | 11 | Perfumer (nose) reference table |
| `notes.csv` | 2,448 | 11 | Fragrance notes reference (NEW) |
| `accords.csv` | 92 | 5 | Accords with colors (NEW) |
| **Total** | **133,522** | **67** | |

---

## Breaking Changes

### 1. Voting Field Format Changed

All voting fields now use `category:votes:percent` format.

**Affected fields**: `appreciation`, `price_value`, `ownership`, `gender_votes`, `longevity`, `sillage`, `season`, `time_of_day`

**Old format (v2.x)**:
```
weak:18;moderate:36;long_lasting:14;eternal:5;very_weak:18
```

**New format (v3.0)**:
```
very_weak:4:18;weak:4:18;moderate:8:36;long_lasting:3:14;eternal:1:5
```

**Migration**:
```python
# Old parsing
longevity = {cat: int(pct) for cat, pct in [x.split(':') for x in field.split(';')]}

# New parsing
longevity = {
    cat: {'votes': int(votes), 'percent': float(pct)}
    for cat, votes, pct in [x.split(':') for x in field.split(';')]
}
```

### 2. Accords Field Format Changed

**Old format (v2.x)**:
```
fruity:100:#FC4B29:#000000;sweet:64:#FFD1DC:#000000
```

**New format (v3.0)**:
```
a24:100;a34:64;a38:60
```

The `accords` field now contains `accord_id:percentage` pairs. Use `accords.csv` to look up names and colors.

**Migration**:
```python
# Load accords lookup
accords_df = pd.read_csv('accords.csv', sep='|')
accords_map = {row['id']: row for _, row in accords_df.iterrows()}

# Parse fragrance accords
for item in accords_field.split(';'):
    accord_id, pct = item.split(':')
    accord_info = accords_map.get(accord_id, {})
    print(f"{accord_info.get('name', accord_id)}: {pct}%")
```

### 3. Notes Pyramid Format Changed

**Old format (v2.x)**:
```
top(Bergamot,url,img;Lemon,url,img)mid(...)base(...)
```

**New format (v3.0)**:
```
top(Bergamot,n80,img,0.8,1.2;Lemon,n85,img,1.0,1.0)mid(...)base(...)
```

Now includes:
- Note ID (use to look up in `notes.csv`)
- Opacity (0-1 float)
- Weight (visual size/importance)

### 4. Reminds Of Format Changed

**Old format (v2.x)**:
```
12345;67890;11111
```

**New format (v3.0)**:
```
12345:42:3;67890:28:1;11111:15:0
```

Now includes likes and dislikes for each "reminds of" suggestion: `pid:likes:dislikes`

### 5. Database Structure: 5 Files Instead of 3

Add loading for two new files:
- `notes.csv` - 10 fields, 2,448 records
- `accords.csv` - 5 fields, 92 records

---

## New Files

### notes.csv (11 fields)

Reference table containing detailed fragrance note information.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique note identifier | `n80` |
| `name` | String | Note name | `Orange` |
| `url` | URL | Fragrantica note page | `https://www.fragrantica.com/notes/Orange-80.html` |
| `latin_name` | String | Latin/scientific name | `Citrus sinensis` |
| `other_names` | String | Alternative names | `Sweet Orange, Naranja` |
| `group` | String | Note category | `Citrus smells` |
| `odor_profile` | String | Odor description | Text |
| `main_icon` | URL | Note icon | URL |
| `alt_icons` | String | Alternative icons | Semicolon-separated URLs |
| `background` | URL | Full-size background image | URL |
| `fragrance_count` | Integer | Fragrances with this note | `12847` |

### accords.csv (5 fields)

Reference table containing accord display information.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique accord identifier | `a24` |
| `name` | String | Accord name | `fruity` |
| `bar_color` | String | Background color (hex) | `#FC4B29` |
| `font_color` | String | Text color (hex) | `#000000` |
| `fragrance_count` | Integer | Fragrances with this accord | `45821` |

---

## New Fields in fragrances.csv

### reviews_count

Total number of user reviews for the fragrance.

| Property | Value |
|----------|-------|
| Type | Integer |
| Example | `793` |
| Notes | Complements `rating` which shows average and vote count |

### pros_cons

What People Say — pros and cons with user voting.

| Property | Value |
|----------|-------|
| Type | String |
| Format | `pros(text,likes,dislikes;...)cons(text,likes,dislikes;...)` |
| Example | `pros(Long lasting,42,3;Great projection,28,1)cons(Expensive,15,8)` |

**Parsing**:
```python
import re

def parse_pros_cons(field):
    result = {'pros': [], 'cons': []}
    for key in ['pros', 'cons']:
        match = re.search(rf'{key}\(([^)]*)\)', field)
        if match:
            for item in match.group(1).split(';'):
                parts = item.split(',')
                if len(parts) >= 3:
                    result[key].append({
                        'text': parts[0],
                        'likes': int(parts[1]),
                        'dislikes': int(parts[2])
                    })
    return result
```

---

## Migration Guide (v2.x → v3.0)

### Step 1: Update File Loading

```python
# Old (v2.x)
fragrances = pd.read_csv('fragrances.csv', sep='|')
brands = pd.read_csv('brands.csv', sep='|')
perfumers = pd.read_csv('perfumers.csv', sep='|')

# New (v3.0)
fragrances = pd.read_csv('fragrances.csv', sep='|')
brands = pd.read_csv('brands.csv', sep='|')
perfumers = pd.read_csv('perfumers.csv', sep='|')
notes = pd.read_csv('notes.csv', sep='|')       # NEW
accords = pd.read_csv('accords.csv', sep='|')   # NEW
```

### Step 2: Update Accords Parsing

```python
# Create lookup map
accords_map = {row['id']: row.to_dict() for _, row in accords.iterrows()}

# Old parsing (v2.x)
def parse_accords_v2(field):
    return [{
        'name': parts[0],
        'percentage': int(parts[1]),
        'bg_color': parts[2],
        'text_color': parts[3]
    } for parts in (x.split(':') for x in field.split(';'))]

# New parsing (v3.0)
def parse_accords_v3(field, lookup=accords_map):
    result = []
    for item in field.split(';'):
        accord_id, pct = item.split(':')
        accord_info = lookup.get(accord_id, {})
        result.append({
            'id': accord_id,
            'name': accord_info.get('name', accord_id),
            'percentage': int(pct),
            'bar_color': accord_info.get('bar_color'),
            'font_color': accord_info.get('font_color')
        })
    return result
```

### Step 3: Update Voting Fields Parsing

```python
# Old parsing (v2.x) - just percentages
def parse_votes_v2(field):
    return {cat: int(val) for cat, val in [x.split(':') for x in field.split(';')]}

# New parsing (v3.0) - votes AND percentages
def parse_votes_v3(field):
    result = {}
    for item in field.split(';'):
        parts = item.split(':')
        if len(parts) >= 3:
            result[parts[0]] = {
                'votes': int(parts[1]),
                'percent': float(parts[2])
            }
    return result
```

### Step 4: Update Notes Pyramid Parsing

```python
import re

# Create notes lookup map
notes_map = {row['id']: row.to_dict() for _, row in notes.iterrows()}

def parse_notes_pyramid(field, lookup=notes_map):
    result = {}
    for layer, content in re.findall(r'(top|mid|base|notes)\(([^)]*)\)', field):
        notes_list = []
        for note in content.split(';'):
            parts = note.split(',')
            if len(parts) >= 5:
                note_id = parts[1]
                note_info = lookup.get(note_id, {})
                notes_list.append({
                    'name': parts[0],
                    'id': note_id,
                    'image': parts[2],
                    'opacity': float(parts[3]) if parts[3] else 1.0,
                    'weight': float(parts[4]) if parts[4] else 1.0,
                    'latin_name': note_info.get('latin_name'),
                    'group': note_info.get('group')
                })
        result[layer] = notes_list
    return result
```

### Step 5: Update Reminds Of Parsing

```python
# Old parsing (v2.x)
def parse_reminds_of_v2(field):
    return [int(pid) for pid in field.split(';')]

# New parsing (v3.0)
def parse_reminds_of_v3(field):
    result = []
    for item in field.split(';'):
        parts = item.split(':')
        if len(parts) >= 3:
            result.append({
                'pid': int(parts[0]),
                'likes': int(parts[1]),
                'dislikes': int(parts[2])
            })
    return result
```

---

## Benefits of New Structure

- **More granular voting data**: Know both absolute votes AND percentages
- **Normalized accords**: Accord colors stored once in reference table
- **Rich note metadata**: Latin names, odor profiles, note groups
- **Better visualizations**: Use opacity/weight for note pyramid displays
- **Community feedback**: Likes/dislikes on "reminds of" suggestions
- **AI insights**: Pros/cons with user voting

---

## File Format Specifications

All five files share the same format:

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
- `brands.csv` - 10 related brands
- `perfumers.csv` - 10 related perfumers
- `notes.csv` - 10 sample notes
- `accords.csv` - 10 sample accords

---

## Questions & Support

For questions about the new multi-file structure or migration assistance:
- Email: support@fragdb.net
- Website: https://fragdb.net

---

*Last updated: January 2026*
