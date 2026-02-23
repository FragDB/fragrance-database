#!/usr/bin/env python3
"""
FragDB - Simple Recommender Example (v3.0)

Demonstrates how to build a basic fragrance recommendation system.
"""

import pandas as pd
from typing import List, Dict
from load_database import load_fragdb
from parse_fields import parse_accords, parse_percentage_field, parse_brand


def get_fragrance_profile(row: pd.Series) -> Dict[str, float]:
    """Extract a numeric profile from a fragrance for similarity comparison."""
    profile = {}

    # Add accords
    accords = parse_accords(row["accords"])
    for accord in accords:
        profile[f"accord_{accord['name']}"] = accord["percentage"] / 100.0

    # Add characteristics
    longevity = parse_percentage_field(row.get("longevity", ""))
    for cat, pct in longevity.items():
        profile[f"longevity_{cat}"] = pct / 100.0

    sillage = parse_percentage_field(row.get("sillage", ""))
    for cat, pct in sillage.items():
        profile[f"sillage_{cat}"] = pct / 100.0

    return profile


def cosine_similarity(profile1: Dict[str, float], profile2: Dict[str, float]) -> float:
    """Calculate cosine similarity between two fragrance profiles."""
    # Get all keys
    all_keys = set(profile1.keys()) | set(profile2.keys())

    # Calculate dot product and magnitudes
    dot_product = 0.0
    mag1 = 0.0
    mag2 = 0.0

    for key in all_keys:
        v1 = profile1.get(key, 0.0)
        v2 = profile2.get(key, 0.0)
        dot_product += v1 * v2
        mag1 += v1 * v1
        mag2 += v2 * v2

    # Avoid division by zero
    if mag1 == 0 or mag2 == 0:
        return 0.0

    return dot_product / (mag1 ** 0.5 * mag2 ** 0.5)


def find_similar(df: pd.DataFrame, target_name: str, n: int = 5) -> List[Dict]:
    """Find N most similar fragrances to the target."""
    # Find target fragrance
    target_mask = df["name"].str.lower() == target_name.lower()
    if not target_mask.any():
        print(f"Fragrance '{target_name}' not found")
        return []

    target_row = df[target_mask].iloc[0]
    target_profile = get_fragrance_profile(target_row)

    # Calculate similarity to all other fragrances
    similarities = []
    for idx, row in df.iterrows():
        if row["name"].lower() == target_name.lower():
            continue

        profile = get_fragrance_profile(row)
        sim = cosine_similarity(target_profile, profile)

        # Extract brand name from brand field (v2.0 format: name;id)
        brand_info = parse_brand(row["brand"])

        similarities.append({
            "name": row["name"],
            "brand": brand_info["name"],
            "brand_id": brand_info["id"],
            "similarity": sim
        })

    # Sort by similarity and return top N
    similarities.sort(key=lambda x: x["similarity"], reverse=True)
    return similarities[:n]


def recommend_by_accords(df: pd.DataFrame, preferred_accords: List[str], n: int = 5) -> List[Dict]:
    """Recommend fragrances based on preferred accords."""
    scores = []

    for idx, row in df.iterrows():
        accords = parse_accords(row["accords"])
        accord_names = {a["name"].lower() for a in accords}

        # Count matching accords
        matches = sum(1 for pref in preferred_accords if pref.lower() in accord_names)

        if matches > 0:
            # Weight by accord percentages
            score = 0
            for accord in accords:
                if accord["name"].lower() in [p.lower() for p in preferred_accords]:
                    score += accord["percentage"]

            # Extract brand name (v2.0 format: name;id)
            brand_info = parse_brand(row["brand"])

            scores.append({
                "name": row["name"],
                "brand": brand_info["name"],
                "brand_id": brand_info["id"],
                "matches": matches,
                "score": score
            })

    # Sort by score
    scores.sort(key=lambda x: x["score"], reverse=True)
    return scores[:n]


def recommend_by_perfumer(
    fragrances: pd.DataFrame,
    perfumers: pd.DataFrame,
    perfumer_name: str,
    n: int = 5
) -> List[Dict]:
    """Recommend fragrances by a specific perfumer.

    Uses perfumers.csv to find fragrances created by a perfumer.
    """
    # Find perfumer ID
    perfumer_mask = perfumers["name"].str.lower().str.contains(perfumer_name.lower(), na=False)
    if not perfumer_mask.any():
        print(f"Perfumer '{perfumer_name}' not found")
        return []

    perfumer_row = perfumers[perfumer_mask].iloc[0]
    perfumer_id = perfumer_row["id"]

    # Find fragrances by this perfumer
    results = []
    for idx, row in fragrances.iterrows():
        perfumers_field = row.get("perfumers", "")
        if perfumers_field and f";{perfumer_id}" in perfumers_field:
            brand_info = parse_brand(row["brand"])
            results.append({
                "name": row["name"],
                "brand": brand_info["name"],
                "year": row["year"]
            })

    return results[:n]


def main():
    # Load database
    db = load_fragdb()
    fragrances = db["fragrances"]
    perfumers = db["perfumers"]

    print("=== FragDB v4.3 Recommender ===\n")

    # Find similar to a fragrance
    print("Fragrances similar to 'Light Blue':")
    similar = find_similar(fragrances, "Light Blue", n=3)
    for item in similar:
        print(f"  {item['name']} by {item['brand']} (similarity: {item['similarity']:.2f})")
    print()

    # Recommend by preferred accords
    print("Fragrances with fruity and sweet accords:")
    recommendations = recommend_by_accords(fragrances, ["fruity", "sweet"], n=5)
    for item in recommendations:
        print(f"  {item['name']} by {item['brand']} (score: {item['score']})")
    print()

    # Recommend by perfumer (v2.0 feature)
    print("Fragrances by Alberto Morillas:")
    by_perfumer = recommend_by_perfumer(fragrances, perfumers, "Alberto Morillas", n=5)
    for item in by_perfumer:
        print(f"  {item['name']} by {item['brand']} ({item['year']})")


if __name__ == "__main__":
    main()
