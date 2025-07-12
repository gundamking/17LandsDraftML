# Basic Analysis Example for 17Lands Draft ML
# This script demonstrates how to use the analysis pipeline

# Load the main analysis script
source("../R/draft_analysis.R")

# Example 1: Quick analysis with default settings
cat("=== Example 1: Quick Analysis ===\n")

# Check if data file exists
data_file <- "../data/draft_data_public.SNC.PremierDraft.csv"
if (file.exists(data_file)) {
  cat("Running quick analysis...\n")
  
  # Run quick analysis
  results <- quick_analysis(data_file, "../output")
  
  # Print summary
  cat("\nAnalysis completed!\n")
  cat("Total decks analyzed:", results$data_summary$total_drafts, "\n")
  cat("Classification AUC:", round(results$evaluation$classification$auc, 3), "\n")
  cat("Regression R²:", round(results$evaluation$regression$r_squared, 3), "\n")
  
} else {
  cat("Data file not found. Please place your 17Lands data file in the data/ directory.\n")
  cat("Expected file:", data_file, "\n")
}

# Example 2: Custom analysis with specific settings
cat("\n=== Example 2: Custom Analysis ===\n")

if (file.exists(data_file)) {
  cat("Running custom analysis...\n")
  
  # Run with custom settings
  custom_results <- run_draft_analysis(
    data_file = data_file,
    output_dir = "../output/custom",
    test_proportion = 0.3,  # Use 30% for testing
    seed = 123,              # Different random seed
    save_models = TRUE,
    create_plots = TRUE
  )
  
  # Show feature importance
  cat("\nTop 5 most important cards (Classification):\n")
  top_classification <- head(custom_results$importance$classification, 5)
  for (i in 1:nrow(top_classification)) {
    cat(sprintf("%d. %s (%.3f)\n", 
                i, 
                top_classification$feature[i], 
                top_classification$importance[i]))
  }
  
  cat("\nTop 5 most important cards (Regression):\n")
  top_regression <- head(custom_results$importance$regression, 5)
  for (i in 1:nrow(top_regression)) {
    cat(sprintf("%d. %s (%.3f)\n", 
                i, 
                top_regression$feature[i], 
                top_regression$importance[i]))
  }
  
} else {
  cat("Data file not found. Skipping custom analysis.\n")
}

# Example 3: Making predictions on new data
cat("\n=== Example 3: Making Predictions ===\n")

# This example shows how to use a trained model for predictions
if (file.exists("../output/regression_model.rds")) {
  cat("Loading trained model...\n")
  
  # Load the trained model
  model <- load_model("../output/regression_model.rds")
  
  # Create sample deck data (this would normally come from actual draft data)
  # For demonstration, we'll create a simple example
  cat("Creating sample deck for prediction...\n")
  
  # Note: In practice, you would load actual deck data here
  # This is just for demonstration
  sample_deck <- matrix(0, nrow = 1, ncol = 100)  # Assuming 100 cards
  colnames(sample_deck) <- paste0("pool_card_", 1:100)
  
  # Add some cards to the deck (simulating a real deck)
  sample_deck[1, c(1, 5, 10, 15, 20)] <- 1  # Add 5 cards
  
  # Make prediction
  prediction <- predict_deck_performance(model, sample_deck)
  
  cat("Predicted win rate for sample deck:", round(prediction, 3), "\n")
  
} else {
  cat("Trained model not found. Run analysis first to create models.\n")
}

# Example 4: Analyzing specific cards
cat("\n=== Example 4: Card Impact Analysis ===\n")

if (file.exists("../output/regression_model.rds") && file.exists(data_file)) {
  cat("Analyzing card impact...\n")
  
  # Load model and sample data
  model <- load_model("../output/regression_model.rds")
  
  # Create a base deck (empty deck)
  base_deck <- matrix(0, nrow = 1, ncol = 100)
  colnames(base_deck) <- paste0("pool_card_", 1:100)
  
  # Test specific cards
  cards_to_test <- c("Lightning Bolt", "Counterspell", "Black Lotus")
  
  # Analyze impact
  impact_results <- analyze_card_impact(model, base_deck, cards_to_test)
  
  cat("Card impact analysis:\n")
  for (i in 1:nrow(impact_results)) {
    cat(sprintf("%s: %.3f win rate impact\n", 
                impact_results$card[i], 
                impact_results$impact[i]))
  }
  
} else {
  cat("Model or data not found. Skipping card impact analysis.\n")
}

# Example 5: Data exploration
cat("\n=== Example 5: Data Exploration ===\n")

if (file.exists(data_file)) {
  cat("Exploring data structure...\n")
  
  # Load and process data
  raw_data <- load_draft_data(data_file)
  processed_data <- process_draft_data(raw_data)
  
  # Show data summary
  cat("Data summary:\n")
  cat("- Total decks:", nrow(processed_data$deck_matrix), "\n")
  cat("- Total cards:", length(processed_data$pool_columns), "\n")
  cat("- Win rate range:", round(min(processed_data$win_rates), 3), 
      "-", round(max(processed_data$win_rates), 3), "\n")
  cat("- Mean win rate:", round(mean(processed_data$win_rates), 3), "\n")
  
  # Show deck size distribution
  deck_sizes <- rowSums(processed_data$deck_matrix > 0)
  cat("- Average deck size:", round(mean(deck_sizes), 1), "cards\n")
  cat("- Deck size range:", min(deck_sizes), "-", max(deck_sizes), "cards\n")
  
} else {
  cat("Data file not found. Skipping data exploration.\n")
}

cat("\n=== Example Complete ===\n")
cat("Check the output/ directory for generated plots and models.\n")
cat("See README.md for more detailed usage instructions.\n") 