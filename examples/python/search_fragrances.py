#!/usr/bin/env python3
"""
FragDB - Search Fragrances Example (v3.0)

Demonstrates how to search and filter fragrances in the database.
"""

import pandas as pd
from load_database import load_fragdb, join_with_brands


def search_by_name(df: pd.DataFrame, query: str) -> pd.DataFrame:
    """Search fragrances by name (case-insensitive)."""
    mask = df["name"].str.lower().str.contains(query.lower(), na=False)
    return df[mask]


def search_by_brand(df: pd.DataFrame, brand: str) -> pd.DataFrame:
    """Search fragrances by brand name.

    Brand field format (v2.0): brand_name;brand_id
    """
    mask = df["brand"].str.lower().str.startswith(brand.lower(), na=False)
    return df[mask]


def search_by_brand_id(df: pd.DataFrame, brand_id: str) -> pd.DataFrame:
    """Search fragrances by brand ID.

    Use this when you have the brand_id (e.g., 'b3' for Dior).
    """
    mask = df["brand"].str.endswith(f";{brand_id}", na=False)
    return df[mask]


def filter_by_gender(df: pd.DataFrame, gender: str) -> pd.DataFrame:
    """Filter fragrances by target gender."""
    return df[df["gender"] == gender]


def filter_by_year_range(df: pd.DataFrame, start: int, end: int) -> pd.DataFrame:
    """Filter fragrances by release year range."""
    return df[(df["year"] >= start) & (df["year"] <= end)]


def filter_by_rating(df: pd.DataFrame, min_rating: float) -> pd.DataFrame:
    """Filter fragrances by minimum rating."""
    # Rating format: average;vote_count
    df = df.copy()
    df["rating_value"] = df["rating"].str.split(";").str[0].astype(float)
    return df[df["rating_value"] >= min_rating]


def get_top_rated(df: pd.DataFrame, n: int = 10) -> pd.DataFrame:
    """Get top N rated fragrances."""
    df = df.copy()
    df["rating_value"] = df["rating"].str.split(";").str[0].astype(float)
    return df.nlargest(n, "rating_value")


def get_brand_name(brand_field: str) -> str:
    """Extract brand name from brand field.

    Brand field format (v2.0): brand_name;brand_id
    """
    if not brand_field or pd.isna(brand_field):
        return ""
    return brand_field.split(";")[0]


def main():
    # Load database
    db = load_fragdb()
    df = db["fragrances"]
    brands = db["brands"]

    # Search examples
    print("=== Search Examples (FragDB v3.0) ===\n")

    # Search by name
    print("Fragrances with 'Poison' in name:")
    results = search_by_name(df, "poison")
    for _, row in results.iterrows():
        print(f"  {row['name']} by {get_brand_name(row['brand'])} ({row['year']})")
    print()

    # Search by brand name
    print("Dior fragrances:")
    results = search_by_brand(df, "Dior")
    for _, row in results.iterrows():
        print(f"  {row['name']} ({row['year']}) - {row['gender']}")
    print()

    # Filter by gender
    print("Unisex fragrances:")
    results = filter_by_gender(df, "for women and men")
    for _, row in results.iterrows():
        print(f"  {row['name']} by {get_brand_name(row['brand'])} ({row['year']})")
    print()

    # Filter by year range
    print("Fragrances from 2010-2015:")
    results = filter_by_year_range(df, 2010, 2015)
    for _, row in results.iterrows():
        print(f"  {row['name']} by {get_brand_name(row['brand'])} ({row['year']})")
    print()

    # Top rated
    print("Top 5 rated fragrances:")
    results = get_top_rated(df, 5)
    for _, row in results.iterrows():
        print(f"  {row['name']} by {get_brand_name(row['brand'])} ({row['rating_value']:.2f})")
    print()

    # Advanced: Search with brand details
    print("=== Advanced Search with Brand Details ===\n")
    joined = join_with_brands(df, brands)
    print("French brand fragrances:")
    french_fragrances = joined[joined["country"] == "France"]
    for _, row in french_fragrances.head(5).iterrows():
        print(f"  {row['name']} by {row['name_brand']}")


if __name__ == "__main__":
    main()
