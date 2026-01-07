#!/usr/bin/env python3
"""
FragDB - Load Database Example

Demonstrates how to load the FragDB fragrance database using pandas.
"""

import pandas as pd


def load_fragdb(filepath: str = "../../SAMPLE.csv") -> pd.DataFrame:
    """Load the FragDB database from a CSV file.

    Args:
        filepath: Path to the CSV file (pipe-delimited)

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


def main():
    # Load the database
    df = load_fragdb()

    # Display basic info
    print(f"Loaded {len(df)} fragrances")
    print(f"Columns ({len(df.columns)}): {', '.join(df.columns)}")
    print()

    # Show sample
    print("Sample fragrances:")
    print(df[["name", "brand", "year", "gender"]].head())
    print()

    # Basic statistics
    print("Year range:", df["year"].min(), "-", df["year"].max())
    print("Unique brands:", df["brand"].nunique())
    print("Gender distribution:")
    print(df["gender"].value_counts())


if __name__ == "__main__":
    main()
