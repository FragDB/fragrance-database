# Sample Data Preview

This table shows a preview of the FragDB sample data. The full sample contains 10 fragrances with all 28 fields.

## Quick Preview (Key Fields)

| PID | Name | Brand | Year | Gender | Rating |
|-----|------|-------|------|--------|--------|
| 219 | Hypnotic Poison | Dior | 1998 | for women | 4.09 |
| 485 | Light Blue | Dolce&Gabbana | 2001 | for women | 3.86 |
| 611 | Coco Mademoiselle | Chanel | 2001 | for women | 4.27 |
| 704 | Angel | Mugler | 1992 | for women | 3.92 |
| 707 | Alien | Mugler | 2005 | for women | 4.09 |
| 1018 | Black Orchid | Tom Ford | 2006 | for women | 4.08 |
| 1825 | Tobacco Vanille | Tom Ford | 2007 | for women and men | 4.35 |
| 14982 | La Vie Est Belle | Lancôme | 2012 | for women | 3.91 |
| 25324 | Black Opium | Yves Saint Laurent | 2014 | for women | 4.09 |
| 31861 | Sauvage | Dior | 2015 | for men | 4.12 |

## Download Full Sample

Download [SAMPLE.csv](./SAMPLE.csv) to see all 28 fields including:

- **Identity**: pid, url, brand, name, year, gender, collection
- **Media**: main_photo, info_card, user_photoes
- **Composition**: accords, notes_pyramid, perfumers, description
- **Ratings**: rating, appreciation, price_value, ownership
- **Characteristics**: gender_votes, longevity, sillage, season, time_of_day
- **Related**: by_designer, in_collection, reminds_of, also_like, news_ids

## Format Details

- **Delimiter**: `|` (pipe character)
- **Encoding**: UTF-8
- **Header**: First row contains field names

See [DATA_DICTIONARY.md](./DATA_DICTIONARY.md) for complete field documentation.

## Example: Accords (Hypnotic Poison)

```
vanilla:100:#FFFEC0:#000000;sweet:86:#EE363B:#FFFFFF;almond:85:#F1E3C5:#000000;...
```

| Accord | Percentage | Background Color |
|--------|------------|------------------|
| vanilla | 100% | #FFFEC0 |
| sweet | 86% | #EE363B |
| almond | 85% | #F1E3C5 |
| fruity | 74% | #FC4B29 |
| nutty | 69% | #B4955F |

## Example: Notes Pyramid (Hypnotic Poison)

- **Top**: Coconut, Plum, Apricot
- **Middle**: Brazilian Rosewood, Jasmine, Tuberose, Caraway, Rose, Lily-of-the-Valley
- **Base**: Vanilla, Almond, Sandalwood, Musk

## Full Database

This sample contains 10 iconic fragrances. The full FragDB database includes:

- **119,000+** fragrances
- **7,200+** brands
- **2,400+** unique notes
- **92** unique accords

[Purchase at fragdb.net](https://fragdb.net)
