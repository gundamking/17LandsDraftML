# Main Draft Analysis Pipeline for 17Lands Draft ML
# Complete analysis workflow from data loading to model evaluation

# Load required libraries
library(randomForest)
library(pROC)
library(ggplot2)
library(dplyr)
library(readr)

# Source all modules
source("R/utils.R")
source("R/data_processing.R")
source("R/modeling.R")
source("R/visualization.R")

#' Complete draft analysis pipeline
#' @param data_file Path to the CSV data file
#' @param output_dir Output directory for results
#' @param test_proportion Proportion of data for testing (default: 0.2)
#' @param seed Random seed for reproducibility
#' @param save_models Whether to save trained models
#' @param create_plots Whether to create visualization plots
#' @return List with all analysis results
run_draft_analysis <- function(data_file, output_dir = "output", test_proportion = 0.2, 
                              seed = 42, save_models = TRUE, create_plots = TRUE) {
  
  log_message("Starting draft analysis pipeline", "INFO")
  log_message(paste("Data file:", data_file), "INFO")
  log_message(paste("Output directory:", output_dir), "INFO")
  
  # Ensure output directory exists
  ensure_dir_exists(output_dir)
  
  # Set random seed
  set.seed(seed)
  
  # Step 1: Load and validate data
  log_message("Step 1: Loading and validating data", "INFO")
  raw_data <- load_draft_data(data_file)
  
  # Step 2: Process data
  log_message("Step 2: Processing draft data", "INFO")
  processed_data <- process_draft_data(raw_data)
  
  # Step 3: Create data exploration plots
  if (create_plots) {
    log_message("Step 3: Creating data exploration plots", "INFO")
    exploration_plots <- create_data_exploration_plots(processed_data, output_dir)
  }
  
  # Step 4: Split data
  log_message("Step 4: Splitting data into training and testing sets", "INFO")
  data_split <- split_data(processed_data, test_proportion, seed)
  
  # Step 5: Train classification model
  log_message("Step 5: Training classification model", "INFO")
  binary_labels <- create_binary_labels(data_split$train$win_rates)
  classification_model <- train_classification_model(
    data_split$train$deck_matrix, 
    binary_labels
  )
  
  # Step 6: Train regression model
  log_message("Step 6: Training regression model", "INFO")
  regression_model <- train_regression_model(
    data_split$train$deck_matrix, 
    data_split$train$win_rates
  )
  
  # Step 7: Evaluate classification model
  log_message("Step 7: Evaluating classification model", "INFO")
  test_binary_labels <- create_binary_labels(data_split$test$win_rates)
  classification_results <- evaluate_classification_model(
    classification_model,
    data_split$test$deck_matrix,
    test_binary_labels
  )
  
  # Step 8: Evaluate regression model
  log_message("Step 8: Evaluating regression model", "INFO")
  regression_results <- evaluate_regression_model(
    regression_model,
    data_split$test$deck_matrix,
    data_split$test$win_rates
  )
  
  # Step 9: Get feature importance
  log_message("Step 9: Analyzing feature importance", "INFO")
  classification_importance <- get_feature_importance(classification_model)
  regression_importance <- get_feature_importance(regression_model)
  
  # Step 10: Create evaluation plots
  if (create_plots) {
    log_message("Step 10: Creating evaluation plots", "INFO")
    
    # Classification evaluation dashboard
    classification_plots <- create_evaluation_dashboard(
      classification_results,
      classification_results$predictions[, 2],
      as.numeric(test_binary_labels) - 1,  # Convert to 0/1
      classification_importance,
      output_dir,
      "classification"
    )
    
    # Regression evaluation dashboard
    regression_plots <- create_evaluation_dashboard(
      regression_results,
      regression_results$predictions,
      data_split$test$win_rates,
      regression_importance,
      output_dir,
      "regression"
    )
  }
  
  # Step 11: Save models and results
  if (save_models) {
    log_message("Step 11: Saving models and results", "INFO")
    
    # Save models
    save_model(classification_model, file.path(output_dir, "classification_model.rds"))
    save_model(regression_model, file.path(output_dir, "regression_model.rds"))
    
    # Save feature importance
    write.csv(classification_importance, 
              file.path(output_dir, "classification_importance.csv"), 
              row.names = FALSE)
    write.csv(regression_importance, 
              file.path(output_dir, "regression_importance.csv"), 
              row.names = FALSE)
    
    # Save processed data
    save_processed_data(processed_data, output_dir, "processed")
  }
  
  # Step 12: Generate summary report
  log_message("Step 12: Generating summary report", "INFO")
  summary_report <- generate_summary_report(
    classification_results,
    regression_results,
    processed_data,
    output_dir
  )
  
  # Compile results
  results <- list(
    data_summary = list(
      total_drafts = nrow(processed_data$deck_matrix),
      total_cards = length(processed_data$pool_columns),
      train_size = nrow(data_split$train$deck_matrix),
      test_size = nrow(data_split$test$deck_matrix)
    ),
    models = list(
      classification = classification_model,
      regression = regression_model
    ),
    evaluation = list(
      classification = classification_results,
      regression = regression_results
    ),
    importance = list(
      classification = classification_importance,
      regression = regression_importance
    ),
    summary_report = summary_report
  )
  
  log_message("Draft analysis pipeline completed successfully", "INFO")
  return(results)
}

#' Generate summary report
#' @param classification_results Classification model results
#' @param regression_results Regression model results
#' @param processed_data Processed data summary
#' @param output_dir Output directory
#' @return Summary report text
generate_summary_report <- function(classification_results, regression_results, 
                                  processed_data, output_dir) {
  
  report <- c(
    "=== 17Lands Draft ML Analysis Report ===",
    paste("Generated:", Sys.time()),
    "",
    "=== Data Summary ===",
    paste("Total decks analyzed:", nrow(processed_data$deck_matrix)),
    paste("Total cards in dataset:", length(processed_data$pool_columns)),
    paste("Win rate range:", round(min(processed_data$win_rates), 3), 
          "-", round(max(processed_data$win_rates), 3)),
    paste("Mean win rate:", round(mean(processed_data$win_rates), 3)),
    "",
    "=== Classification Model Performance ===",
    paste("AUC:", round(classification_results$auc, 3)),
    paste("Accuracy:", round(classification_results$accuracy, 3)),
    paste("Sensitivity:", round(classification_results$sensitivity, 3)),
    paste("Specificity:", round(classification_results$specificity, 3)),
    "",
    "=== Regression Model Performance ===",
    paste("R²:", round(regression_results$r_squared, 3)),
    paste("RMSE:", round(regression_results$rmse, 3)),
    paste("MAE:", round(regression_results$mae, 3)),
    paste("Correlation:", round(regression_results$correlation, 3)),
    "",
    "=== Top 10 Most Important Cards (Classification) ===",
    paste(head(classification_results$importance$feature, 10), 
          collapse = ", "),
    "",
    "=== Top 10 Most Important Cards (Regression) ===",
    paste(head(regression_results$importance$feature, 10), 
          collapse = ", "),
    "",
    "=== Files Generated ===",
    "- classification_model.rds: Trained classification model",
    "- regression_model.rds: Trained regression model",
    "- classification_importance.csv: Feature importance for classification",
    "- regression_importance.csv: Feature importance for regression",
    "- Various PNG plots in output directory",
    "",
    "=== Usage Notes ===",
    "- Use the saved models for making predictions on new draft data",
    "- Feature importance files show which cards most influence win rates",
    "- Calibration plots show how well predictions match actual outcomes",
    "- ROC curves show classification model performance across thresholds"
  )
  
  # Save report
  report_file <- file.path(output_dir, "analysis_report.txt")
  writeLines(report, report_file)
  
  # Print to console
  cat(paste(report, collapse = "\n"), "\n")
  
  return(report)
}

#' Quick analysis function for testing
#' @param data_file Path to data file
#' @param output_dir Output directory
#' @return Analysis results
quick_analysis <- function(data_file, output_dir = "output") {
  log_message("Running quick analysis", "INFO")
  
  # Run with minimal settings for quick testing
  results <- run_draft_analysis(
    data_file = data_file,
    output_dir = output_dir,
    test_proportion = 0.3,
    seed = 42,
    save_models = TRUE,
    create_plots = TRUE
  )
  
  return(results)
}

#' Predict win rates for new deck data
#' @param model Trained regression model
#' @param deck_matrix New deck composition matrix
#' @param calibration_model Optional calibration model
#' @return Predicted win rates
predict_deck_performance <- function(model, deck_matrix, calibration_model = NULL) {
  log_message("Making predictions for new deck data", "INFO")
  
  # Make predictions
  predictions <- predict(model, deck_matrix)
  
  # Apply calibration if available
  if (!is.null(calibration_model)) {
    predictions <- predict(calibration_model, data.frame(predicted_mean = predictions))
    predictions <- pmax(0, pmin(1, predictions))  # Ensure range [0,1]
  }
  
  return(predictions)
}

#' Analyze specific cards' impact on win rate
#' @param model Trained model
#' @param deck_matrix Base deck matrix
#' @param cards_to_test Vector of card names to test
#' @return Data frame with card impact analysis
analyze_card_impact <- function(model, deck_matrix, cards_to_test) {
  log_message("Analyzing card impact on win rates", "INFO")
  
  impact_results <- data.frame(
    card = cards_to_test,
    base_win_rate = numeric(length(cards_to_test)),
    with_card_win_rate = numeric(length(cards_to_test)),
    impact = numeric(length(cards_to_test)),
    stringsAsFactors = FALSE
  )
  
  # Get base prediction
  base_prediction <- predict(model, deck_matrix)
  
  for (i in seq_along(cards_to_test)) {
    card <- cards_to_test[i]
    
    # Find card column
    card_col <- grep(paste0("^pool_", card, "$"), colnames(deck_matrix), 
                     ignore.case = TRUE, value = TRUE)
    
    if (length(card_col) > 0) {
      # Create modified deck with card
      modified_deck <- deck_matrix
      modified_deck[, card_col] <- 1  # Add the card
      
      # Get prediction with card
      with_card_prediction <- predict(model, modified_deck)
      
      # Calculate impact
      impact_results$base_win_rate[i] <- base_prediction
      impact_results$with_card_win_rate[i] <- with_card_prediction
      impact_results$impact[i] <- with_card_prediction - base_prediction
    }
  }
  
  # Sort by impact
  impact_results <- impact_results[order(-impact_results$impact), ]
  
  return(impact_results)
}

# Example usage and documentation
if (FALSE) {
  # Example: Run complete analysis
  results <- run_draft_analysis(
    data_file = "data/draft_data_public.SNC.PremierDraft.csv",
    output_dir = "output"
  )
  
  # Example: Quick analysis for testing
  quick_results <- quick_analysis("data/your_data.csv")
  
  # Example: Make predictions on new data
  model <- load_model("output/regression_model.rds")
  new_predictions <- predict_deck_performance(model, new_deck_matrix)
  
  # Example: Analyze specific cards
  card_impact <- analyze_card_impact(
    model, 
    base_deck_matrix, 
    c("Lightning Bolt", "Counterspell", "Black Lotus")
  )
} 