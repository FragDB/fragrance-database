# FragDB - R Analysis Example
#
# Demonstrates how to load and analyze the FragDB fragrance database in R.
# For the full database with 119,000+ fragrances, visit https://fragdb.net

# Load required libraries
library(tidyverse)
library(stringr)

# =============================================================================
# DATA LOADING
# =============================================================================

#' Load the FragDB database from CSV file
#'
#' @param filepath Path to the CSV file
#' @return A tibble containing the fragrance data
load_fragdb <- function(filepath = "../../SAMPLE.csv") {
  read_delim(
    filepath,
    delim = "|",
    col_types = cols(.default = "c"),
    locale = locale(encoding = "UTF-8")
  )
}

# =============================================================================
# FIELD PARSING FUNCTIONS
# =============================================================================

#' Parse the brand field
#'
#' @param brand_str Raw brand string (format: name;url;logo)
#' @return A tibble with brand info
parse_brand <- function(brand_str) {
  if (is.na(brand_str) || brand_str == "") {
    return(tibble(name = "", url = "", logo = ""))
  }

  parts <- str_split(brand_str, ";", simplify = TRUE)
  tibble(
    name = ifelse(length(parts) >= 1, parts[1], ""),
    url = ifelse(length(parts) >= 2, parts[2], ""),
    logo = ifelse(length(parts) >= 3, parts[3], "")
  )
}

#' Parse the rating field
#'
#' @param rating_str Raw rating string (format: average;votes)
#' @return A tibble with rating info
parse_rating <- function(rating_str) {
  if (is.na(rating_str) || rating_str == "") {
    return(tibble(average = NA_real_, votes = 0L))
  }

  parts <- str_split(rating_str, ";", simplify = TRUE)
  tibble(
    average = as.numeric(parts[1]),
    votes = as.integer(parts[2])
  )
}

#' Parse the accords field
#'
#' @param accords_str Raw accords string (format: name:pct:bg:text;...)
#' @return A tibble with accord details
parse_accords <- function(accords_str) {
  if (is.na(accords_str) || accords_str == "") {
    return(tibble(name = character(), percentage = integer(),
                  bg_color = character(), text_color = character()))
  }

  accords <- str_split(accords_str, ";")[[1]]

  map_dfr(accords, function(accord) {
    parts <- str_split(accord, ":", simplify = TRUE)
    if (length(parts) >= 4) {
      tibble(
        name = parts[1],
        percentage = as.integer(parts[2]),
        bg_color = parts[3],
        text_color = parts[4]
      )
    } else {
      tibble(name = character(), percentage = integer(),
             bg_color = character(), text_color = character())
    }
  })
}

#' Parse percentage-based fields (longevity, sillage, etc.)
#'
#' @param field_str Raw field string (format: category:percentage;...)
#' @return A named vector of percentages
parse_percentage_field <- function(field_str) {
  if (is.na(field_str) || field_str == "") {
    return(tibble(category = character(), percentage = integer()))
  }

  items <- str_split(field_str, ";")[[1]]

  map_dfr(items, function(item) {
    parts <- str_split(item, ":", simplify = TRUE)
    if (length(parts) >= 2) {
      tibble(
        category = parts[1],
        percentage = as.integer(parts[2])
      )
    } else {
      tibble(category = character(), percentage = integer())
    }
  })
}

# =============================================================================
# ANALYSIS FUNCTIONS
# =============================================================================

#' Prepare dataframe with parsed fields
#'
#' @param df Raw fragrance dataframe
#' @return Dataframe with additional parsed columns
prepare_data <- function(df) {
  df %>%
    mutate(
      year = as.integer(year),
      brand_name = map_chr(brand, ~ parse_brand(.x)$name),
      rating_average = map_dbl(rating, ~ parse_rating(.x)$average),
      rating_votes = map_int(rating, ~ parse_rating(.x)$votes)
    )
}

#' Get top rated fragrances
#'
#' @param df Prepared dataframe
#' @param n Number of results
#' @param min_votes Minimum votes required
#' @return Top rated fragrances
get_top_rated <- function(df, n = 10, min_votes = 100) {
  df %>%
    filter(rating_votes >= min_votes) %>%
    arrange(desc(rating_average)) %>%
    head(n) %>%
    select(name, brand_name, year, rating_average, rating_votes)
}

#' Count fragrances by brand
#'
#' @param df Prepared dataframe
#' @return Brand counts
count_by_brand <- function(df) {
  df %>%
    filter(!is.na(brand_name) & brand_name != "") %>%
    count(brand_name, sort = TRUE)
}

#' Count fragrances by year
#'
#' @param df Prepared dataframe
#' @return Year counts
count_by_year <- function(df) {
  df %>%
    filter(!is.na(year)) %>%
    count(year, sort = TRUE)
}

#' Count fragrances by gender
#'
#' @param df Raw dataframe
#' @return Gender counts
count_by_gender <- function(df) {
  df %>%
    filter(!is.na(gender) & gender != "") %>%
    count(gender, sort = TRUE)
}

#' Get all accords with their frequencies
#'
#' @param df Raw dataframe
#' @return Accord frequencies
get_accord_frequencies <- function(df) {
  df %>%
    filter(!is.na(accords) & accords != "") %>%
    pull(accords) %>%
    map_dfr(parse_accords) %>%
    count(name, sort = TRUE)
}

#' Search fragrances by name
#'
#' @param df Dataframe
#' @param query Search query
#' @return Matching fragrances
search_by_name <- function(df, query) {
  df %>%
    filter(str_detect(tolower(name), tolower(query)))
}

# =============================================================================
# MAIN ANALYSIS
# =============================================================================

main <- function() {
  cat("=== FragDB R Analysis Example ===\n\n")

  # Load data
  cat("Loading database...\n")
  df <- load_fragdb()
  cat(sprintf("Loaded %d fragrances\n\n", nrow(df)))

  # Prepare data with parsed fields
  cat("Preparing data...\n")
  df_prepared <- prepare_data(df)

  # Basic statistics
  cat("\n=== Basic Statistics ===\n")
  cat(sprintf("Total fragrances: %d\n", nrow(df)))
  cat(sprintf("Unique brands: %d\n", n_distinct(df_prepared$brand_name)))
  cat(sprintf("Year range: %d - %d\n",
              min(df_prepared$year, na.rm = TRUE),
              max(df_prepared$year, na.rm = TRUE)))

  # Gender distribution
  cat("\n=== Gender Distribution ===\n")
  gender_counts <- count_by_gender(df)
  print(gender_counts, n = 10)

  # Top rated (if votes exist in sample)
  cat("\n=== Top Rated Fragrances ===\n")
  top_rated <- get_top_rated(df_prepared, n = 5, min_votes = 0)
  print(top_rated)

  # Accord analysis
  cat("\n=== Top Accords ===\n")
  accord_freq <- get_accord_frequencies(df)
  print(head(accord_freq, 10))

  # Sample fragrance details
  cat("\n=== Sample Fragrance Details ===\n")
  sample_row <- df[1, ]
  cat(sprintf("Name: %s\n", sample_row$name))
  cat(sprintf("Brand: %s\n", parse_brand(sample_row$brand)$name))
  cat(sprintf("Year: %s\n", sample_row$year))
  cat(sprintf("Gender: %s\n", sample_row$gender))

  cat("\nAccords:\n")
  accords <- parse_accords(sample_row$accords)
  print(head(accords, 5))
}

# Run analysis
if (sys.nframe() == 0) {
  main()
}
