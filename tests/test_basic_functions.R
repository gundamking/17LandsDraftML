# Basic Unit Tests for 17Lands Draft ML
# Tests for core utility functions

# Load testthat if available
if (require(testthat, quietly = TRUE)) {
  library(testthat)
} else {
  # Simple test framework if testthat is not available
  test_that <- function(desc, code) {
    cat("Testing:", desc, "\n")
    tryCatch({
      code
      cat("✓ PASS\n")
    }, error = function(e) {
      cat("✗ FAIL:", e$message, "\n")
    })
  }
}

# Source utility functions
source("R/utils.R")

# Test utility functions
test_that("clean_card_names handles basic cases", {
  # Test basic cleaning
  expect_equal(clean_card_names("Lightning Bolt"), "lightning.bolt")
  expect_equal(clean_card_names("Counterspell"), "counterspell")
  expect_equal(clean_card_names("Black Lotus"), "black.lotus")
  
  # Test special characters
  expect_equal(clean_card_names("Jace's Phantasm"), "jace.s.phantasm")
  expect_equal(clean_card_names("Goblin Guide"), "goblin.guide")
  
  # Test edge cases
  expect_equal(clean_card_names(""), "")
  expect_equal(clean_card_names(character(0)), character(0))
  expect_equal(clean_card_names(NULL), character(0))
})

test_that("calculate_win_rate works correctly", {
  # Test normal cases
  expect_equal(calculate_win_rate(3, 2), 0.6)
  expect_equal(calculate_win_rate(7, 0), 1.0)
  expect_equal(calculate_win_rate(0, 3), 0.0)
  
  # Test edge cases
  expect_true(is.na(calculate_win_rate(0, 0)))
  expect_true(is.na(calculate_win_rate(NA, 3)))
  expect_true(is.na(calculate_win_rate(3, NA)))
})

test_that("is_draft_completed works correctly", {
  # Test completed drafts
  expect_true(is_draft_completed(7, 0))   # 7 wins
  expect_true(is_draft_completed(0, 3))   # 3 losses
  expect_true(is_draft_completed(7, 3))   # 7 wins, 3 losses
  
  # Test incomplete drafts
  expect_false(is_draft_completed(6, 2))  # 6 wins, 2 losses
  expect_false(is_draft_completed(5, 2))  # 5 wins, 2 losses
  expect_false(is_draft_completed(0, 0))  # No games
})

test_that("safe_divide works correctly", {
  # Test normal division
  expect_equal(safe_divide(10, 2), 5)
  expect_equal(safe_divide(0, 5), 0)
  
  # Test division by zero
  expect_equal(safe_divide(10, 0), 0)
  expect_equal(safe_divide(10, 0, default_value = NA), NA)
  
  # Test with custom default
  expect_equal(safe_divide(10, 0, default_value = 999), 999)
})

test_that("handle_missing_values works correctly", {
  # Test numeric vectors
  test_numeric <- c(1, 2, NA, 4, 5)
  expect_equal(handle_missing_values(test_numeric, 0), c(1, 2, 0, 4, 5))
  expect_equal(handle_missing_values(test_numeric, 999), c(1, 2, 999, 4, 5))
  
  # Test character vectors
  test_character <- c("a", "b", NA, "d", "e")
  expect_equal(handle_missing_values(test_character, "missing"), 
               c("a", "b", "missing", "d", "e"))
  
  # Test edge cases
  expect_equal(handle_missing_values(numeric(0)), numeric(0))
  expect_equal(handle_missing_values(NULL), NULL)
})

test_that("validate_data_structure works correctly", {
  # Test valid data
  valid_data <- data.frame(
    draft_id = 1:3,
    pick = c("Card1", "Card2", "Card3"),
    pick_maindeck_rate = c(0.8, 0.6, 0.9),
    event_match_wins = c(3, 5, 7),
    event_match_losses = c(2, 1, 0)
  )
  
  required_cols <- c("draft_id", "pick", "pick_maindeck_rate", 
                     "event_match_wins", "event_match_losses")
  
  expect_true(validate_data_structure(valid_data, required_cols))
  
  # Test missing columns
  invalid_data <- valid_data[, 1:3]  # Remove some columns
  expect_false(validate_data_structure(invalid_data, required_cols))
  
  # Test empty data frame
  empty_data <- data.frame()
  expect_false(validate_data_structure(empty_data, required_cols))
})

test_that("print_progress works without errors", {
  # Test that it doesn't throw errors
  expect_no_error(print_progress(1, 10, "Test"))
  expect_no_error(print_progress(5, 10, "Test"))
  expect_no_error(print_progress(10, 10, "Test"))
  
  # Test edge cases
  expect_no_error(print_progress(0, 0, "Test"))
  expect_no_error(print_progress(1, 1, "Test"))
})

test_that("log_message works without errors", {
  # Test different log levels
  expect_no_error(log_message("Test info message", "INFO"))
  expect_no_error(log_message("Test warning message", "WARNING"))
  expect_no_error(log_message("Test error message", "ERROR"))
  
  # Test with and without timestamp
  expect_no_error(log_message("Test message", timestamp = TRUE))
  expect_no_error(log_message("Test message", timestamp = FALSE))
})

# Run all tests if this file is sourced directly
if (FALSE) {
  cat("Running unit tests...\n")
  
  # Test utility functions
  test_that("clean_card_names handles basic cases", {
    expect_equal(clean_card_names("Lightning Bolt"), "lightning.bolt")
  })
  
  test_that("calculate_win_rate works correctly", {
    expect_equal(calculate_win_rate(3, 2), 0.6)
  })
  
  test_that("is_draft_completed works correctly", {
    expect_true(is_draft_completed(7, 0))
    expect_false(is_draft_completed(6, 2))
  })
  
  cat("All tests completed!\n")
} 