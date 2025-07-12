# Output Directory

This directory contains analysis results and generated files.

## Generated Files

### Models
- `classification_model.rds`: Trained classification model
- `regression_model.rds`: Trained regression model

### Feature Importance
- `classification_importance.csv`: Feature importance for classification
- `regression_importance.csv`: Feature importance for regression

### Reports
- `analysis_report.txt`: Summary report of the analysis
- `processed_decks.csv`: Processed deck compositions
- `processed_win_rates.csv`: Processed win rates
- `processed_metadata.txt`: Processing metadata

### Visualizations
- `data_exploration_*.png`: Data exploration plots
- `classification_*.png`: Classification model evaluation plots
- `regression_*.png`: Regression model evaluation plots
- `model_evaluation_*.png`: Model performance plots

## Usage

After running the analysis, you can:

1. **Load trained models** for predictions:
   ```r
   model <- load_model("output/regression_model.rds")
   ```

2. **View feature importance** to understand card impact:
   ```r
   importance <- read.csv("output/regression_importance.csv")
   ```

3. **Examine plots** for model validation:
   - Calibration plots show prediction accuracy
   - ROC curves show classification performance
   - Feature importance plots show card rankings

4. **Use the analysis report** for insights:
   ```r
   report <- readLines("output/analysis_report.txt")
   ```

## File Descriptions

### Model Files (.rds)
- Binary R objects containing trained models
- Use `load_model()` function to load them
- Can be used for predictions on new data

### CSV Files
- **Importance files**: Card rankings by influence on win rate
- **Processed data**: Cleaned and formatted data used for training

### PNG Files
- **Calibration plots**: Show how well predictions match actual outcomes
- **ROC curves**: Classification model performance across thresholds
- **Feature importance**: Bar charts of most influential cards
- **Data exploration**: Win rate distributions, deck sizes, etc.

### Text Files
- **Analysis report**: Comprehensive summary of results
- **Metadata**: Information about data processing and model training

## Notes

- Files are automatically generated during analysis
- Large datasets may produce many output files
- Plots are high-resolution PNG format suitable for presentations
- Models can be shared and reused across different analyses 