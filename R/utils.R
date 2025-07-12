# Utility Functions for 17Lands Draft ML
# Common helper functions used across the project

#' Clean card names for consistent matching
#' @param card_names Vector of card names to clean
#' @return Vector of cleaned card names
clean_card_names <- function(card_names) {
  if (is.null(card_names) || length(card_names) == 0) {
    return(character(0))
  }
  
  cleaned <- card_names %>%
    gsub(' ', '.', .) %>%
    gsub('-', '.', .) %>%
    gsub("'", '.', .) %>%
    gsub('"', '.', .) %>%
    gsub('&', '.and.', .) %>%
    gsub(',', '.', .) %>%
    gsub(':', '.', .) %>%
    gsub('!', '.', .) %>%
    gsub('\\?', '.', .) %>%
    gsub('\\(', '.', .) %>%
    gsub('\\)', '.', .) %>%
    gsub('\\[', '.', .) %>%
    gsub('\\]', '.', .) %>%
    gsub('\\{', '.', .) %>%
    gsub('\\}', '.', .) %>%
    gsub('\\\\', '.', .) %>%
    gsub('/', '.', .) %>%
    gsub('\\\\', '.', .) %>%
    tolower()
  
  return(cleaned)
}

#' Calculate win rate from wins and losses
#' @param wins Number of wins
#' @param losses Number of losses
#' @return Win rate as a proportion
calculate_win_rate <- function(wins, losses) {
  total_games <- wins + losses
  if (total_games == 0) {
    return(NA)
  }
  return(wins / total_games)
}

#' Check if a draft is completed
#' @param wins Number of wins
#' @param losses Number of losses
#' @return Logical indicating if draft is complete
is_draft_completed <- function(wins, losses) {
  return(wins == 7 | losses == 3)
}

#' Safe division function
#' @param numerator Numerator
#' @param denominator Denominator
#' @param default_value Value to return if denominator is 0
#' @return Result of division or default value
safe_divide <- function(numerator, denominator, default_value = 0) {
  if (denominator == 0) {
    return(default_value)
  }
  return(numerator / denominator)
}

#' Create output directory if it doesn't exist
#' @param dir_path Path to directory
#' @return Logical indicating success
ensure_dir_exists <- function(dir_path) {
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
    cat("Created directory:", dir_path, "\n")
  }
  return(TRUE)
}

#' Save plot with consistent formatting
#' @param plot_obj ggplot object
#' @param filename Name of file to save
#' @param width Plot width in inches
#' @param height Plot height in inches
#' @param dpi Resolution in DPI
save_plot <- function(plot_obj, filename, width = 10, height = 8, dpi = 300) {
  ensure_dir_exists(dirname(filename))
  
  ggsave(
    filename = filename,
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white"
  )
  
  cat("Plot saved:", filename, "\n")
}

#' Print progress message
#' @param current Current iteration
#' @param total Total iterations
#' @param message Custom message
print_progress <- function(current, total, message = "Processing") {
  if (current %% max(1, floor(total / 100)) == 0 || current == total) {
    percentage <- round(current / total * 100, 1)
    cat(sprintf("%s: %d/%d (%.1f%%)\n", message, current, total, percentage))
  }
}

#' Validate data structure
#' @param data Data frame to validate
#' @param required_cols Required column names
#' @return Logical indicating if data is valid
validate_data_structure <- function(data, required_cols) {
  missing_cols <- setdiff(required_cols, colnames(data))
  
  if (length(missing_cols) > 0) {
    cat("Warning: Missing required columns:", paste(missing_cols, collapse = ", "), "\n")
    return(FALSE)
  }
  
  return(TRUE)
}

#' Handle missing values in a safe way
#' @param x Vector to process
#' @param replacement Value to use for missing data
#' @return Vector with missing values replaced
handle_missing_values <- function(x, replacement = 0) {
  if (is.numeric(x)) {
    x[is.na(x)] <- replacement
  } else {
    x[is.na(x)] <- as.character(replacement)
  }
  return(x)
}

#' Log function for debugging and monitoring
#' @param message Message to log
#' @param level Log level (INFO, WARNING, ERROR)
#' @param timestamp Whether to include timestamp
log_message <- function(message, level = "INFO", timestamp = TRUE) {
  timestamp_str <- if (timestamp) paste0("[", Sys.time(), "] ") else ""
  cat(paste0(timestamp_str, level, ": ", message, "\n"))
} 