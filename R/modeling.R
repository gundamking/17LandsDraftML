# Modeling Functions for 17Lands Draft ML
# Machine learning models for predicting deck performance

# Load required libraries
library(randomForest)
library(pROC)
library(caret)
library(e1071)

# Source utility functions
source("R/utils.R")

#' Train Random Forest classification model
#' @param deck_matrix Matrix of deck compositions
#' @param labels Binary classification labels
#' @param ntree Number of trees (default: 100)
#' @param mtry Number of variables to try at each split (default: sqrt of features)
#' @param seed Random seed for reproducibility
#' @return Trained Random Forest model
train_classification_model <- function(deck_matrix, labels, ntree = 100, mtry = NULL, seed = 42) {
  log_message("Training Random Forest classification model", "INFO")
  
  set.seed(seed)
  
  # Calculate mtry if not provided
  if (is.null(mtry)) {
    mtry <- max(1, floor(sqrt(ncol(deck_matrix))))
  }
  
  # Train model with error handling
  tryCatch({
    model <- randomForest(
      x = deck_matrix,
      y = labels,
      ntree = ntree,
      mtry = mtry,
      importance = TRUE,
      proximity = FALSE
    )
    
    log_message(paste("Model trained with", ntree, "trees and mtry =", mtry), "INFO")
    return(model)
    
  }, error = function(e) {
    stop("Error training classification model: ", e$message)
  })
}

#' Train Random Forest regression model
#' @param deck_matrix Matrix of deck compositions
#' @param win_rates Vector of win rates
#' @param ntree Number of trees (default: 100)
#' @param mtry Number of variables to try at each split (default: sqrt of features)
#' @param seed Random seed for reproducibility
#' @return Trained Random Forest regression model
train_regression_model <- function(deck_matrix, win_rates, ntree = 100, mtry = NULL, seed = 42) {
  log_message("Training Random Forest regression model", "INFO")
  
  set.seed(seed)
  
  # Calculate mtry if not provided
  if (is.null(mtry)) {
    mtry <- max(1, floor(sqrt(ncol(deck_matrix))))
  }
  
  # Train model with error handling
  tryCatch({
    model <- randomForest(
      x = deck_matrix,
      y = win_rates,
      ntree = ntree,
      mtry = mtry,
      importance = TRUE,
      proximity = FALSE
    )
    
    log_message(paste("Model trained with", ntree, "trees and mtry =", mtry), "INFO")
    return(model)
    
  }, error = function(e) {
    stop("Error training regression model: ", e$message)
  })
}

#' Evaluate classification model performance
#' @param model Trained classification model
#' @param test_matrix Test data matrix
#' @param test_labels Test labels
#' @return List with performance metrics
evaluate_classification_model <- function(model, test_matrix, test_labels) {
  log_message("Evaluating classification model", "INFO")
  
  # Make predictions
  predictions <- predict(model, test_matrix, type = "prob")
  predicted_labels <- predict(model, test_matrix)
  
  # Calculate metrics
  confusion_matrix <- confusionMatrix(predicted_labels, test_labels)
  
  # Calculate AUC
  auc_value <- auc(test_labels, predictions[, 2])
  
  # Calculate other metrics
  accuracy <- confusion_matrix$overall["Accuracy"]
  sensitivity <- confusion_matrix$byClass["Sensitivity"]
  specificity <- confusion_matrix$byClass["Specificity"]
  
  results <- list(
    confusion_matrix = confusion_matrix,
    auc = auc_value,
    accuracy = accuracy,
    sensitivity = sensitivity,
    specificity = specificity,
    predictions = predictions,
    predicted_labels = predicted_labels
  )
  
  log_message(paste("Classification AUC:", round(auc_value, 3)), "INFO")
  log_message(paste("Accuracy:", round(accuracy, 3)), "INFO")
  
  return(results)
}

#' Evaluate regression model performance
#' @param model Trained regression model
#' @param test_matrix Test data matrix
#' @param test_rates Test win rates
#' @return List with performance metrics
evaluate_regression_model <- function(model, test_matrix, test_rates) {
  log_message("Evaluating regression model", "INFO")
  
  # Make predictions
  predictions <- predict(model, test_matrix)
  
  # Calculate metrics
  mse <- mean((predictions - test_rates)^2)
  rmse <- sqrt(mse)
  mae <- mean(abs(predictions - test_rates))
  
  # Calculate R-squared
  ss_res <- sum((test_rates - predictions)^2)
  ss_tot <- sum((test_rates - mean(test_rates))^2)
  r_squared <- 1 - (ss_res / ss_tot)
  
  # Calculate correlation
  correlation <- cor(predictions, test_rates)
  
  results <- list(
    predictions = predictions,
    mse = mse,
    rmse = rmse,
    mae = mae,
    r_squared = r_squared,
    correlation = correlation
  )
  
  log_message(paste("Regression R²:", round(r_squared, 3)), "INFO")
  log_message(paste("RMSE:", round(rmse, 3)), "INFO")
  
  return(results)
}

#' Get feature importance from model
#' @param model Trained Random Forest model
#' @param n_top Number of top features to return (default: 20)
#' @return Data frame with feature importance
get_feature_importance <- function(model, n_top = 20) {
  if (!inherits(model, "randomForest")) {
    stop("Model must be a Random Forest object")
  }
  
  # Get importance scores
  importance_scores <- importance(model)
  
  # Convert to data frame
  importance_df <- data.frame(
    feature = rownames(importance_scores),
    importance = importance_scores[, 1],
    stringsAsFactors = FALSE
  )
  
  # Sort by importance
  importance_df <- importance_df[order(-importance_df$importance), ]
  
  # Return top features
  return(head(importance_df, n_top))
}

#' Calibrate regression predictions
#' @param predictions Raw predictions
#' @param actual_values Actual values
#' @param bins Number of bins for calibration (default: 20)
#' @return List with calibration results
calibrate_predictions <- function(predictions, actual_values, bins = 20) {
  # Create bins
  bin_edges <- seq(0, 1, length.out = bins + 1)
  bin_centers <- (bin_edges[-1] + bin_edges[-(bins + 1)]) / 2
  
  # Calculate calibration
  calibrated_values <- numeric(length(predictions))
  bin_stats <- data.frame(
    bin_center = bin_centers,
    predicted_mean = numeric(bins),
    actual_mean = numeric(bins),
    count = numeric(bins)
  )
  
  for (i in 1:bins) {
    if (i == bins) {
      # Last bin includes upper bound
      bin_mask <- predictions >= bin_edges[i] & predictions <= bin_edges[i + 1]
    } else {
      bin_mask <- predictions >= bin_edges[i] & predictions < bin_edges[i + 1]
    }
    
    if (sum(bin_mask) > 0) {
      bin_stats$predicted_mean[i] <- mean(predictions[bin_mask])
      bin_stats$actual_mean[i] <- mean(actual_values[bin_mask])
      bin_stats$count[i] <- sum(bin_mask)
      
      # Calibrate predictions in this bin
      calibrated_values[bin_mask] <- bin_stats$actual_mean[i]
    }
  }
  
  # Fit linear model for smooth calibration
  valid_bins <- bin_stats$count > 5
  if (sum(valid_bins) > 1) {
    lm_model <- lm(actual_mean ~ predicted_mean, data = bin_stats[valid_bins, ])
    smooth_calibrated <- predict(lm_model, newdata = data.frame(predicted_mean = predictions))
    
    # Ensure predictions stay in [0, 1] range
    smooth_calibrated <- pmax(0, pmin(1, smooth_calibrated))
  } else {
    smooth_calibrated <- calibrated_values
  }
  
  return(list(
    calibrated = calibrated_values,
    smooth_calibrated = smooth_calibrated,
    bin_stats = bin_stats,
    calibration_model = if (sum(valid_bins) > 1) lm_model else NULL
  ))
}

#' Train ensemble model with multiple algorithms
#' @param deck_matrix Training data matrix
#' @param labels Training labels (for classification) or values (for regression)
#' @param model_type "classification" or "regression"
#' @param algorithms Vector of algorithms to use
#' @return List of trained models
train_ensemble_model <- function(deck_matrix, labels, model_type = "classification", 
                                algorithms = c("rf", "svm", "gbm")) {
  log_message("Training ensemble model", "INFO")
  
  models <- list()
  
  for (algo in algorithms) {
    tryCatch({
      if (algo == "rf") {
        if (model_type == "classification") {
          models[[algo]] <- train_classification_model(deck_matrix, labels)
        } else {
          models[[algo]] <- train_regression_model(deck_matrix, labels)
        }
      } else if (algo == "svm") {
        if (model_type == "classification") {
          models[[algo]] <- svm(deck_matrix, labels, probability = TRUE)
        } else {
          models[[algo]] <- svm(deck_matrix, labels)
        }
      } else if (algo == "gbm") {
        # GBM implementation would go here
        log_message("GBM not yet implemented", "WARNING")
      }
      
      log_message(paste("Trained", algo, "model"), "INFO")
      
    }, error = function(e) {
      log_message(paste("Failed to train", algo, "model:", e$message), "WARNING")
    })
  }
  
  return(models)
}

#' Make ensemble predictions
#' @param models List of trained models
#' @param test_matrix Test data matrix
#' @param model_type "classification" or "regression"
#' @param weights Weights for each model (default: equal weights)
#' @return Ensemble predictions
make_ensemble_predictions <- function(models, test_matrix, model_type = "classification", 
                                    weights = NULL) {
  if (length(models) == 0) {
    stop("No models provided for ensemble prediction")
  }
  
  # Use equal weights if not specified
  if (is.null(weights)) {
    weights <- rep(1/length(models), length(models))
  }
  
  # Get predictions from each model
  predictions_list <- list()
  
  for (i in seq_along(models)) {
    model <- models[[i]]
    algo <- names(models)[i]
    
    tryCatch({
      if (algo == "rf") {
        if (model_type == "classification") {
          pred <- predict(model, test_matrix, type = "prob")[, 2]
        } else {
          pred <- predict(model, test_matrix)
        }
      } else if (algo == "svm") {
        if (model_type == "classification") {
          pred <- attr(predict(model, test_matrix, probability = TRUE), "probabilities")[, 2]
        } else {
          pred <- predict(model, test_matrix)
        }
      }
      
      predictions_list[[i]] <- pred
      
    }, error = function(e) {
      log_message(paste("Failed to get predictions from", algo, "model"), "WARNING")
      predictions_list[[i]] <- NULL
    })
  }
  
  # Remove NULL predictions
  valid_predictions <- !sapply(predictions_list, is.null)
  predictions_list <- predictions_list[valid_predictions]
  weights <- weights[valid_predictions]
  
  if (length(predictions_list) == 0) {
    stop("No valid predictions from any model")
  }
  
  # Calculate weighted average
  ensemble_pred <- Reduce("+", Map("*", predictions_list, weights))
  
  return(ensemble_pred)
}

#' Save trained model
#' @param model Trained model object
#' @param file_path Path to save the model
save_model <- function(model, file_path) {
  ensure_dir_exists(dirname(file_path))
  
  tryCatch({
    saveRDS(model, file_path)
    log_message(paste("Model saved to", file_path), "INFO")
  }, error = function(e) {
    stop("Error saving model: ", e$message)
  })
}

#' Load trained model
#' @param file_path Path to the saved model
#' @return Loaded model object
load_model <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("Model file not found: ", file_path)
  }
  
  tryCatch({
    model <- readRDS(file_path)
    log_message(paste("Model loaded from", file_path), "INFO")
    return(model)
  }, error = function(e) {
    stop("Error loading model: ", e$message)
  })
} 