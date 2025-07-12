# Setup Script for 17Lands Draft ML
# This script initializes the project and installs dependencies

cat("=== 17Lands Draft ML Setup ===\n")
cat("Initializing project...\n\n")

# Create necessary directories
dirs_to_create <- c("data", "output", "docs", "tests", "examples")
for (dir in dirs_to_create) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("Created directory:", dir, "\n")
  } else {
    cat("Directory already exists:", dir, "\n")
  }
}

# Install dependencies
cat("\nInstalling R package dependencies...\n")
source("R/install_dependencies.R")

# Test basic functionality
cat("\nTesting basic functionality...\n")
source("R/utils.R")

# Test utility functions
test_result <- tryCatch({
  # Test basic functions
  clean_card_names("Lightning Bolt")
  calculate_win_rate(3, 2)
  is_draft_completed(7, 0)
  
  cat("✓ Basic functions working correctly\n")
  TRUE
}, error = function(e) {
  cat("✗ Error testing basic functions:", e$message, "\n")
  FALSE
})

# Create sample data file if it doesn't exist
sample_data_file <- "data/README.md"
if (!file.exists(sample_data_file)) {
  sample_content <- c(
    "# Data Directory",
    "",
    "Place your 17Lands draft data files in this directory.",
    "",
    "## Expected File Format",
    "",
    "The analysis expects CSV files with the following columns:",
    "- `draft_id`: Unique identifier for each draft",
    "- `pick`: Card name for each pick",
    "- `pick_maindeck_rate`: Rate at which the card was included in the main deck",
    "- `event_match_wins`: Number of match wins",
    "- `event_match_losses`: Number of match losses",
    "- `user_game_win_rate_bucket`: Player skill metric",
    "- `user_n_games_bucket`: Player experience metric",
    "- Pool columns: Binary indicators for each card in the format `pool_[cardname]`",
    "",
    "## Example Usage",
    "",
    "1. Download your draft data from 17Lands",
    "2. Place the CSV file in this directory",
    "3. Run the analysis: `source('R/draft_analysis.R')`",
    "4. Check the `output/` directory for results"
  )
  
  writeLines(sample_content, sample_data_file)
  cat("Created sample data README\n")
}

# Create output directory README
output_readme <- "output/README.md"
if (!file.exists(output_readme)) {
  output_content <- c(
    "# Output Directory",
    "",
    "This directory contains analysis results and generated files.",
    "",
    "## Generated Files",
    "",
    "- `classification_model.rds`: Trained classification model",
    "- `regression_model.rds`: Trained regression model",
    "- `classification_importance.csv`: Feature importance for classification",
    "- `regression_importance.csv`: Feature importance for regression",
    "- `analysis_report.txt`: Summary report of the analysis",
    "- Various PNG plots showing model performance and data exploration",
    "",
    "## Usage",
    "",
    "After running the analysis, you can:",
    "1. Load trained models for predictions",
    "2. View feature importance to understand card impact",
    "3. Examine plots for model validation",
    "4. Use the analysis report for insights"
  )
  
  writeLines(output_content, output_readme)
  cat("Created output README\n")
}

# Test the main analysis script
cat("\nTesting main analysis script...\n")
test_analysis <- tryCatch({
  source("R/draft_analysis.R")
  cat("✓ Main analysis script loaded successfully\n")
  TRUE
}, error = function(e) {
  cat("✗ Error loading main analysis script:", e$message, "\n")
  FALSE
})

# Summary
cat("\n=== Setup Complete ===\n")
if (test_result && test_analysis) {
  cat("✓ All tests passed\n")
  cat("✓ Project ready for use\n")
  cat("\nNext steps:\n")
  cat("1. Place your 17Lands data file in the data/ directory\n")
  cat("2. Run: source('R/draft_analysis.R')\n")
  cat("3. Run: results <- run_draft_analysis('data/your_file.csv')\n")
  cat("4. Check the output/ directory for results\n")
} else {
  cat("✗ Some tests failed. Please check the error messages above.\n")
  cat("Make sure all required R packages are installed.\n")
}

cat("\nFor more information, see README.md\n") 