# Visualization Functions for 17Lands Draft ML
# Functions for creating plots and visualizations

# Load required libraries
library(ggplot2)
library(gridExtra)
library(scales)
library(viridis)

# Source utility functions
source("R/utils.R")

#' Create calibration plot for regression model
#' @param predictions Model predictions
#' @param actual_values Actual values
#' @param bins Number of bins for calibration
#' @param title Plot title
#' @return ggplot object
create_calibration_plot <- function(predictions, actual_values, bins = 20, 
                                   title = "Model Calibration") {
  # Create bins
  bin_edges <- seq(0, 1, length.out = bins + 1)
  bin_centers <- (bin_edges[-1] + bin_edges[-(bins + 1)]) / 2
  
  # Calculate bin statistics
  bin_stats <- data.frame(
    bin_center = bin_centers,
    predicted_mean = numeric(bins),
    actual_mean = numeric(bins),
    count = numeric(bins)
  )
  
  for (i in 1:bins) {
    if (i == bins) {
      bin_mask <- predictions >= bin_edges[i] & predictions <= bin_edges[i + 1]
    } else {
      bin_mask <- predictions >= bin_edges[i] & predictions < bin_edges[i + 1]
    }
    
    if (sum(bin_mask) > 0) {
      bin_stats$predicted_mean[i] <- mean(predictions[bin_mask])
      bin_stats$actual_mean[i] <- mean(actual_values[bin_mask])
      bin_stats$count[i] <- sum(bin_mask)
    }
  }
  
  # Filter bins with sufficient data
  valid_bins <- bin_stats$count > 5
  
  # Create plot
  p <- ggplot(bin_stats[valid_bins, ], aes(x = predicted_mean, y = actual_mean)) +
    geom_point(aes(size = count), alpha = 0.7, color = "steelblue") +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", alpha = 0.7) +
    scale_size_continuous(range = c(2, 8), name = "Sample Size") +
    labs(
      title = title,
      x = "Predicted Win Rate",
      y = "Actual Win Rate"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      legend.position = "bottom"
    ) +
    coord_fixed(ratio = 1, xlim = c(0, 1), ylim = c(0, 1))
  
  return(p)
}

#' Create feature importance plot
#' @param importance_df Data frame with feature importance
#' @param n_top Number of top features to show
#' @param title Plot title
#' @return ggplot object
create_importance_plot <- function(importance_df, n_top = 20, 
                                 title = "Feature Importance") {
  # Get top features
  top_features <- head(importance_df, n_top)
  
  # Create plot
  p <- ggplot(top_features, aes(x = reorder(feature, importance), y = importance)) +
    geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
    coord_flip() +
    labs(
      title = title,
      x = "Feature",
      y = "Importance Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      axis.text.y = element_text(size = 9)
    )
  
  return(p)
}

#' Create win rate distribution plot
#' @param win_rates Vector of win rates
#' @param title Plot title
#' @return ggplot object
create_win_rate_distribution <- function(win_rates, title = "Win Rate Distribution") {
  p <- ggplot(data.frame(win_rate = win_rates), aes(x = win_rate)) +
    geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7, color = "white") +
    geom_vline(xintercept = mean(win_rates), color = "red", linetype = "dashed", size = 1) +
    labs(
      title = title,
      x = "Win Rate",
      y = "Frequency"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  return(p)
}

#' Create prediction vs actual plot
#' @param predictions Model predictions
#' @param actual_values Actual values
#' @param title Plot title
#' @return ggplot object
create_prediction_plot <- function(predictions, actual_values, 
                                 title = "Predicted vs Actual Win Rates") {
  # Create data frame
  plot_data <- data.frame(
    predicted = predictions,
    actual = actual_values
  )
  
  # Calculate correlation
  correlation <- cor(predictions, actual_values)
  
  p <- ggplot(plot_data, aes(x = predicted, y = actual)) +
    geom_point(alpha = 0.6, color = "steelblue") +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", alpha = 0.7) +
    labs(
      title = paste0(title, " (r = ", round(correlation, 3), ")"),
      x = "Predicted Win Rate",
      y = "Actual Win Rate"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    coord_fixed(ratio = 1)
  
  return(p)
}

#' Create ROC curve plot
#' @param predictions Model predictions (probabilities)
#' @param actual_labels Actual binary labels
#' @param title Plot title
#' @return ggplot object
create_roc_plot <- function(predictions, actual_labels, title = "ROC Curve") {
  # Calculate ROC
  roc_obj <- roc(actual_labels, predictions)
  auc_value <- auc(roc_obj)
  
  # Create data frame for plotting
  roc_data <- data.frame(
    sensitivity = roc_obj$sensitivities,
    specificity = roc_obj$specificities
  )
  
  p <- ggplot(roc_data, aes(x = 1 - specificity, y = sensitivity)) +
    geom_line(color = "steelblue", size = 1) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", alpha = 0.7) +
    labs(
      title = paste0(title, " (AUC = ", round(auc_value, 3), ")"),
      x = "1 - Specificity (False Positive Rate)",
      y = "Sensitivity (True Positive Rate)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    coord_fixed(ratio = 1)
  
  return(p)
}

#' Create confusion matrix heatmap
#' @param confusion_matrix Confusion matrix object
#' @param title Plot title
#' @return ggplot object
create_confusion_heatmap <- function(confusion_matrix, title = "Confusion Matrix") {
  # Extract confusion matrix data
  cm_data <- as.data.frame(confusion_matrix$table)
  colnames(cm_data) <- c("Predicted", "Actual", "Count")
  
  # Calculate percentages
  cm_data$Percentage <- cm_data$Count / sum(cm_data$Count) * 100
  
  p <- ggplot(cm_data, aes(x = Predicted, y = Actual, fill = Count)) +
    geom_tile() +
    geom_text(aes(label = sprintf("%d\n(%.1f%%)", Count, Percentage)), 
              color = "white", size = 4) +
    scale_fill_viridis(name = "Count") +
    labs(
      title = title,
      x = "Predicted",
      y = "Actual"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      legend.position = "none"
    )
  
  return(p)
}

#' Create model performance summary plot
#' @param results List with model evaluation results
#' @param title Plot title
#' @return ggplot object
create_performance_summary <- function(results, title = "Model Performance Summary") {
  # Extract metrics
  metrics <- data.frame(
    Metric = c("Accuracy", "Sensitivity", "Specificity", "AUC"),
    Value = c(
      results$accuracy,
      results$sensitivity,
      results$specificity,
      results$auc
    )
  )
  
  p <- ggplot(metrics, aes(x = Metric, y = Value)) +
    geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
    geom_text(aes(label = sprintf("%.3f", Value)), 
              vjust = -0.5, size = 4, color = "black") +
    labs(
      title = title,
      x = "Metric",
      y = "Value"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    ylim(0, max(metrics$Value) * 1.1)
  
  return(p)
}

#' Create comprehensive model evaluation dashboard
#' @param model_results List with model evaluation results
#' @param predictions Model predictions
#' @param actual_values Actual values
#' @param importance_df Feature importance data frame
#' @param output_dir Output directory for saving plots
#' @param prefix File name prefix
#' @return List of created plots
create_evaluation_dashboard <- function(model_results, predictions, actual_values, 
                                      importance_df, output_dir = "output", 
                                      prefix = "model_evaluation") {
  log_message("Creating evaluation dashboard", "INFO")
  
  plots <- list()
  
  # 1. Calibration plot
  plots$calibration <- create_calibration_plot(predictions, actual_values)
  save_plot(plots$calibration, file.path(output_dir, paste0(prefix, "_calibration.png")))
  
  # 2. Prediction vs actual plot
  plots$prediction <- create_prediction_plot(predictions, actual_values)
  save_plot(plots$prediction, file.path(output_dir, paste0(prefix, "_predictions.png")))
  
  # 3. Feature importance plot
  if (!is.null(importance_df) && nrow(importance_df) > 0) {
    plots$importance <- create_importance_plot(importance_df)
    save_plot(plots$importance, file.path(output_dir, paste0(prefix, "_importance.png")))
  }
  
  # 4. Win rate distribution
  plots$distribution <- create_win_rate_distribution(actual_values)
  save_plot(plots$distribution, file.path(output_dir, paste0(prefix, "_distribution.png")))
  
  # 5. Performance summary (if classification)
  if ("accuracy" %in% names(model_results)) {
    plots$performance <- create_performance_summary(model_results)
    save_plot(plots$performance, file.path(output_dir, paste0(prefix, "_performance.png")))
  }
  
  # 6. Confusion matrix (if classification)
  if ("confusion_matrix" %in% names(model_results)) {
    plots$confusion <- create_confusion_heatmap(model_results$confusion_matrix)
    save_plot(plots$confusion, file.path(output_dir, paste0(prefix, "_confusion.png")))
  }
  
  # 7. ROC curve (if classification)
  if ("predictions" %in% names(model_results) && length(unique(actual_values)) == 2) {
    # Convert to binary for ROC
    binary_actual <- as.factor(ifelse(actual_values > 0.5, "High", "Low"))
    plots$roc <- create_roc_plot(model_results$predictions[, 2], binary_actual)
    save_plot(plots$roc, file.path(output_dir, paste0(prefix, "_roc.png")))
  }
  
  log_message("Evaluation dashboard created successfully", "INFO")
  return(plots)
}

#' Create data exploration plots
#' @param deck_data Processed deck data
#' @param output_dir Output directory
#' @param prefix File name prefix
#' @return List of exploration plots
create_data_exploration_plots <- function(deck_data, output_dir = "output", 
                                        prefix = "data_exploration") {
  log_message("Creating data exploration plots", "INFO")
  
  plots <- list()
  
  # 1. Win rate distribution
  plots$win_rate_dist <- create_win_rate_distribution(
    deck_data$win_rates, 
    "Win Rate Distribution"
  )
  save_plot(plots$win_rate_dist, file.path(output_dir, paste0(prefix, "_win_rates.png")))
  
  # 2. Deck size distribution
  deck_sizes <- rowSums(deck_data$deck_matrix > 0)
  deck_size_data <- data.frame(size = deck_sizes)
  
  plots$deck_size_dist <- ggplot(deck_size_data, aes(x = size)) +
    geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7, color = "white") +
    labs(
      title = "Deck Size Distribution",
      x = "Number of Unique Cards",
      y = "Frequency"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  save_plot(plots$deck_size_dist, file.path(output_dir, paste0(prefix, "_deck_sizes.png")))
  
  # 3. Card frequency heatmap (top cards)
  card_frequencies <- colSums(deck_data$deck_matrix > 0)
  top_cards <- head(sort(card_frequencies, decreasing = TRUE), 20)
  
  top_cards_data <- data.frame(
    card = names(top_cards),
    frequency = as.numeric(top_cards)
  )
  
  plots$card_frequency <- ggplot(top_cards_data, aes(x = reorder(card, frequency), y = frequency)) +
    geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
    coord_flip() +
    labs(
      title = "Most Common Cards",
      x = "Card",
      y = "Frequency"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      axis.text.y = element_text(size = 9)
    )
  
  save_plot(plots$card_frequency, file.path(output_dir, paste0(prefix, "_card_frequency.png")))
  
  log_message("Data exploration plots created successfully", "INFO")
  return(plots)
}

#' Save all plots to files
#' @param plots List of ggplot objects
#' @param output_dir Output directory
#' @param prefix File name prefix
#' @param format Output format (png, pdf, svg)
save_all_plots <- function(plots, output_dir = "output", prefix = "plot", format = "png") {
  ensure_dir_exists(output_dir)
  
  for (i in seq_along(plots)) {
    plot_name <- names(plots)[i]
    filename <- file.path(output_dir, paste0(prefix, "_", plot_name, ".", format))
    
    save_plot(plots[[i]], filename)
  }
  
  log_message(paste("Saved", length(plots), "plots to", output_dir), "INFO")
} 