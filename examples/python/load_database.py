#!/usr/bin/env python3
"""
FragDB - Load Database Example (v2.0)

Demonstrates how to load the FragDB multi-file database using pandas.
"""

import pandas as pd
from pathlib import Path


def load_fragrances(filepath: str = "../../samples/fragrances.csv") -> pd.DataFrame:
    """Load the fragrances database from a CSV file.

    Args:
        filepath: Path to the fragrances CSV file (pipe-delimited)

    Returns:
        DataFrame with fragrance data
    """
    df = pd.read_csv(
        filepath,
        delimiter="|",
        encoding="utf-8",
        dtype=str  # Load all as strings, convert as needed
    )

    # Convert numeric fields
    df["pid"] = pd.to_numeric(df["pid"], errors="coerce")
    df["year"] = pd.to_numeric(df["year"], errors="coerce")

    return df


def load_brands(filepath: str = "../../samples/brands.csv") -> pd.DataFrame:
    """Load the brands reference table.

    Args:
        filepath: Path to the brands CSV file (pipe-delimited)

    Returns:
        DataFrame with brand data
    """
    df = pd.read_csv(
        filepath,
        delimiter="|",
        encoding="utf-8",
        dtype=str
    )

    # Convert numeric fields
    df["brand_count"] = pd.to_numeric(df["brand_count"], errors="coerce")

    return df


def load_perfumers(filepath: str = "../../samples/perfumers.csv") -> pd.DataFrame:
    """Load the perfumers reference table.

    Args:
        filepath: Path to the perfumers CSV file (pipe-delimited)

    Returns:
        DataFrame with perfumer data
    """
    df = pd.read_csv(
        filepath,
        delimiter="|",
        encoding="utf-8",
        dtype=str
    )

    # Convert numeric fields
    df["perfumes_count"] = pd.to_numeric(df["perfumes_count"], errors="coerce")

    return df


def load_fragdb(samples_dir: str = "../../samples") -> dict:
    """Load all FragDB database files.

    Args:
        samples_dir: Directory containing the CSV files

    Returns:
        Dictionary with 'fragrances', 'brands', and 'perfumers' DataFrames
    """
    base = Path(samples_dir)
    return {
        "fragrances": load_fragrances(str(base / "fragrances.csv")),
        "brands": load_brands(str(base / "brands.csv")),
        "perfumers": load_perfumers(str(base / "perfumers.csv"))
    }


def join_with_brands(fragrances: pd.DataFrame, brands: pd.DataFrame) -> pd.DataFrame:
    """Join fragrances with brand details.

    Args:
        fragrances: Fragrances DataFrame
        brands: Brands DataFrame

    Returns:
        DataFrame with fragrances joined to brand details
    """
    # Extract brand_id from brand field (format: brand_name;brand_id)
    fragrances = fragrances.copy()
    fragrances["brand_id"] = fragrances["brand"].str.split(";").str[1]

    # Merge with brands
    return fragrances.merge(
        brands,
        left_on="brand_id",
        right_on="id",
        how="left",
        suffixes=("", "_brand")
    )


def main():
    # Load all database files
    db = load_fragdb()

    fragrances = db["fragrances"]
    brands = db["brands"]
    perfumers = db["perfumers"]

    # Display basic info
    print("=== FragDB v2.0 Database ===\n")
    print(f"Fragrances: {len(fragrances)} records, {len(fragrances.columns)} fields")
    print(f"Brands: {len(brands)} records, {len(brands.columns)} fields")
    print(f"Perfumers: {len(perfumers)} records, {len(perfumers.columns)} fields")
    print()

    # Show sample fragrances
    print("Sample fragrances:")
    print(fragrances[["name", "brand", "year", "gender"]].head())
    print()

    # Show sample brands
    print("Sample brands:")
    print(brands[["id", "name", "country", "brand_count"]].head())
    print()

    # Show sample perfumers
    print("Sample perfumers:")
    print(perfumers[["id", "name", "company", "perfumes_count"]].head())
    print()

    # Example: Join fragrances with brands
    print("=== Joined Data Example ===")
    joined = join_with_brands(fragrances, brands)
    print(joined[["name", "name_brand", "country", "website"]].head())


if __name__ == "__main__":
    main()
