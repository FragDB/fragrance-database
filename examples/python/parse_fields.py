#!/usr/bin/env python3
"""
FragDB - Parse Complex Fields Example

Demonstrates how to parse complex fields like accords and notes_pyramid.
"""

import re
from typing import List, Dict, Any
import pandas as pd
from load_database import load_fragdb


def parse_accords(accords_str: str) -> List[Dict[str, Any]]:
    """Parse the accords field into a list of dictionaries.

    Format: name:percentage:bg_color:text_color;...
    """
    if not accords_str or pd.isna(accords_str):
        return []

    accords = []
    for accord in accords_str.split(";"):
        parts = accord.split(":")
        if len(parts) >= 4:
            accords.append({
                "name": parts[0],
                "percentage": int(parts[1]) if parts[1].isdigit() else 0,
                "bg_color": parts[2],
                "text_color": parts[3]
            })
    return accords


def parse_notes_pyramid(notes_str: str) -> Dict[str, List[Dict[str, str]]]:
    """Parse the notes_pyramid field into a structured dictionary.

    Format: layer(note,url,img;note,url,img);layer(...)
    Layers: top, mid, base, or notes (flat)
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
            if len(parts) >= 3:
                notes.append({
                    "name": parts[0],
                    "url": parts[1],
                    "image": parts[2]
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
    """Parse the brand field into name, url, and logo.

    Format: name;url;logo_url
    """
    if not brand_str or pd.isna(brand_str):
        return {"name": "", "url": "", "logo": ""}

    parts = brand_str.split(";")
    return {
        "name": parts[0] if len(parts) > 0 else "",
        "url": parts[1] if len(parts) > 1 else "",
        "logo": parts[2] if len(parts) > 2 else ""
    }


def parse_percentage_field(field_str: str) -> Dict[str, int]:
    """Parse any percentage-based field.

    Format: category:percentage;category:percentage;...
    """
    if not field_str or pd.isna(field_str):
        return {}

    result = {}
    for item in field_str.split(";"):
        parts = item.split(":")
        if len(parts) >= 2:
            result[parts[0]] = int(parts[1]) if parts[1].isdigit() else 0
    return result


def parse_id_list(ids_str: str) -> List[int]:
    """Parse semicolon-separated ID list.

    Format: id;id;id;...
    """
    if not ids_str or pd.isna(ids_str):
        return []

    return [int(x) for x in ids_str.split(";") if x.isdigit()]


def main():
    # Load database
    df = load_fragdb()

    # Get first fragrance for examples
    row = df.iloc[0]
    print(f"Parsing fields for: {row['name']} by {parse_brand(row['brand'])['name']}")
    print()

    # Parse accords
    print("=== Accords ===")
    accords = parse_accords(row["accords"])
    for accord in accords[:5]:  # Show top 5
        print(f"  {accord['name']}: {accord['percentage']}%")
    print()

    # Parse notes pyramid
    print("=== Notes Pyramid ===")
    notes = parse_notes_pyramid(row["notes_pyramid"])
    for layer, note_list in notes.items():
        print(f"  {layer.upper()}: {', '.join(n['name'] for n in note_list[:3])}")
    print()

    # Parse rating
    print("=== Rating ===")
    rating = parse_rating(row["rating"])
    print(f"  Average: {rating['average']:.2f} ({rating['votes']:,} votes)")
    print()

    # Parse longevity
    print("=== Longevity ===")
    longevity = parse_percentage_field(row["longevity"])
    for category, percentage in longevity.items():
        print(f"  {category}: {percentage}%")


if __name__ == "__main__":
    main()
