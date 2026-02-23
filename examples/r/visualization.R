# FragDB - R Visualization Example
#
# Demonstrates how to create visualizations from the FragDB fragrance database.
# For the full database with 123,000+ fragrances, visit https://fragdb.net

# Load required libraries
library(tidyverse)
library(scales)
library(stringr)

# Source the analysis functions
source("analysis.R")

# =============================================================================
# VISUALIZATION FUNCTIONS
# =============================================================================

#' Plot rating distribution
#'
#' @param df Prepared dataframe
#' @return ggplot object
plot_rating_distribution <- function(df) {
  df %>%
    filter(!is.na(rating_average)) %>%
    ggplot(aes(x = rating_average)) +
    geom_histogram(binwidth = 0.1, fill = "#3498db", color = "white", alpha = 0.8) +
    labs(
      title = "Distribution of Fragrance Ratings",
      x = "Average Rating",
      y = "Count"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Plot fragrances by year
#'
#' @param df Prepared dataframe
#' @return ggplot object
plot_by_year <- function(df) {
  df %>%
    filter(!is.na(year) & year >= 1900 & year <= 2025) %>%
    count(year) %>%
    ggplot(aes(x = year, y = n)) +
    geom_line(color = "#2ecc71", linewidth = 1) +
    geom_point(color = "#27ae60", size = 2) +
    labs(
      title = "Fragrance Releases by Year",
      x = "Year",
      y = "Number of Fragrances"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Plot gender distribution
#'
#' @param df Dataframe
#' @return ggplot object
plot_gender_distribution <- function(df) {
  df %>%
    filter(!is.na(gender) & gender != "") %>%
    count(gender) %>%
    mutate(gender = fct_reorder(gender, n)) %>%
    ggplot(aes(x = gender, y = n, fill = gender)) +
    geom_col(show.legend = FALSE) +
    coord_flip() +
    scale_fill_brewer(palette = "Set2") +
    labs(
      title = "Fragrances by Target Gender",
      x = "",
      y = "Count"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Plot top brands
#'
#' @param df Prepared dataframe
#' @param n Number of brands to show
#' @return ggplot object
plot_top_brands <- function(df, n = 10) {
  df %>%
    filter(!is.na(brand_name) & brand_name != "") %>%
    count(brand_name, sort = TRUE) %>%
    head(n) %>%
    mutate(brand_name = fct_reorder(brand_name, n)) %>%
    ggplot(aes(x = brand_name, y = n, fill = n)) +
    geom_col(show.legend = FALSE) +
    coord_flip() +
    scale_fill_gradient(low = "#3498db", high = "#e74c3c") +
    labs(
      title = sprintf("Top %d Brands by Number of Fragrances", n),
      x = "",
      y = "Number of Fragrances"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Plot top accords
#'
#' @param df Dataframe
#' @param n Number of accords to show
#' @return ggplot object
plot_top_accords <- function(df, n = 15) {
  df %>%
    filter(!is.na(accords) & accords != "") %>%
    pull(accords) %>%
    map_dfr(parse_accords) %>%
    count(name, sort = TRUE) %>%
    head(n) %>%
    mutate(name = fct_reorder(name, n)) %>%
    ggplot(aes(x = name, y = n, fill = n)) +
    geom_col(show.legend = FALSE) +
    coord_flip() +
    scale_fill_gradient(low = "#9b59b6", high = "#e74c3c") +
    labs(
      title = sprintf("Top %d Most Common Accords", n),
      x = "",
      y = "Occurrences"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Plot rating vs votes scatter
#'
#' @param df Prepared dataframe
#' @return ggplot object
plot_rating_vs_votes <- function(df) {
  df %>%
    filter(!is.na(rating_average) & !is.na(rating_votes) & rating_votes > 0) %>%
    ggplot(aes(x = rating_votes, y = rating_average)) +
    geom_point(alpha = 0.5, color = "#3498db") +
    scale_x_log10(labels = comma) +
    labs(
      title = "Rating vs Number of Votes",
      x = "Number of Votes (log scale)",
      y = "Average Rating"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Plot accord composition for a fragrance
#'
#' @param accords_df Parsed accords tibble
#' @param fragrance_name Name for the title
#' @return ggplot object
plot_accord_composition <- function(accords_df, fragrance_name = "Fragrance") {
  accords_df %>%
    filter(!is.na(percentage)) %>%
    mutate(name = fct_reorder(name, percentage)) %>%
    ggplot(aes(x = name, y = percentage, fill = bg_color)) +
    geom_col() +
    scale_fill_identity() +
    coord_flip() +
    labs(
      title = sprintf("Accord Composition: %s", fragrance_name),
      x = "",
      y = "Percentage"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      panel.grid.minor = element_blank()
    )
}

#' Create a combined dashboard
#'
#' @param df Prepared dataframe
#' @return Combined plot
create_dashboard <- function(df) {
  # Requires gridExtra or patchwork
  if (!require(patchwork, quietly = TRUE)) {
    cat("Install 'patchwork' package for dashboard: install.packages('patchwork')\n")
    return(NULL)
  }

  p1 <- plot_gender_distribution(df)
  p2 <- plot_top_brands(df, 8)
  p3 <- plot_top_accords(df, 10)
  p4 <- plot_by_year(df)

  (p1 | p2) / (p3 | p4) +
    plot_annotation(
      title = "FragDB Fragrance Database Overview",
      theme = theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5))
    )
}

# =============================================================================
# MAIN VISUALIZATION
# =============================================================================

main <- function() {
  cat("=== FragDB R Visualization Example ===\n\n")

  # Load and prepare data
  cat("Loading database...\n")
  df <- load_fragdb()
  df_prepared <- prepare_data(df)
  cat(sprintf("Loaded %d fragrances\n\n", nrow(df)))

  # Create output directory
  output_dir <- "output"
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }

  # Generate visualizations
  cat("Generating visualizations...\n")

  # 1. Gender distribution
  p <- plot_gender_distribution(df)
  ggsave(file.path(output_dir, "gender_distribution.png"), p, width = 8, height = 6, dpi = 150)
  cat("  - Saved gender_distribution.png\n")

  # 2. Top brands
  p <- plot_top_brands(df_prepared, 10)
  ggsave(file.path(output_dir, "top_brands.png"), p, width = 8, height = 6, dpi = 150)
  cat("  - Saved top_brands.png\n")

  # 3. Top accords
  p <- plot_top_accords(df, 15)
  ggsave(file.path(output_dir, "top_accords.png"), p, width = 8, height = 6, dpi = 150)
  cat("  - Saved top_accords.png\n")

  # 4. Releases by year
  p <- plot_by_year(df_prepared)
  ggsave(file.path(output_dir, "releases_by_year.png"), p, width = 10, height = 6, dpi = 150)
  cat("  - Saved releases_by_year.png\n")

  # 5. Rating distribution (if ratings exist)
  if (any(!is.na(df_prepared$rating_average))) {
    p <- plot_rating_distribution(df_prepared)
    ggsave(file.path(output_dir, "rating_distribution.png"), p, width = 8, height = 6, dpi = 150)
    cat("  - Saved rating_distribution.png\n")
  }

  # 6. Sample fragrance accord composition
  sample_row <- df[1, ]
  accords <- parse_accords(sample_row$accords)
  if (nrow(accords) > 0) {
    p <- plot_accord_composition(accords, sample_row$name)
    ggsave(file.path(output_dir, "sample_accords.png"), p, width = 8, height = 6, dpi = 150)
    cat("  - Saved sample_accords.png\n")
  }

  cat(sprintf("\nAll visualizations saved to '%s/' directory\n", output_dir))

  # Try to create dashboard
  cat("\nAttempting to create dashboard...\n")
  dashboard <- create_dashboard(df_prepared)
  if (!is.null(dashboard)) {
    ggsave(file.path(output_dir, "dashboard.png"), dashboard, width = 14, height = 10, dpi = 150)
    cat("  - Saved dashboard.png\n")
  }
}

# Run visualization
if (sys.nframe() == 0) {
  main()
}
