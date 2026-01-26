#!/usr/bin/env python3
"""
FragDB - Parse Complex Fields Example (v3.0)

Demonstrates how to parse complex fields like accords, notes_pyramid, voting fields, etc.
Updated for v3.0 field formats.
"""

import re
from typing import List, Dict, Any, Optional
import pandas as pd
from load_database import load_fragdb


def parse_accords(accords_str: str, accords_df: Optional[pd.DataFrame] = None) -> List[Dict[str, Any]]:
    """Parse the accords field into a list of dictionaries.

    v3.0 Format: accord_id:percentage;accord_id:percentage;...
    Example: a24:100;a34:64;a38:60

    Use accords_df to look up accord names and colors.
    """
    if not accords_str or pd.isna(accords_str):
        return []

    accords = []
    for accord in accords_str.split(";"):
        parts = accord.split(":")
        if len(parts) >= 2:
            accord_id = parts[0]
            percentage = int(parts[1]) if parts[1].isdigit() else 0

            accord_info = {"id": accord_id, "percentage": percentage}

            # Look up name and colors from accords.csv if provided
            if accords_df is not None:
                match = accords_df[accords_df["id"] == accord_id]
                if not match.empty:
                    row = match.iloc[0]
                    accord_info["name"] = row["name"]
                    accord_info["bar_color"] = row["bar_color"]
                    accord_info["font_color"] = row["font_color"]

            accords.append(accord_info)

    return accords


def parse_notes_pyramid(notes_str: str, notes_df: Optional[pd.DataFrame] = None) -> Dict[str, List[Dict[str, Any]]]:
    """Parse the notes_pyramid field into a structured dictionary.

    v3.0 Format: layer(name,note_id,img,opacity,weight;...)
    Layers: top, mid, base, or notes (flat)

    Opacity: 0-1 float indicating note transparency
    Weight: visual size/importance of the note
    """
    if not notes_str or pd.isna(notes_str):
        return {}

    result = {}
    # Match layer(contents) pattern
    layers = re.findall(r'(top|mid|base|notes)\(([^)]*)\)', notes_str)

    for layer_name, notes_content in layers:
        notes = []
        for note in notes_content.split(";"):
            parts = note.split(",")
            if len(parts) >= 5:
                note_id = parts[1]
                note_info = {
                    "name": parts[0],
                    "id": note_id,
                    "image": parts[2],
                    "opacity": float(parts[3]) if parts[3] else 1.0,
                    "weight": float(parts[4]) if parts[4] else 1.0
                }

                # Look up additional info from notes.csv if provided
                if notes_df is not None and note_id:
                    match = notes_df[notes_df["id"] == note_id]
                    if not match.empty:
                        row = match.iloc[0]
                        note_info["latin_name"] = row.get("latin_name", "")
                        note_info["group"] = row.get("group", "")

                notes.append(note_info)
            elif len(parts) >= 3:
                # Fallback for simpler format
                notes.append({
                    "name": parts[0],
                    "id": parts[1] if len(parts) > 1 else "",
                    "image": parts[2] if len(parts) > 2 else "",
                    "opacity": 1.0,
                    "weight": 1.0
                })
        result[layer_name] = notes

    return result


def parse_rating(rating_str: str) -> Dict[str, float]:
    """Parse the rating field into average and count.

    Format: average;vote_count
    """
    if not rating_str or pd.isna(rating_str):
        return {"average": 0.0, "votes": 0}

    parts = rating_str.split(";")
    return {
        "average": float(parts[0]) if len(parts) > 0 else 0.0,
        "votes": int(parts[1]) if len(parts) > 1 else 0
    }


def parse_brand(brand_str: str) -> Dict[str, str]:
    """Parse the brand field into name and ID.

    Format: brand_name;brand_id
    Example: Dior;b3
    """
    if not brand_str or pd.isna(brand_str):
        return {"name": "", "id": ""}

    parts = brand_str.split(";")
    return {
        "name": parts[0] if len(parts) > 0 else "",
        "id": parts[1] if len(parts) > 1 else ""
    }


def parse_perfumers(perfumers_str: str) -> List[Dict[str, str]]:
    """Parse the perfumers field into a list of dictionaries.

    Format: name1;id1;name2;id2;...
    Example: Erwin Creed;p1;Jean-Claude Ellena;p5
    """
    if not perfumers_str or pd.isna(perfumers_str):
        return []

    parts = perfumers_str.split(";")
    perfumers = []

    for i in range(0, len(parts), 2):
        if i + 1 < len(parts):
            perfumers.append({
                "name": parts[i],
                "id": parts[i + 1]
            })

    return perfumers


def parse_voting_field(field_str: str) -> Dict[str, Dict[str, Any]]:
    """Parse any voting field (v3.0 format).

    v3.0 Format: category:votes:percent;category:votes:percent;...
    Example: love:12:13;like:48:53;ok:1:1;dislike:0:0;hate:0:0

    Returns dict with category as key and {votes, percent} as value.
    """
    if not field_str or pd.isna(field_str):
        return {}

    result = {}
    for item in field_str.split(";"):
        parts = item.split(":")
        if len(parts) >= 3:
            category = parts[0]
            result[category] = {
                "votes": int(parts[1]) if parts[1].isdigit() else 0,
                "percent": float(parts[2]) if parts[2] else 0.0
            }
        elif len(parts) == 2:
            # Fallback for older format (category:value)
            category = parts[0]
            try:
                value = float(parts[1])
                result[category] = {"votes": int(value), "percent": value}
            except ValueError:
                result[category] = {"votes": 0, "percent": 0.0}

    return result


def parse_reminds_of(reminds_str: str) -> List[Dict[str, int]]:
    """Parse the reminds_of field (v3.0 format).

    v3.0 Format: pid:likes:dislikes;pid:likes:dislikes;...
    Example: 12345:42:3;67890:28:1

    Returns list of {pid, likes, dislikes} dicts.
    """
    if not reminds_str or pd.isna(reminds_str):
        return []

    result = []
    for item in reminds_str.split(";"):
        parts = item.split(":")
        if len(parts) >= 3:
            result.append({
                "pid": int(parts[0]) if parts[0].isdigit() else 0,
                "likes": int(parts[1]) if parts[1].isdigit() else 0,
                "dislikes": int(parts[2]) if parts[2].isdigit() else 0
            })
        elif len(parts) == 1 and parts[0].isdigit():
            # Fallback for older format (just PIDs)
            result.append({"pid": int(parts[0]), "likes": 0, "dislikes": 0})

    return result


def parse_pros_cons(pros_cons_str: str) -> Dict[str, List[Dict[str, Any]]]:
    """Parse the pros_cons field (NEW in v3.0).

    Format: pros(text,likes,dislikes;text,likes,dislikes)cons(text,likes,dislikes;...)
    """
    if not pros_cons_str or pd.isna(pros_cons_str):
        return {"pros": [], "cons": []}

    result = {"pros": [], "cons": []}

    # Match pros(...) and cons(...) patterns
    pros_match = re.search(r'pros\(([^)]*)\)', pros_cons_str)
    cons_match = re.search(r'cons\(([^)]*)\)', pros_cons_str)

    for key, match in [("pros", pros_match), ("cons", cons_match)]:
        if match:
            content = match.group(1)
            for item in content.split(";"):
                parts = item.split(",")
                if len(parts) >= 3:
                    result[key].append({
                        "text": parts[0],
                        "likes": int(parts[1]) if parts[1].isdigit() else 0,
                        "dislikes": int(parts[2]) if parts[2].isdigit() else 0
                    })

    return result


def parse_id_list(ids_str: str) -> List[int]:
    """Parse semicolon-separated ID list.

    Format: id;id;id;...
    Used for: by_designer, in_collection, also_like, news_ids
    """
    if not ids_str or pd.isna(ids_str):
        return []

    return [int(x) for x in ids_str.split(";") if x.isdigit()]


def main():
    # Load database
    db = load_fragdb()
    fragrances = db["fragrances"]
    brands = db["brands"]
    perfumers = db["perfumers"]
    notes = db["notes"]
    accords = db["accords"]

    # Get first fragrance for examples
    row = fragrances.iloc[0]
    brand_info = parse_brand(row["brand"])
    print(f"Parsing fields for: {row['name']} by {brand_info['name']}")
    print(f"Brand ID: {brand_info['id']} (use to lookup in brands.csv)")
    print()

    # Parse accords (v3.0 format - uses accords.csv for lookup)
    print("=== Accords (v3.0 format) ===")
    accord_list = parse_accords(row.get("accords", ""), accords)
    for accord in accord_list[:5]:  # Show top 5
        name = accord.get("name", accord["id"])
        color = accord.get("bar_color", "")
        print(f"  {name}: {accord['percentage']}% {color}")
    print()

    # Parse notes pyramid (v3.0 format with opacity and weight)
    print("=== Notes Pyramid (v3.0 format) ===")
    notes_pyramid = parse_notes_pyramid(row.get("notes_pyramid", ""), notes)
    for layer, note_list in notes_pyramid.items():
        print(f"  {layer.upper()}:")
        for n in note_list[:3]:
            print(f"    - {n['name']} (opacity: {n['opacity']}, weight: {n['weight']})")
    print()

    # Parse perfumers
    print("=== Perfumers ===")
    perfumer_list = parse_perfumers(row.get("perfumers", ""))
    for p in perfumer_list:
        print(f"  {p['name']} (ID: {p['id']} - lookup in perfumers.csv)")
    print()

    # Parse rating
    print("=== Rating ===")
    rating = parse_rating(row.get("rating", ""))
    print(f"  Average: {rating['average']:.2f} ({rating['votes']:,} votes)")

    # Reviews count (NEW in v3.0)
    reviews = row.get("reviews_count", 0)
    print(f"  Reviews: {reviews}")
    print()

    # Parse voting fields (v3.0 format: category:votes:percent)
    print("=== Longevity (v3.0 format) ===")
    longevity = parse_voting_field(row.get("longevity", ""))
    for category, data in longevity.items():
        print(f"  {category}: {data['votes']} votes ({data['percent']:.0f}%)")
    print()

    print("=== Sillage (v3.0 format) ===")
    sillage = parse_voting_field(row.get("sillage", ""))
    for category, data in sillage.items():
        print(f"  {category}: {data['votes']} votes ({data['percent']:.0f}%)")
    print()

    print("=== Appreciation (v3.0 format) ===")
    appreciation = parse_voting_field(row.get("appreciation", ""))
    for category, data in appreciation.items():
        print(f"  {category}: {data['votes']} votes ({data['percent']:.0f}%)")
    print()

    # Parse reminds_of (v3.0 format: pid:likes:dislikes)
    print("=== Reminds Of (v3.0 format) ===")
    reminds = parse_reminds_of(row.get("reminds_of", ""))
    for r in reminds[:3]:
        print(f"  PID {r['pid']}: {r['likes']} likes, {r['dislikes']} dislikes")
    print()

    # Parse pros_cons (NEW in v3.0)
    print("=== Pros/Cons (NEW in v3.0) ===")
    pros_cons = parse_pros_cons(row.get("pros_cons", ""))
    print("  Pros:")
    for p in pros_cons["pros"][:2]:
        print(f"    + {p['text']} ({p['likes']} likes)")
    print("  Cons:")
    for c in pros_cons["cons"][:2]:
        print(f"    - {c['text']} ({c['likes']} likes)")
    print()

    # Example: Look up brand details from brands.csv
    print("=== Brand Details (from brands.csv) ===")
    brand_id = brand_info["id"]
    brand_row = brands[brands["id"] == brand_id]
    if not brand_row.empty:
        b = brand_row.iloc[0]
        print(f"  Name: {b['name']}")
        print(f"  Country: {b['country']}")
        print(f"  Website: {b['website']}")
        print(f"  Fragrances: {b['brand_count']}")


if __name__ == "__main__":
    main()
