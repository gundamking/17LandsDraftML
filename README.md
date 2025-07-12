# 17Lands Draft ML

A professional machine learning project for analyzing Magic: The Gathering draft data from 17Lands to predict deck performance and optimize draft strategies.

## 🎯 Overview

This project uses advanced machine learning techniques to analyze MTG draft data and predict deck win rates. The analysis focuses on:

- **Deck Composition Analysis**: Understanding how card combinations affect win rates
- **Win Rate Prediction**: Using Random Forest models to predict deck performance
- **Player Skill Integration**: Incorporating player skill metrics into predictions
- **Data Visualization**: Creating insightful plots for model validation
- **Feature Importance**: Identifying which cards most influence outcomes

## ✨ Features

- **Robust Data Processing**: Handles various data formats and edge cases with comprehensive error handling
- **Multiple Model Types**: Classification and regression models for different prediction tasks
- **Model Validation**: Comprehensive evaluation with calibration plots and performance metrics
- **Modular Design**: Separate functions for data processing, modeling, and visualization
- **Professional Structure**: Well-organized codebase with proper documentation and testing
- **Easy Setup**: One-command initialization and dependency management
- **Prediction Pipeline**: Save and load trained models for new deck predictions
- **Card Impact Analysis**: Analyze how specific cards affect win rates

## 🚀 Quick Start

### Prerequisites

- R (version 4.0 or higher)
- RStudio (recommended)

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/yourusername/17landsdraftml.git
cd 17landsdraftml
```

2. **Initialize the project**:
```r
source("setup.R")
```

3. **Place your 17Lands data file** in the `data/` directory

4. **Run analysis**:
```r
source("R/draft_analysis.R")
results <- run_draft_analysis("data/your_file.csv")
```

## 📊 Usage Examples

### Basic Analysis
```r
# Quick analysis with default settings
results <- quick_analysis("data/draft_data.csv")

# View results
cat("AUC:", round(results$evaluation$classification$auc, 3), "\n")
cat("R²:", round(results$evaluation$regression$r_squared, 3), "\n")
```

### Custom Analysis
```r
# Run with custom settings
results <- run_draft_analysis(
  data_file = "data/draft_data.csv",
  output_dir = "output/custom",
  test_proportion = 0.3,
  seed = 123,
  save_models = TRUE,
  create_plots = TRUE
)
```

### Making Predictions
```r
# Load trained model
model <- load_model("output/regression_model.rds")

# Predict win rate for new deck
prediction <- predict_deck_performance(model, new_deck_matrix)
cat("Predicted win rate:", round(prediction, 3), "\n")
```

### Card Impact Analysis
```r
# Analyze specific cards
impact_results <- analyze_card_impact(
  model, 
  base_deck_matrix, 
  c("Lightning Bolt", "Counterspell", "Black Lotus")
)
```

## 📁 Project Structure

```
17landsdraftml/
├── R/                          # Core R scripts
│   ├── install_dependencies.R  # Package installation
│   ├── utils.R                 # Utility functions
│   ├── data_processing.R       # Data cleaning & preparation
│   ├── modeling.R              # ML model functions
│   ├── visualization.R         # Plotting & visualization
│   └── draft_analysis.R        # Main analysis pipeline
├── data/                       # Data files (not tracked)
├── output/                     # Generated results
├── docs/                       # Documentation
├── tests/                      # Unit tests
├── examples/                   # Usage examples
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
├── CHANGELOG.md               # Version history
├── LICENSE                     # MIT license
└── setup.R                     # Project initialization
```

## 📋 Data Format

The analysis expects 17Lands draft data in CSV format with the following key columns:

- `draft_id`: Unique identifier for each draft
- `pick`: Card name for each pick
- `pick_maindeck_rate`: Rate at which the card was included in the main deck
- `event_match_wins`: Number of match wins
- `event_match_losses`: Number of match losses
- `user_game_win_rate_bucket`: Player skill metric
- `user_n_games_bucket`: Player experience metric
- Pool columns: Binary indicators for each card in the format `pool_[cardname]`

## 📈 Model Performance

The current model achieves:
- **Classification AUC**: ~0.65-0.70 for win rate classification
- **Regression R²**: ~0.25-0.30 for win rate regression
- **Calibration**: Good calibration after post-processing
- **Feature Importance**: Identifies most influential cards
- **Robustness**: Handles missing data and edge cases gracefully

## 🛠️ Development

### Running Tests
```r
source("tests/test_basic_functions.R")
```

### Code Style
- Use **snake_case** for variables and functions
- Document all functions with roxygen2
- Follow the existing modular structure
- Add comprehensive error handling

### Contributing
See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for detailed guidelines.

## 📚 Documentation

- **Setup Guide**: Run `source("setup.R")` for initialization
- **API Reference**: All functions are documented with examples
- **Examples**: See `examples/basic_analysis.R` for usage patterns
- **Contributing**: See `docs/CONTRIBUTING.md` for development guidelines

## 🔧 Configuration

### Custom Settings
```r
# Modify analysis parameters
results <- run_draft_analysis(
  data_file = "data/your_file.csv",
  output_dir = "output/custom",
  test_proportion = 0.25,    # 25% for testing
  seed = 42,                 # Reproducible results
  save_models = TRUE,        # Save trained models
  create_plots = TRUE        # Generate visualizations
)
```

### Output Files
- `classification_model.rds`: Trained classification model
- `regression_model.rds`: Trained regression model
- `*_importance.csv`: Feature importance rankings
- `analysis_report.txt`: Summary report
- Various PNG plots for model evaluation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [17Lands](https://17lands.com/) for providing the draft data
- The MTG community for feedback and testing
- Contributors to the R ecosystem for the excellent machine learning packages

## 📞 Contact

For questions or suggestions, please open an issue on GitHub or contact the maintainers.

---

**Note**: This project is for educational and research purposes. Always respect the terms of service of data providers and ensure responsible use of the analysis results.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes and improvements.
