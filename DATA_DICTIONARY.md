# FragDB v5 — Data Dictionary

Generated: 2026-04-19

## Overview

| File | Records | Fields |
|------|---------|--------|
| fragrances.csv | 128,246 | 30 |
| brands.csv | 7,661 | 54 |
| perfumers.csv | 2,920 | 36 |
| notes.csv | 2,510 | 55 |
| accords.csv | 92 | 27 |
| translations.csv | 34 | 25 |

Languages: en + 22 (de, es, fr, cs, it, ru, pl, pt, el, zh, ja, nl, sr, ro, ar, uk, mn, ko, tr, sv, he, hu)

---

## fragrances.csv

Main fragrance database. Gender and voting fields use translation IDs from translations.csv.
Notes pyramid references notes.csv by note_id.

| Field | Type | Description | Format/Example |
|-------|------|-------------|----------------|
| pid | Integer | Unique fragrance ID | `9828` |
| url | URL | Fragrantica page | `https://www.fragrantica.com/perfume/Creed/Aventus-9828.html` |
| brand | String | Brand name and ID | `Creed;b68` — split by `;`, second part is brands.csv ID |
| name | String | Fragrance name | `Aventus` |
| year | Integer | Release year | `2010` or empty |
| gender | Translation ID | Target gender | `gender_for_men` — look up in translations.csv |
| collection | String | Collection within brand | `Aventus` or empty |
| main_photo | URL | Bottle image | URL or empty |
| info_card | URL | Social card image | URL or empty |
| user_photoes | URLs | User photos | `;`-separated URLs or empty |
| video_url | URLs | YouTube + HLS videos | `;`-separated URLs or empty (~99% empty) |
| accords | String | Scent accords | `a35:100;a75:68` — accord_id:percent, sorted desc. JOIN accords.csv |
| notes_pyramid | String | Notes by layer | `top(n75,0.96,3.73;n132,0.92,3.42)middle(...)base(...)` or `notes(...)` |
| perfumers | String | Perfumer names/IDs | `name;id;name;id` — JOIN perfumers.csv by ID |
| description | HTML | Description (EN only) | HTML text or empty |
| rating | String | Rating and votes | `4.32;26253` — average;total_votes |
| reviews_count | Integer | User reviews count | `4200` or empty |
| appreciation | Translation IDs | Sentiment votes | `like_love:15500:59;like_like:6600:25` — tid:votes:percent |
| price_value | Translation IDs | Price perception | `price_way_overpriced:7100:57;price_ok:1500:12` |
| gender_votes | Translation IDs | Gender suitability votes | `gvotes_male:8600:68;gvotes_unisex:909:7` |
| longevity | Translation IDs | Duration votes | `longevity_moderate:6300:39;longevity_long_lasting:6000:37` |
| sillage | Translation IDs | Projection votes | `sillage_moderate:8600:53;sillage_strong:4500:27` |
| season | Translation IDs | Seasonal suitability | `season_summer:12400:100;season_spring:12100:98` |
| time_of_day | Translation IDs | Day/night suitability | `season_day:12400:100;season_night:8500:69` |
| pros_cons | String | AI pros/cons (EN only) | `pros(text,likes,dislikes;...)cons(...)` or empty (~90% empty) |
| by_designer | PIDs | Same brand fragrances | `;`-separated PIDs |
| in_collection | PIDs | Same collection fragrances | `;`-separated PIDs or empty |
| reminds_of | String | Similar fragrances | `pid:likes:dislikes;...` or empty |
| also_like | PIDs | User recommendations | `;`-separated PIDs or empty |
| news_ids | IDs | Related news articles | `;`-separated IDs or empty |

### Notes pyramid format

`level(note_id,opacity,weight;note_id,opacity,weight;...)level(...)`

- **Levels**: `top`, `middle`, `base` — or just `notes` when layers unknown
- **note_id**: JOIN with notes.csv for name, icon, translations
- **opacity**: 0.0–1.0 (visual prominence, 1.0 = most prominent)
- **weight**: visual size on pyramid chart

### Voting field format

All voting fields: `translation_id:votes:percent;...`

- **translation_id**: look up in translations.csv for label in any language
- **votes**: absolute vote count (integer)
- **percent**: percentage of total votes (float)

---

## translations.csv

Vocabulary for gender values and voting labels. 34 entries in 23 languages.

| Field | Description |
|-------|-------------|
| id | Translation ID used in fragrances.csv |
| section | Which field uses this ID (gender, gender_votes, appreciation, longevity, sillage, season, price_value) |
| en | English label |
| de...hu | 22 language translations |

### All translation IDs

| ID | Section | EN |
|----|---------|-----|
| gender_for_women | gender | for women |
| gender_for_men | gender | for men |
| gender_for_women_and_men | gender | for women and men |
| gvotes_female | gender_votes | female |
| gvotes_more_female | gender_votes | more female |
| gvotes_unisex | gender_votes | unisex |
| gvotes_more_male | gender_votes | more male |
| gvotes_male | gender_votes | male |
| gvotes_shared | gender_votes | shared |
| like_love | appreciation | love |
| like_like | appreciation | like |
| like_ok | appreciation | ok |
| like_dislike | appreciation | dislike |
| like_hate | appreciation | hate |
| longevity_very_weak | longevity | very weak |
| longevity_weak | longevity | weak |
| longevity_moderate | longevity | moderate |
| longevity_long_lasting | longevity | long lasting |
| longevity_eternal | longevity | eternal |
| sillage_intimate | sillage | intimate |
| sillage_moderate | sillage | moderate |
| sillage_strong | sillage | strong |
| sillage_enormous | sillage | enormous |
| season_winter | season | winter |
| season_spring | season | spring |
| season_summer | season | summer |
| season_fall | season | fall |
| season_day | season / time_of_day | day |
| season_night | season / time_of_day | night |
| price_way_overpriced | price_value | way overpriced |
| price_overpriced | price_value | overpriced |
| price_ok | price_value | ok |
| price_good_value | price_value | good value |
| price_great_value | price_value | great value |

---

## brands.csv

Brand/designer profiles with translations.

| # | Field | Description |
|---|-------|-------------|
| 1 | id | Unique ID (b1, b68...) |
| 2 | name | Brand name |
| 3 | url | Fragrantica page URL |
| 4 | logo_url | Logo image URL |
| 5 | country | Country of origin (EN) |
| 6 | main_activity | Business type (EN) |
| 7 | website | Official website URL |
| 8 | parent_company | Parent company |
| 9 | description | Description (HTML, EN) |
| 10 | brand_count | Fragrances in database |
| 11-32 | country_de...country_hu | Country in 22 languages |
| 33-54 | main_activity_de...main_activity_hu | Business type in 22 languages |

---

## perfumers.csv

Perfumer (nose) profiles with translations.

| # | Field | Description |
|---|-------|-------------|
| 1 | id | Unique ID (p1, p138...) |
| 2 | name | Perfumer name (EN) |
| 3 | url | Fragrantica page URL |
| 4 | photo_url | Photo URL |
| 5 | status | Professional status (EN) |
| 6 | company | Current company |
| 7 | also_worked | Previous companies |
| 8 | education | Education |
| 9 | web | Personal website |
| 10 | perfumes_count | Fragrances created |
| 11 | biography | Biography (HTML, EN) |
| 12-33 | status_de...status_hu | Status in 22 languages |
| 34 | perfumer_name_ru | Name in Russian |
| 35 | perfumer_name_uk | Name in Ukrainian |
| 36 | perfumer_name_ja | Name in Japanese |

---

## notes.csv

Fragrance note reference with translations. Each unique (name, URL, icon) combination = separate entry.

| # | Field | Description |
|---|-------|-------------|
| 1 | id | Unique ID (n80, n105, n1900...) |
| 2 | name | Note name as on perfume page (EN) |
| 3 | url | Note page URL |
| 4 | latin_name | Scientific/Latin name |
| 5 | other_names | Alternative names |
| 6 | group | Category (Citrus, Flowers, Woods...) |
| 7 | odor_profile | Scent description |
| 8 | main_icon | Note icon URL (from perfume pyramids) |
| 9 | alt_icons | Alternative icons (`;`-sep) |
| 10 | background | Background image URL |
| 11 | fragrance_count | Fragrances using this note |
| 12-33 | note_name_de...note_name_hu | Note name in 22 languages |
| 34-55 | note_group_de...note_group_hu | Group in 22 languages |

**Note variants**: Rose, Damask Rose, Turkish Rose may share the same page URL but have separate IDs, names, and translations.

---

## accords.csv

Fragrance accord reference with display colors and translations.

| # | Field | Description |
|---|-------|-------------|
| 1 | id | Unique ID (a1, a24...) |
| 2 | name | Accord name (EN) |
| 3 | bar_color | Display color (#hex) |
| 4 | font_color | Text color (#hex) |
| 5 | fragrance_count | Fragrances with this accord |
| 6-27 | name_de...name_hu | Accord name in 22 languages |