# FragDB - R Analysis Example (v4.3)
#
# Demonstrates how to load and analyze the FragDB fragrance database in R.
# Now includes 5 CSV files: fragrances, brands, perfumers, notes, accords.
# For the full database with 123,000+ fragrances, visit https://fragdb.net

# Load required libraries
library(tidyverse)
library(stringr)

# =============================================================================
# DATA LOADING
# =============================================================================

#' Load all FragDB database files
#'
#' @param samples_dir Path to the samples directory
#' @return A list containing all five dataframes
load_fragdb <- function(samples_dir = "../../samples") {
  list(
    fragrances = read_delim(
      file.path(samples_dir, "fragrances.csv"),
      delim = "|",
      col_types = cols(.default = "c"),
      locale = locale(encoding = "UTF-8")
    ),
    brands = read_delim(
      file.path(samples_dir, "brands.csv"),
      delim = "|",
      col_types = cols(.default = "c"),
      locale = locale(encoding = "UTF-8")
    ),
    perfumers = read_delim(
      file.path(samples_dir, "perfumers.csv"),
      delim = "|",
      col_types = cols(.default = "c"),
      locale = locale(encoding = "UTF-8")
    ),
    notes = read_delim(
      file.path(samples_dir, "notes.csv"),
      delim = "|",
      col_types = cols(.default = "c"),
      locale = locale(encoding = "UTF-8")
    ),
    accords = read_delim(
      file.path(samples_dir, "accords.csv"),
      delim = "|",
      col_types = cols(.default = "c"),
      locale = locale(encoding = "UTF-8")
    )
  )
}

# =============================================================================
# FIELD PARSING FUNCTIONS
# =============================================================================

#' Parse the brand field
#'
#' @param brand_str Raw brand string (format: name;brand_id)
#' @return A tibble with brand info
parse_brand <- function(brand_str) {
  if (is.na(brand_str) || brand_str == "") {
    return(tibble(name = "", id = ""))
  }

  parts <- str_split(brand_str, ";", simplify = TRUE)
  tibble(
    name = ifelse(length(parts) >= 1, parts[1], ""),
    id = ifelse(length(parts) >= 2, parts[2], "")
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

#' Parse the accords field (v3.0 format)
#'
#' @param accords_str Raw accords string (format: accord_id:pct;...)
#' @param accords_df Optional accords dataframe for lookup
#' @return A tibble with accord details
parse_accords <- function(accords_str, accords_df = NULL) {
  if (is.na(accords_str) || accords_str == "") {
    return(tibble(id = character(), percentage = integer(),
                  name = character(), bar_color = character()))
  }

  accords <- str_split(accords_str, ";")[[1]]

  result <- map_dfr(accords, function(accord) {
    parts <- str_split(accord, ":", simplify = TRUE)
    if (length(parts) >= 2) {
      accord_id <- parts[1]
      pct <- as.integer(parts[2])

      row <- tibble(id = accord_id, percentage = pct)

      # Look up name and color from accords.csv if provided
      if (!is.null(accords_df)) {
        match <- accords_df %>% filter(id == accord_id)
        if (nrow(match) > 0) {
          row$name <- match$name[1]
          row$bar_color <- match$bar_color[1]
        }
      }

      row
    } else {
      tibble(id = character(), percentage = integer())
    }
  })

  result
}

#' Parse voting fields (v3.0 format: category:votes:percent)
#'
#' @param field_str Raw field string
#' @return A tibble with category, votes, and percent
parse_voting_field <- function(field_str) {
  if (is.na(field_str) || field_str == "") {
    return(tibble(category = character(), votes = integer(), percent = numeric()))
  }

  items <- str_split(field_str, ";")[[1]]

  map_dfr(items, function(item) {
    parts <- str_split(item, ":", simplify = TRUE)
    if (length(parts) >= 3) {
      tibble(
        category = parts[1],
        votes = as.integer(parts[2]),
        percent = as.numeric(parts[3])
      )
    } else {
      tibble(category = character(), votes = integer(), percent = numeric())
    }
  })
}

#' Parse reminds_of field (v3.0 format: pid:likes:dislikes)
#'
#' @param reminds_str Raw reminds_of string
#' @return A tibble with pid, likes, dislikes
parse_reminds_of <- function(reminds_str) {
  if (is.na(reminds_str) || reminds_str == "") {
    return(tibble(pid = integer(), likes = integer(), dislikes = integer()))
  }

  items <- str_split(reminds_str, ";")[[1]]

  map_dfr(items, function(item) {
    parts <- str_split(item, ":", simplify = TRUE)
    if (length(parts) >= 3) {
      tibble(
        pid = as.integer(parts[1]),
        likes = as.integer(parts[2]),
        dislikes = as.integer(parts[3])
      )
    } else {
      tibble(pid = integer(), likes = integer(), dislikes = integer())
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
      reviews_count = as.integer(reviews_count),
      brand_name = map_chr(brand, ~ parse_brand(.x)$name),
      brand_id = map_chr(brand, ~ parse_brand(.x)$id),
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
    select(name, brand_name, year, rating_average, rating_votes, reviews_count)
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
#' @param accords_df Accords reference dataframe
#' @return Accord frequencies
get_accord_frequencies <- function(df, accords_df = NULL) {
  df %>%
    filter(!is.na(accords) & accords != "") %>%
    pull(accords) %>%
    map_dfr(~ parse_accords(.x, accords_df)) %>%
    group_by(id, name) %>%
    summarise(count = n(), .groups = "drop") %>%
    arrange(desc(count))
}

#' Count notes by group
#'
#' @param notes_df Notes dataframe
#' @return Group counts
count_notes_by_group <- function(notes_df) {
  notes_df %>%
    filter(!is.na(group) & group != "") %>%
    count(group, sort = TRUE)
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
  cat("=== FragDB v4.3 R Analysis Example ===\n\n")

  # Load data
  cat("Loading database (5 files)...\n")
  db <- load_fragdb()
  fragrances <- db$fragrances
  brands <- db$brands
  perfumers <- db$perfumers
  notes <- db$notes
  accords <- db$accords

  cat(sprintf("Loaded %d fragrances\n", nrow(fragrances)))
  cat(sprintf("Loaded %d brands\n", nrow(brands)))
  cat(sprintf("Loaded %d perfumers\n", nrow(perfumers)))
  cat(sprintf("Loaded %d notes\n", nrow(notes)))
  cat(sprintf("Loaded %d accords\n\n", nrow(accords)))

  # Prepare data with parsed fields
  cat("Preparing data...\n")
  df_prepared <- prepare_data(fragrances)

  # Basic statistics
  cat("\n=== Basic Statistics ===\n")
  cat(sprintf("Total fragrances: %d\n", nrow(fragrances)))
  cat(sprintf("Unique brands: %d\n", n_distinct(df_prepared$brand_name)))
  cat(sprintf("Year range: %d - %d\n",
              min(df_prepared$year, na.rm = TRUE),
              max(df_prepared$year, na.rm = TRUE)))

  # Gender distribution
  cat("\n=== Gender Distribution ===\n")
  gender_counts <- count_by_gender(fragrances)
  print(gender_counts, n = 10)

  # Top rated (if votes exist in sample)
  cat("\n=== Top Rated Fragrances ===\n")
  top_rated <- get_top_rated(df_prepared, n = 5, min_votes = 0)
  print(top_rated)

  # Accord analysis (v3.0 - with lookup)
  cat("\n=== Top Accords (v3.0) ===\n")
  accord_freq <- get_accord_frequencies(fragrances, accords)
  print(head(accord_freq, 10))

  # Notes by group (NEW in v3.0)
  cat("\n=== Notes by Group (NEW in v3.0) ===\n")
  notes_by_group <- count_notes_by_group(notes)
  print(head(notes_by_group, 10))

  # Sample fragrance details
  cat("\n=== Sample Fragrance Details ===\n")
  sample_row <- fragrances[1, ]
  cat(sprintf("Name: %s\n", sample_row$name))
  cat(sprintf("Brand: %s\n", parse_brand(sample_row$brand)$name))
  cat(sprintf("Year: %s\n", sample_row$year))
  cat(sprintf("Gender: %s\n", sample_row$gender))
  cat(sprintf("Reviews: %s\n", sample_row$reviews_count))

  # Parse voting fields (v3.0 format)
  cat("\n=== Longevity Votes (v3.0) ===\n")
  longevity <- parse_voting_field(sample_row$longevity)
  print(longevity)

  cat("\nAccords (with lookup):\n")
  sample_accords <- parse_accords(sample_row$accords, accords)
  print(head(sample_accords, 5))
}

# Run analysis
if (sys.nframe() == 0) {
  main()
}
