#!/usr/bin/env python3
"""
FragDB - Load Database Example (v3.0)

Demonstrates how to load the FragDB multi-file database using pandas.
Now includes 5 CSV files: fragrances, brands, perfumers, notes, accords.
"""

import pandas as pd
from pathlib import Path


def load_fragrances(filepath: str = "../../samples/fragrances.csv") -> pd.DataFrame:
    """Load the fragrances database from a CSV file.

    Args:
        filepath: Path to the fragrances CSV file (pipe-delimited)

    Returns:
        DataFrame with fragrance data (30 fields)
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
    df["reviews_count"] = pd.to_numeric(df["reviews_count"], errors="coerce")

    return df


def load_brands(filepath: str = "../../samples/brands.csv") -> pd.DataFrame:
    """Load the brands reference table.

    Args:
        filepath: Path to the brands CSV file (pipe-delimited)

    Returns:
        DataFrame with brand data (10 fields)
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
        DataFrame with perfumer data (11 fields)
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


def load_notes(filepath: str = "../../samples/notes.csv") -> pd.DataFrame:
    """Load the notes reference table (NEW in v3.0).

    Args:
        filepath: Path to the notes CSV file (pipe-delimited)

    Returns:
        DataFrame with note data (11 fields)
    """
    df = pd.read_csv(
        filepath,
        delimiter="|",
        encoding="utf-8",
        dtype=str
    )

    # Convert numeric fields
    df["fragrance_count"] = pd.to_numeric(df["fragrance_count"], errors="coerce")

    return df


def load_accords(filepath: str = "../../samples/accords.csv") -> pd.DataFrame:
    """Load the accords reference table (NEW in v3.0).

    Args:
        filepath: Path to the accords CSV file (pipe-delimited)

    Returns:
        DataFrame with accord data (5 fields)
    """
    df = pd.read_csv(
        filepath,
        delimiter="|",
        encoding="utf-8",
        dtype=str
    )

    # Convert numeric fields
    df["fragrance_count"] = pd.to_numeric(df["fragrance_count"], errors="coerce")

    return df


def load_fragdb(samples_dir: str = "../../samples") -> dict:
    """Load all FragDB database files.

    Args:
        samples_dir: Directory containing the CSV files

    Returns:
        Dictionary with 'fragrances', 'brands', 'perfumers', 'notes', 'accords' DataFrames
    """
    base = Path(samples_dir)
    return {
        "fragrances": load_fragrances(str(base / "fragrances.csv")),
        "brands": load_brands(str(base / "brands.csv")),
        "perfumers": load_perfumers(str(base / "perfumers.csv")),
        "notes": load_notes(str(base / "notes.csv")),
        "accords": load_accords(str(base / "accords.csv"))
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
    notes = db["notes"]
    accords = db["accords"]

    # Display basic info
    print("=== FragDB v4.3 Database ===\n")
    print(f"Fragrances: {len(fragrances)} records, {len(fragrances.columns)} fields")
    print(f"Brands: {len(brands)} records, {len(brands.columns)} fields")
    print(f"Perfumers: {len(perfumers)} records, {len(perfumers.columns)} fields")
    print(f"Notes: {len(notes)} records, {len(notes.columns)} fields")
    print(f"Accords: {len(accords)} records, {len(accords.columns)} fields")
    print()

    # Show sample fragrances
    print("Sample fragrances:")
    print(fragrances[["name", "brand", "year", "gender", "reviews_count"]].head())
    print()

    # Show sample brands
    print("Sample brands:")
    print(brands[["id", "name", "country", "brand_count"]].head())
    print()

    # Show sample perfumers
    print("Sample perfumers:")
    print(perfumers[["id", "name", "company", "perfumes_count"]].head())
    print()

    # Show sample notes (NEW in v3.0)
    print("Sample notes:")
    print(notes[["id", "name", "group", "fragrance_count"]].head())
    print()

    # Show sample accords (NEW in v3.0)
    print("Sample accords:")
    print(accords[["id", "name", "bar_color", "fragrance_count"]].head())
    print()

    # Example: Join fragrances with brands
    print("=== Joined Data Example ===")
    joined = join_with_brands(fragrances, brands)
    print(joined[["name", "name_brand", "country", "website"]].head())


if __name__ == "__main__":
    main()
