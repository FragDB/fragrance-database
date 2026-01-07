#!/usr/bin/env python3
"""
FragDB - Search Fragrances Example

Demonstrates how to search and filter fragrances in the database.
"""

import pandas as pd
from load_database import load_fragdb


def search_by_name(df: pd.DataFrame, query: str) -> pd.DataFrame:
    """Search fragrances by name (case-insensitive)."""
    mask = df["name"].str.lower().str.contains(query.lower(), na=False)
    return df[mask]


def search_by_brand(df: pd.DataFrame, brand: str) -> pd.DataFrame:
    """Search fragrances by brand name."""
    # Brand field format: name;url;logo
    mask = df["brand"].str.lower().str.startswith(brand.lower(), na=False)
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


def main():
    # Load database
    df = load_fragdb()

    # Search examples
    print("=== Search Examples ===\n")

    # Search by name
    print("Fragrances with 'Poison' in name:")
    results = search_by_name(df, "poison")
    print(results[["name", "brand", "year"]].to_string(index=False))
    print()

    # Search by brand
    print("Dior fragrances:")
    results = search_by_brand(df, "Dior")
    print(results[["name", "year", "gender"]].to_string(index=False))
    print()

    # Filter by gender
    print("Unisex fragrances:")
    results = filter_by_gender(df, "for women and men")
    print(results[["name", "brand", "year"]].to_string(index=False))
    print()

    # Filter by year range
    print("Fragrances from 2010-2015:")
    results = filter_by_year_range(df, 2010, 2015)
    print(results[["name", "brand", "year"]].to_string(index=False))
    print()

    # Top rated
    print("Top 5 rated fragrances:")
    results = get_top_rated(df, 5)
    print(results[["name", "brand", "rating_value"]].to_string(index=False))


if __name__ == "__main__":
    main()
