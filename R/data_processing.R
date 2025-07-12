# Data Processing Functions for 17Lands Draft ML
# Functions for cleaning, validating, and preparing draft data

# Load required libraries
library(dplyr)
library(readr)
library(tidyr)

# Source utility functions
source("R/utils.R")

#' Load and validate 17Lands draft data
#' @param file_path Path to the CSV file
#' @param validate_structure Whether to validate required columns
#' @return Data frame with loaded data
load_draft_data <- function(file_path, validate_structure = TRUE) {
  log_message("Loading draft data from file", "INFO")
  
  # Check if file exists
  if (!file.exists(file_path)) {
    stop("Data file not found: ", file_path)
  }
  
  # Load data with error handling
  tryCatch({
    data <- read_csv(file_path, show_col_types = FALSE)
    log_message(paste("Loaded", nrow(data), "rows and", ncol(data), "columns"), "INFO")
  }, error = function(e) {
    stop("Error loading data: ", e$message)
  })
  
  # Validate structure if requested
  if (validate_structure) {
    required_cols <- c("draft_id", "pick", "pick_maindeck_rate", 
                      "event_match_wins", "event_match_losses")
    if (!validate_data_structure(data, required_cols)) {
      warning("Data structure validation failed")
    }
  }
  
  return(data)
}

#' Process draft data to extract deck compositions and win rates
#' @param data Raw draft data
#' @param min_games Minimum number of games for inclusion
#' @return List containing processed data
process_draft_data <- function(data, min_games = 1) {
  log_message("Processing draft data", "INFO")
  
  # Find completed drafts
  completed_drafts <- data %>%
    filter(is_draft_completed(event_match_wins, event_match_losses)) %>%
    group_by(draft_id) %>%
    summarise(
      total_games = first(event_match_wins + event_match_losses),
      .groups = 'drop'
    ) %>%
    filter(total_games >= min_games)
  
  log_message(paste("Found", nrow(completed_drafts), "completed drafts"), "INFO")
  
  # Get pool columns (card availability)
  pool_cols <- grep('^pool_', colnames(data), value = TRUE)
  log_message(paste("Found", length(pool_cols), "pool columns"), "INFO")
  
  # Process each completed draft
  deck_data <- list()
  win_rates <- numeric()
  user_metrics <- list()
  
  for (i in seq_along(completed_drafts$draft_id)) {
    draft_id <- completed_drafts$draft_id[i]
    
    # Get draft picks
    draft_picks <- data %>%
      filter(draft_id == !!draft_id) %>%
      arrange(pick_number)
    
    if (nrow(draft_picks) == 0) next
    
    # Calculate win rate
    wins <- draft_picks$event_match_wins[1]
    losses <- draft_picks$event_match_losses[1]
    win_rate <- calculate_win_rate(wins, losses)
    
    if (is.na(win_rate)) next
    
    # Build deck composition
    deck_composition <- rep(0, length(pool_cols))
    names(deck_composition) <- pool_cols
    
    # Process each pick
    for (j in 1:nrow(draft_picks)) {
      pick <- draft_picks$pick[j]
      maindeck_rate <- draft_picks$pick_maindeck_rate[j]
      
      if (!is.na(maindeck_rate) && maindeck_rate > 0) {
        # Clean card name for matching
        cleaned_pick <- clean_card_names(pick)
        
        # Find matching pool column
        for (pool_col in pool_cols) {
          card_name <- gsub('^pool_', '', pool_col)
          cleaned_card <- clean_card_names(card_name)
          
          if (grepl(cleaned_pick, cleaned_card, ignore.case = TRUE) ||
              grepl(cleaned_card, cleaned_pick, ignore.case = TRUE)) {
            deck_composition[pool_col] <- deck_composition[pool_col] + maindeck_rate
            break
          }
        }
      }
    }
    
    # Store results
    deck_data[[i]] <- deck_composition
    win_rates[i] <- win_rate
    
    # Store user metrics if available
    if ("user_game_win_rate_bucket" %in% colnames(draft_picks)) {
      user_metrics[[i]] <- list(
        skill_bucket = draft_picks$user_game_win_rate_bucket[1],
        experience_bucket = draft_picks$user_n_games_bucket[1]
      )
    }
    
    # Progress update
    if (i %% 100 == 0 || i == length(completed_drafts$draft_id)) {
      print_progress(i, length(completed_drafts$draft_id), "Processing drafts")
    }
  }
  
  # Convert to data frame
  deck_matrix <- do.call(rbind, deck_data)
  
  # Remove rows with all zeros or NA values
  valid_rows <- apply(deck_matrix, 1, function(row) {
    !all(is.na(row)) && !all(row == 0)
  })
  
  deck_matrix <- deck_matrix[valid_rows, ]
  win_rates <- win_rates[valid_rows]
  
  log_message(paste("Final dataset:", nrow(deck_matrix), "decks"), "INFO")
  
  return(list(
    deck_matrix = deck_matrix,
    win_rates = win_rates,
    user_metrics = user_metrics[valid_rows],
    pool_columns = pool_cols
  ))
}

#' Create binary classification labels from win rates
#' @param win_rates Vector of win rates
#' @param threshold Threshold for positive class (default: 6/9 = 0.667)
#' @return Factor vector with binary labels
create_binary_labels <- function(win_rates, threshold = 6/9) {
  labels <- ifelse(win_rates >= threshold, "High_Performance", "Low_Performance")
  return(factor(labels, levels = c("Low_Performance", "High_Performance")))
}

#' Add user skill features to deck data
#' @param deck_data Processed deck data
#' @param user_metrics User skill metrics
#' @return Enhanced deck data with user features
add_user_features <- function(deck_data, user_metrics) {
  if (length(user_metrics) == 0) {
    log_message("No user metrics available", "WARNING")
    return(deck_data)
  }
  
  # Extract user features
  skill_buckets <- sapply(user_metrics, function(x) x$skill_bucket)
  experience_buckets <- sapply(user_metrics, function(x) x$experience_bucket)
  
  # Convert to numeric if they're factors
  skill_buckets <- as.numeric(as.character(skill_buckets))
  experience_buckets <- as.numeric(as.character(experience_buckets))
  
  # Handle missing values
  skill_buckets <- handle_missing_values(skill_buckets, median(skill_buckets, na.rm = TRUE))
  experience_buckets <- handle_missing_values(experience_buckets, median(experience_buckets, na.rm = TRUE))
  
  # Add to deck matrix
  enhanced_matrix <- cbind(
    deck_data$deck_matrix,
    user_skill_bucket = skill_buckets,
    user_experience_bucket = experience_buckets
  )
  
  return(list(
    deck_matrix = enhanced_matrix,
    win_rates = deck_data$win_rates,
    user_metrics = user_metrics,
    pool_columns = deck_data$pool_columns
  ))
}

#' Split data into training and testing sets
#' @param deck_data Processed deck data
#' @param test_proportion Proportion for testing (default: 0.2)
#' @param seed Random seed for reproducibility
#' @return List with training and testing data
split_data <- function(deck_data, test_proportion = 0.2, seed = 42) {
  set.seed(seed)
  
  n_samples <- nrow(deck_data$deck_matrix)
  test_size <- floor(test_proportion * n_samples)
  train_size <- n_samples - test_size
  
  # Create indices
  indices <- sample(1:n_samples)
  train_indices <- indices[1:train_size]
  test_indices <- indices[(train_size + 1):n_samples]
  
  # Split data
  train_data <- list(
    deck_matrix = deck_data$deck_matrix[train_indices, ],
    win_rates = deck_data$win_rates[train_indices],
    user_metrics = deck_data$user_metrics[train_indices],
    pool_columns = deck_data$pool_columns
  )
  
  test_data <- list(
    deck_matrix = deck_data$deck_matrix[test_indices, ],
    win_rates = deck_data$win_rates[test_indices],
    user_metrics = deck_data$user_metrics[test_indices],
    pool_columns = deck_data$pool_columns
  )
  
  log_message(paste("Split data: Training =", train_size, "Testing =", test_size), "INFO")
  
  return(list(train = train_data, test = test_data))
}

#' Save processed data to files
#' @param deck_data Processed deck data
#' @param output_dir Output directory
#' @param prefix File name prefix
save_processed_data <- function(deck_data, output_dir = "output", prefix = "draft") {
  ensure_dir_exists(output_dir)
  
  # Save deck matrix
  deck_file <- file.path(output_dir, paste0(prefix, "_decks.csv"))
  write.csv(deck_data$deck_matrix, deck_file, row.names = FALSE)
  
  # Save win rates
  rates_file <- file.path(output_dir, paste0(prefix, "_win_rates.csv"))
  write.csv(data.frame(win_rate = deck_data$win_rates), rates_file, row.names = FALSE)
  
  # Save metadata
  meta_file <- file.path(output_dir, paste0(prefix, "_metadata.txt"))
  metadata <- c(
    paste("Number of decks:", nrow(deck_data$deck_matrix)),
    paste("Number of cards:", length(deck_data$pool_columns)),
    paste("Date processed:", Sys.time()),
    paste("Win rate range:", round(min(deck_data$win_rates), 3), "-", round(max(deck_data$win_rates), 3))
  )
  writeLines(metadata, meta_file)
  
  log_message(paste("Saved processed data to", output_dir), "INFO")
} 