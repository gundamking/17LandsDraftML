# Contributing to 17Lands Draft ML

Thank you for your interest in contributing to the 17Lands Draft ML project! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch** for your changes
4. **Make your changes** following the guidelines below
5. **Test your changes** thoroughly
6. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- R (version 4.0 or higher)
- RStudio (recommended)
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/17landsdraftml.git
cd 17landsdraftml
```

2. Install dependencies:
```r
source("R/install_dependencies.R")
```

3. Test the installation:
```r
source("R/draft_analysis.R")
# Run a quick test with sample data
```

## Code Style Guidelines

### R Code Style

- Use **snake_case** for variable and function names
- Use **camelCase** for file names
- Add spaces around operators (`+`, `-`, `=`, etc.)
- Use meaningful variable names
- Add comments for complex logic
- Use roxygen2 documentation for functions

### Example

```r
#' Calculate win rate from wins and losses
#' @param wins Number of wins
#' @param losses Number of losses
#' @return Win rate as a proportion
calculate_win_rate <- function(wins, losses) {
  total_games <- wins + losses
  if (total_games == 0) {
    return(NA)
  }
  return(wins / total_games)
}
```

### File Organization

- Keep functions modular and focused
- Use descriptive file names
- Group related functions in the same file
- Follow the existing directory structure

## Testing

### Running Tests

1. **Unit Tests**: Create tests for new functions
2. **Integration Tests**: Test the complete pipeline
3. **Data Validation**: Ensure data processing works correctly

### Test Data

- Use small, synthetic datasets for testing
- Include edge cases and error conditions
- Test with different data formats

## Documentation

### Code Documentation

- Document all public functions with roxygen2
- Include parameter descriptions and return values
- Add examples for complex functions

### User Documentation

- Update README.md for new features
- Add usage examples
- Document any breaking changes

## Pull Request Process

### Before Submitting

1. **Test your changes** thoroughly
2. **Update documentation** as needed
3. **Check code style** consistency
4. **Ensure all tests pass**

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Documentation
- [ ] Code is documented
- [ ] README updated if needed
- [ ] Examples provided

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] No debugging code left
- [ ] Error handling implemented
```

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

1. **Clear description** of the problem
2. **Steps to reproduce** the issue
3. **Expected vs actual behavior**
4. **Environment details** (R version, OS, etc.)
5. **Sample data** if applicable

### Feature Requests

For feature requests, please include:

1. **Clear description** of the feature
2. **Use case** and motivation
3. **Proposed implementation** approach
4. **Impact** on existing functionality

## Code Review Process

### Review Guidelines

- **Functionality**: Does the code work as intended?
- **Performance**: Is the code efficient?
- **Readability**: Is the code clear and well-documented?
- **Testing**: Are there adequate tests?
- **Documentation**: Is the code properly documented?

### Review Checklist

- [ ] Code follows project style guidelines
- [ ] Functions are properly documented
- [ ] Error handling is implemented
- [ ] Tests are included
- [ ] No sensitive data is exposed
- [ ] Performance considerations addressed

## Getting Help

### Questions and Discussion

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check README.md and code comments

### Community Guidelines

- Be respectful and constructive
- Help others learn and contribute
- Share knowledge and best practices
- Follow the project's code of conduct

## Recognition

Contributors will be recognized in:

- **README.md** contributors section
- **GitHub** contributors page
- **Release notes** for significant contributions

Thank you for contributing to 17Lands Draft ML! 