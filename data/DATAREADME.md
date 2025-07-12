# Data Directory

Place your 17Lands draft data files in this directory.

## Expected File Format

The analysis expects CSV files with the following columns:

- `draft_id`: Unique identifier for each draft
- `pick`: Card name for each pick
- `pick_maindeck_rate`: Rate at which the card was included in the main deck
- `event_match_wins`: Number of match wins
- `event_match_losses`: Number of match losses
- `user_game_win_rate_bucket`: Player skill metric
- `user_n_games_bucket`: Player experience metric
- Pool columns: Binary indicators for each card in the format `pool_[cardname]`

## Example Usage

1. Download your draft data from 17Lands
2. Place the CSV file in this directory
3. Run the analysis: `source('R/draft_analysis.R')`
4. Check the `output/` directory for results

## File Naming

Use descriptive names for your data files, for example:
- `draft_data_public.SNC.PremierDraft.csv`
- `draft_data_public.NEO.PremierDraft.csv`
- `my_draft_data.csv`

## Data Sources

- [17Lands](https://17lands.com/) - Public draft data
- Your own draft data exports
- Community-contributed datasets

## Notes

- Large files (>100MB) may take longer to process
- Ensure your data is in UTF-8 encoding
- The analysis will automatically handle missing values 