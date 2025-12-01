# Recession Detection Using Classifiers on the Anticipation-Precision Frontier - Code and Data

This repository contains the code and data accompanying the paper "Recession Detection Using Classifiers on the Anticipation-Precision Frontier", written by [Pascal Michaillat](https://pascalmichaillat.org), and posted on [arXiv](https://doi.org/10.48550/arXiv.2506.09664) in July 2025.

## Paper webpage

The paper is available at https://pascalmichaillat.org/17/.

## Overview

This project implements a machine learning approach to real-time recession detection using US labor market indicators. The methodology:

1. Constructs 95,832 recession indicators by systematically transforming unemployment and vacancy data through smoothing, curvature adjustment, turning point detection, and mixing operations
2. Identifies "perfect classifiers" that detect the correct number of recessions in a training period (1929–2021)
3. Selects optimal classifiers on the anticipation-precision frontier
4. Builds a high-precision ensemble from frontier classifiers
5. Computes recession probabilities using the ensemble's error distribution
6. Validates the approach through placebo tests and multiple backtests (1965–2015)

The approach balances early recession detection (anticipation) with consistent timing (precision), providing probabilistic assessments suitable for real-time economic monitoring.

## Input data

The raw data used by the code to produce the results in the paper are stored as CSV files in the `input` folder.

+ `20210719_cycle_dates_pasted.csv` - US business cycle dates, 1857–2021
	+ Source: [NBER (2023)](https://www.nber.org/research/data/us-business-cycle-expansions-and-contractions)
+ `CLF16OV.csv` - US labor force level, 1948–2025
	+ Source: [BLS (2025a)](https://fred.stlouisfed.org/series/CLF16OV)
+ `CompositeHWI.xlsx - Sheet1.csv` - US vacancy rate, 1951–2020
	+ Source: [Barnichon (2010)](https://docs.google.com/spreadsheets/d/1fkMinSHkjTL99-bLZYFldQ8rHtgh8lxd)
+ `HistoricalSeries_JME_2020January.csv` - US unemployment and vacancy rates, 1890–2017
	+ Source: [Petrosky-Nadeau and Zhang (2021)](https://drive.google.com/file/d/1NcuUMRR4_fOwJW6qHb-XxitVSXXONBHW)
+ `INDPRO.csv` - US industrial production index, 1919–2025
	+ Source: [Federal Reserve Board (2025)](https://fred.stlouisfed.org/series/INDPRO)
+ `JTSJOL.csv` - US vacancy level, 2001–2025
	+ Source: [BLS (2025b)](https://fred.stlouisfed.org/series/JTSJOL)
+ `UNEMPLOY.csv` - US unemployment level, 1948–2025
	+ Source: [BLS (2025c)](https://fred.stlouisfed.org/series/UNEMPLOY)

## Code

The results in the paper are obtained using MATLAB. The MATLAB code is located in the `code` folder.

### Main script

The main script, `main.m`, orchestrates the production of the results in the paper. The script:

1. Loads and processes raw labor market data (1929–2025)
2. Constructs 95,832 recession indicators through systematic transformations
3. Identifies perfect classifiers on the training set (1929–2021)
4. Selects classifiers on the anticipation-precision frontier
5. Builds a high-precision ensemble
6. Computes recession probabilities
7. Performs placebo tests using First Ladies' death dates
8. Conducts backtests for 6 different training periods

### Runtime

The complete script takes approximately 6–8 hours to run due to the computational intensity of the classifier selection process. Intermediate results are saved to allow partial execution.

### Key functions

#### Data loading functions

- `getUnemployment.m` - Loads and splices historical unemployment data (1890–2025)
- `getVacancy.m` - Loads and splices historical vacancy data (1919–2025)
- `getNber.m`  - Load and process NBER recession dates

#### Indicator construction functions

- `buildIndicator.m` - Constructs 4,356 indicators from a single time series through:
  - Smoothing: 22 methods (SMA windows 0–11 months, EMA weights 0.1–1.0)
  - Curvature: 11 Box-Cox-like transformations (0 = log, 1 = linear)
  - Turning point detection: 18 detection windows (1–18 months)
  - Total basic indicators: 22 (smoothing)  × 11 (curving) × 18 (turning)  = 4,356
- `mixIndicator.m` - Combines unemployment and vacancy indicators using linear and minmax mixing (11 mixing weights × 2 methods)
- Total indicators: 4,356 (basic indicators) × 22 (mixing) = 95,832

#### Classifier selection functions

- `selectPerfectClassifier.m` - Identifies indicator-threshold combinations that detect exactly the correct number of recessions in the training period (computationally intensive: ~2 hours per training period)
- `selectFrontierClassifier.m` - Constructs the anticipation-precision Pareto frontier by selecting classifiers that minimize mean anticipation for each precision level

#### Analysis functions

- `computeRecessionProbability.m` - Calculates recession probabilities using ensemble classifiers and their error distributions

#### Tabulating and plotting functions

- `tabulateEnsemble.m` - Creates tables of ensemble parameters and performance metrics
- `plotData.m` - Plots raw unemployment and vacancy rates
- `plotIndicator.m` - Visualizes all indicator variations
- `plotFrontier.m` - Shows anticipation-precision frontier
- `plotEnsemble.m` - Displays ensemble classifiers and thresholds
- `plotProbability.m` - Plots individual and aggregate recession probabilities

#### Utility functions

- `flatten.m` - Reshapes multidimensional arrays efficiently
- `formatFigure.m` - Configures default figure properties and defines plotting styles

### Function documentation

All functions include comprehensive header documentation following MATLAB best practices:
- Syntax with all input/output arguments
- Detailed description of functionality
- Parameter specifications with units and ranges
- Usage examples
- Notes on computational requirements or special cases

## Intermediate data

Some intermediate results produced by the code are saved as MATLAB files (`.mat`) in the `intermediate` folder. These results take significant time to produce (1–2 hours per file) and are provided for reference.

### List of intermediate data

- `ensemble.mat` - Perfect classifiers for main analysis (training: 1929–2021)
- `ensemble_2015.mat` - Perfect classifiers for 2015 backtest
- `ensemble_2005.mat` - Perfect classifiers for 2005 backtest
- `ensemble_1995.mat` - Perfect classifiers for 1995 backtest
- `ensemble_1985.mat` - Perfect classifiers for 1985 backtest
- `ensemble_1975.mat` - Perfect classifiers for 1975 backtest - Too large for GitHub (112MB) so only available upon request
- `ensemble_1965.mat` - Perfect classifiers for 1965 backtest

### Content of each matrix

- `indexPerfect` - Column indices of perfect classifiers in the indicator matrix
- `thresholdPerfect` - Optimal thresholds for each perfect classifier
- `startPerfect` - Detected recession start dates for each classifier

### Usage of intermediate data

To skip the computationally intensive classifier selection step, comment the `selectPerfectClassifier()` and `save()` lines, and uncomment the appropriate `load()` line in `main.m`. This allows you to skip the selection of perfect classifiers and start analysis from the frontier selection stage. This step can also be skipped in each backtest.

## Output data

The results produced by the code from the raw data are stored as PDF and CSV files in the `output` folder.

### Figures

All figures are saved in two formats:
- PDF files - High-quality vector graphics for publication
- CSV files - Underlying data for replication or further analysis

#### Main analysis figures

- `figure_data.pdf` - Raw unemployment and vacancy rates (1929–2025)
- `figure_unemployment.pdf` - All 4,356 unemployment indicator variations
- `figure_vacancy.pdf` - All 4,356 vacancy indicator variations
- `figure_frontier.pdf` - Anticipation-precision frontier with all perfect classifiers
- `figure_frontier_precision.pdf` - Zoomed view of high-precision segment of frontier
- `figure_ensemble_[1-N].pdf` - Individual ensemble classifier plots
- `figure_ensemble.pdf` - Combined plot of normalized ensemble classifiers
- `figure_probability_training.pdf` - Recession probabilities on training period
- `figure_probability_testing.pdf` - Recession probabilities on testing period

#### Placebo test figures

- `figure_frontier_placebo.pdf` - Anticipation-precision frontier using First Ladies' death dates for placebo test

#### Backtest figures

For each backtest year (2015, 2005, 1995, 1985, 1975, 965):

- `figure_frontier_[year].pdf` - Frontier for that training period
- `figure_frontier_[year]_precision.pdf` - Zoomed frontier view
- `figure_ensemble_[year]_[1-N].pdf` - Individual classifiers
- `figure_ensemble_[year].pdf` - Combined ensemble
- `figure_probability_[year]_training.pdf` - Recession probabilities on training period
- `figure_probability_[year]_testing.pdf` - Recession probabilities on backtesting period

### Tables

All tables are saved as CSV files with complete parameter specifications and performance metrics.

### Main analysis tables

- `table_ensemble.csv` - Ensemble classifier parameters and errors. Columns: Smoothing method, smoothing parameter, curving parameter, turning parameter, mixing method, mixing parameter, threshold, standard error, mean error, min error, max error

### Placebo test tables

- `table_ensemble_placebo.csv` - Top 10 placebo classifiers

### Backtest tables

 For each backtest year:

- `table_ensemble_[year].csv` - Ensemble parameters for that training period

## Usage

### Prerequisites

- MATLAB R2019b or later (some functions require recent MATLAB features)
- Sufficient memory for large matrix operations (16GB+ RAM recommended)
- Approximately 10GB free disk space for intermediate and output files

### Running the analysis

1. Clone the repository to your local machine using Git or by downloading the ZIP file:
```bash
git clone https://github.com/pmichaillat/recession-detection.git
```

2. Open MATLAB and set the `code` folder as the current folder.

3. To generate all the results, run the following command in the MATLAB command window:

```matlab
run('main.m')
```

4. By default, the main script overwrites the files in the `intermediate` and `output` folders. To preserve existing files, make a copy of the folders before running the script.

5. Important note: The script takes 6–8 hours to run completely due to classifier selection. Progress is displayed in the command window.

### Partial execution

To skip the computationally intensive selection of perfect classifiers, use pre-computed results:

1. Ensure intermediate `.mat` files exist in `intermediate/`.

2. In `main.m`, comment the `selectPerfectClassifier()` and `save()` lines, and uncomment the appropriate `load()` line in `main.m`. This allows you to skip the selection of perfect classifiers and start analysis from the frontier selection stage. This step can also be skipped in each backtest.

3. Run the `main.m` script. It will use saved classifiers instead of recomputing them.

### Customization

#### Modify training period

- Edit `beginTraining` and `endTraining` in `main.m`

#### Adjust ensemble precision threshold

- Modify `stdErrorMax` in `main.m`
- Lower values = more precise but fewer classifiers
- Higher values = more classifiers but less precise

#### Change backtest periods

- Edit the backtest year array in `main.m`
- Add or remove years as desired

#### Customize figure formatting

- Modify properties in `formatFigure.m`
- Adjust colors, line widths, fonts, etc.

## Software

The results were obtained using MATLAB R2024b on macOS Tahoe (Apple silicon). The code should work on:
- MATLAB R2019b or later
- Windows, macOS, or Linux
- Both Intel and Apple silicon processors
- No required toolboxes. All code uses base MATLAB functions.

## Citation

If you use this code or data in your research, please cite:

```latex
@techreport{Michaillat2025,
  author = {Pascal Michaillat},
  title = {Recession Detection Using Classifiers on the Anticipation-Precision Frontier},
  year = {2025},
  number = {arXiv:2506.09664},
  url = {https://doi.org/10.48550/arXiv.2506.09664}
}
```

## License

This repository is licensed under the [MIT License](LICENSE.md).
