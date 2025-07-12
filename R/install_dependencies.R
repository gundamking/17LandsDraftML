# Install Dependencies for 17Lands Draft ML
# This script installs all required R packages for the project

# List of required packages
required_packages <- c(
  "randomForest",    # Random Forest models
  "pROC",           # ROC analysis and AUC calculation
  "ggplot2",        # Advanced plotting
  "dplyr",          # Data manipulation
  "tidyr",          # Data tidying
  "readr",          # Fast CSV reading
  "caret",          # Machine learning utilities
  "rpart",          # Decision trees
  "e1071",          # SVM and other ML algorithms
  "ROCR",           # Performance evaluation
  "gridExtra",      # Plot arrangement
  "scales",         # Scale functions for plots
  "viridis",        # Color palettes
  "knitr",          # Report generation
  "rmarkdown"       # R Markdown support
)

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE, quietly = TRUE)) {
      cat("Installing", package, "...\n")
      install.packages(package, dependencies = TRUE)
    } else {
      cat(package, "is already installed.\n")
    }
  }
}

# Install packages
cat("Installing required packages for 17Lands Draft ML...\n")
install_if_missing(required_packages)

# Load essential packages
cat("Loading essential packages...\n")
library(randomForest)
library(pROC)
library(ggplot2)
library(dplyr)
library(readr)

cat("All dependencies installed and loaded successfully!\n") 