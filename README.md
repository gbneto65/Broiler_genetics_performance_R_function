# Broiler_genetics_performance_R_function

# Broiler Performance Standards in R

An R function for retrieving and interpolating broiler performance objectives for **Ross 308** (2022) and **Cobb 500** (2022) birds from day 0 through day 56.

The function supports three sex categories and four performance parameters. It can return values for whole-number ages or estimate values for fractional ages using linear interpolation.

## Files

Recommended project structure:

```text
broiler-performance-standards/
├── broiler_std.R
└── README.md
```

- `broiler_std.R`: contains the `broiler_std()` function and the Ross308 and Cobb500 performance vectors.
- `README.md`: explains how to load and use the function.

## Requirements

- R version 4.0 or later is recommended.
- No external R packages are required.

The function uses only base R.

## Load the function

Save the complete function as `broiler_std.R`, set the R working directory to the project folder, and run:

```r
source("broiler_std.R")
```

Confirm that the function is available:

```r
exists("broiler_std")
# Expected: TRUE
```

## Function syntax

```r
broiler_std(
  age,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "bw"
)
```

## Arguments

### `age`

A single numeric age in days.

- Minimum: `0`
- Maximum: `56`
- Whole-number ages return the corresponding table value.
- Decimal ages are estimated by linear interpolation.

Examples:

```r
age = 35
age = 35.5
```

### `genetic`

One of:

```r
"Ross308"
"Cobb500"
```

Values are case-sensitive. For example, `"Cobb500"` is valid, but `"cobb500"` is not.

### `sex`

One of:

```r
"as_hatched"
"female"
"male"
```

### `parameter`

One of:

```r
"bw"
"daily_feed_intake"
"cum_feed_intake"
"fcr"
```

| Parameter | Meaning | Unit |
|---|---|---|
| `bw` | Body weight | g/bird |
| `daily_feed_intake` | Daily feed intake | g/bird/day |
| `cum_feed_intake` | Cumulative feed intake | g/bird |
| `fcr` | Cumulative feed conversion ratio | g feed/g body weight |

## Output

The function returns one numeric value.

```r
result <- broiler_std(
  age = 35,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "bw"
)

class(result)
# Expected: "numeric"

print(result)
```

The function returns `NA` when the selected source table does not report the requested value. This is particularly relevant for early Cobb500 feed-intake and FCR observations.

## Basic examples

### Ross308 as-hatched body weight at day 35

```r
broiler_std(
  age = 35,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "bw"
)
```

### Ross308 female cumulative feed intake at day 35

```r
broiler_std(
  age = 35,
  genetic = "Ross308",
  sex = "female",
  parameter = "cum_feed_intake"
)
```

### Cobb500 male daily feed intake at day 42

```r
broiler_std(
  age = 42,
  genetic = "Cobb500",
  sex = "male",
  parameter = "daily_feed_intake"
)
```

### Cobb500 female FCR at day 28

```r
broiler_std(
  age = 28,
  genetic = "Cobb500",
  sex = "female",
  parameter = "fcr"
)
```

## Fractional ages and interpolation

For a fractional age, the function performs linear interpolation between consecutive daily values.

For example, Cobb500 female body weight is 276 g at day 9 and 320 g at day 10. At day 9.5, the estimate is:

```text
276 + (320 - 276) x 0.5 = 298 g
```

Run:

```r
broiler_std(
  age = 9.5,
  genetic = "Cobb500",
  sex = "female",
  parameter = "bw"
)
# Expected: 298
```

Interpolation is not performed when either adjacent table value is missing. In that situation, the function returns `NA_real_`.

## Store and reuse a result

```r
standard_bw_42 <- broiler_std(
  age = 42,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "bw"
)

print(standard_bw_42)
```

## Compare actual flock performance with the standard

### Body-weight difference

```r
actual_bw <- 3150

standard_bw <- broiler_std(
  age = 42,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "bw"
)

bw_difference_g <- actual_bw - standard_bw
bw_difference_pct <- 100 * bw_difference_g / standard_bw

bw_difference_g
bw_difference_pct
```

Interpretation:

- A positive difference means actual body weight is above the selected standard.
- A negative difference means actual body weight is below the selected standard.
- The comparison is descriptive and does not by itself establish statistical significance.

### Cumulative-feed difference

```r
actual_cum_feed <- 5050

standard_cum_feed <- broiler_std(
  age = 42,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "cum_feed_intake"
)

feed_difference_g <- actual_cum_feed - standard_cum_feed
feed_difference_pct <- 100 * feed_difference_g / standard_cum_feed

feed_difference_g
feed_difference_pct
```

## Compare Ross308 and Cobb500

```r
ross_bw_42 <- broiler_std(
  age = 42,
  genetic = "Ross308",
  sex = "as_hatched",
  parameter = "bw"
)

cobb_bw_42 <- broiler_std(
  age = 42,
  genetic = "Cobb500",
  sex = "as_hatched",
  parameter = "bw"
)

comparison <- data.frame(
  genetic = c("Ross308", "Cobb500"),
  age = c(42, 42),
  sex = c("as_hatched", "as_hatched"),
  body_weight_g = c(ross_bw_42, cobb_bw_42)
)

print(comparison)
```

Genetic standards should be treated as separate reference objectives. A numerical difference between the two standards is not evidence that one genetic is superior under every production system.

## Generate a complete performance curve

### Base R example

```r
ages <- 0:56

ross_bw <- sapply(
  ages,
  function(x) {
    broiler_std(
      age = x,
      genetic = "Ross308",
      sex = "as_hatched",
      parameter = "bw"
    )
  }
)

cobb_bw <- sapply(
  ages,
  function(x) {
    broiler_std(
      age = x,
      genetic = "Cobb500",
      sex = "as_hatched",
      parameter = "bw"
    )
  }
)

plot(
  ages,
  ross_bw,
  type = "l",
  col = "blue",
  lwd = 2,
  xlab = "Age (days)",
  ylab = "Body weight (g/bird)",
  main = "As-hatched broiler body-weight standards"
)

lines(
  ages,
  cobb_bw,
  col = "red",
  lwd = 2
)

legend(
  "topleft",
  legend = c("Ross308", "Cobb500"),
  col = c("blue", "red"),
  lwd = 2,
  bty = "n"
)
```

## Create a standards data frame

The following example creates a table for every age from day 0 through day 56 for one genetic and sex combination.

```r
ages <- 0:56

standards <- data.frame(
  age = ages,
  bw_g = sapply(
    ages,
    broiler_std,
    genetic = "Cobb500",
    sex = "as_hatched",
    parameter = "bw"
  ),
  daily_feed_g = sapply(
    ages,
    broiler_std,
    genetic = "Cobb500",
    sex = "as_hatched",
    parameter = "daily_feed_intake"
  ),
  cum_feed_g = sapply(
    ages,
    broiler_std,
    genetic = "Cobb500",
    sex = "as_hatched",
    parameter = "cum_feed_intake"
  ),
  fcr = sapply(
    ages,
    broiler_std,
    genetic = "Cobb500",
    sex = "as_hatched",
    parameter = "fcr"
  )
)

head(standards, 10)
```

## Test all supported combinations

This check runs every combination of genetic, sex, and parameter at day 35.

```r
test_combinations <- expand.grid(
  genetic = c("Ross308", "Cobb500"),
  sex = c("as_hatched", "female", "male"),
  parameter = c(
    "bw",
    "daily_feed_intake",
    "cum_feed_intake",
    "fcr"
  ),
  stringsAsFactors = FALSE
)

test_combinations$value_day_35 <- mapply(
  FUN = broiler_std,
  age = 35,
  genetic = test_combinations$genetic,
  sex = test_combinations$sex,
  parameter = test_combinations$parameter
)

print(test_combinations)

stopifnot(
  nrow(test_combinations) == 24,
  all(is.finite(test_combinations$value_day_35))
)
```

## Quick validation checks

```r
# Ross308 as-hatched BW at day 10
stopifnot(
  broiler_std(
    age = 10,
    genetic = "Ross308",
    sex = "as_hatched",
    parameter = "bw"
  ) == 330
)

# Cobb500 as-hatched BW at day 10
stopifnot(
  broiler_std(
    age = 10,
    genetic = "Cobb500",
    sex = "as_hatched",
    parameter = "bw"
  ) == 330
)

# Cobb500 female interpolated BW at day 9.5
stopifnot(
  broiler_std(
    age = 9.5,
    genetic = "Cobb500",
    sex = "female",
    parameter = "bw"
  ) == 298
)

# Cobb500 male BW at the maximum supported age
stopifnot(
  broiler_std(
    age = 56,
    genetic = "Cobb500",
    sex = "male",
    parameter = "bw"
  ) == 4953
)
```

## Missing values

The Cobb500 tables supplied for this implementation do not report all feed-intake and FCR values during the first days of life. These blank cells are stored as `NA_real_`.

Example:

```r
broiler_std(
  age = 3,
  genetic = "Cobb500",
  sex = "as_hatched",
  parameter = "fcr"
)
# Expected: NA
```

Do not replace these missing values with zero. Zero would be a biological value and would incorrectly imply that the reported standard is zero.

When creating summaries, handle missing values explicitly:

```r
values <- c(NA, 40, 44, 50)

mean(values, na.rm = TRUE)
```

## Error handling

The function stops with an informative error when:

- `age` is not one finite numeric value.
- `age` is below 0 or above 56.
- `genetic` is unsupported.
- `sex` is unsupported.
- `parameter` is unsupported.
- An internal performance vector does not contain exactly 57 values.

Examples of invalid calls:

```r
# Invalid age
broiler_std(age = 60)

# Invalid genetic spelling
broiler_std(age = 35, genetic = "cobb500")

# Invalid sex category
broiler_std(age = 35, sex = "mixed")

# Invalid parameter
broiler_std(age = 35, parameter = "adg")
```

## Interpretation notes

Performance objectives are reference targets, not statistical predictions for a particular flock.

Differences between observed and standard performance may be associated with factors such as:

- chick quality and starting weight;
- diet composition and nutrient density;
- feed form and feed availability;
- environmental temperature and ventilation;
- stocking density;
- health status and mortality;
- lighting program;
- water availability and quality;
- farm management;
- slaughter age;
- local production conditions.

When analyzing a trial or commercial flock:

1. **Statistical significance** should be assessed from the experimental design and an appropriate statistical model.
2. **Biological relevance** should consider the magnitude and consistency of the performance difference.
3. **Commercial relevance** should consider feed cost, live weight, FCR, mortality, processing value, and return on investment.

## Data-source notes

- Ross308 values are the values included in the original function supplied for this project.
- Cobb500 values were transcribed from the attached metric performance-objective tables for as-hatched, female, and male birds.
- Cobb500 cumulative feed conversion is reported as not accounting for broiler mortality in the supplied tables.
- Confirm the publication edition and source document before using the standards for regulated, contractual, or customer-critical reporting.

## Limitations

- The function supports ages only from day 0 through day 56.
- Interpolation is linear between adjacent daily values.
- The function does not extrapolate beyond day 56.
- The function returns standards, not confidence intervals or expected biological variation.
- The function does not adjust standards for mortality, environment, diet, management, geography, or processing conditions.
- An FCR returned by the function should not be interpreted as mortality-corrected unless the underlying source explicitly defines it that way.

## Suggested citation in an analysis script

Include the exact source-document titles, publication editions, and access dates used by the project. A simple script comment can be written as:

```r
# Performance references:
# Ross 308 performance objectives: add exact edition used.
# Cobb 500 broiler performance objectives, metric: add exact edition used.
```

## Recommended version control

If performance tables are updated, record:

- function version;
- source-document edition;
- date of change;
- values changed;
- person who checked the transcription;
- validation tests completed.

A simple version comment can be added near the top of `broiler_std.R`:

```r
# broiler_std version: 1.0.0
# Last data review: YYYY-MM-DD
```

## License and internal use

Add the appropriate project license or internal-use statement before distributing the function. Performance-table ownership and reproduction conditions should follow the terms of the original source documents.
