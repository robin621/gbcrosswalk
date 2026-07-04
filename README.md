# gbcrosswalk

`gbcrosswalk` is a small R package for building and using crosswalks between
Chinese GB/T 4754 industry classification years.

It is based on the workflow in your original script:

- normalize GB industry codes, preserving leading zeroes;
- derive 4-digit (`S`), 3-digit (`M`), and 2-digit (`L`) levels;
- collapse one-to-many mappings into `_`-separated target sets;
- choose a dominant higher-level parent when a collapsed target set crosses
  multiple parent codes;
- compose adjacent crosswalks, e.g. `1986 -> 1994 -> 2002 -> 2011 -> 2017`.

## Install locally

```r
remotes::install_github("robin621/gbcrosswalk")
```

or from a local checkout:

```r
install.packages(".", repos = NULL, type = "source")
```

## Build pairwise crosswalks

```r
library(gbcrosswalk)

raw_dir <- gb_raw_crosswalk_path()

cw_94_02 <- build_gb_1994_2002(file.path(raw_dir, "GB_1994_2002_cw.csv"))
cw_86_94 <- build_gb_1986_1994(file.path(raw_dir, "GB_1986_1994_cw.xlsx"))
cw_02_11 <- build_gb_2002_2011(file.path(raw_dir, "GB_2002_2011_cw.xls"))
cw_11_17 <- build_gb_2011_2017(file.path(raw_dir, "GB_2011_2017_raw.csv"))
```

Each builder returns a standard long table with columns:

```text
from_year, to_year, level, from_code, to_code, to_code_all, source_pair
```

Write every adjacent pair and one combined file to CSV:

```r
write_gb_crosswalk_csvs(pairs, "crosswalk_csv")
gb_pairs <- read_gb_crosswalk_csvs("crosswalk_csv/gb_all_pairs.csv")
```

The package also ships with the current standardized CSVs:

```r
gb_pairs <- load_gb_crosswalks()
gb_crosswalk_path("gb_all_pairs.csv")
gb_raw_crosswalk_path("GB_T_4754_2017.pdf")
```

## Compose years

```r
pairs <- list(cw_86_94, cw_94_02, cw_02_11, cw_11_17)

cw_86_17_m <- compose_gb_crosswalk(
  pairs,
  from_year = 1986,
  to_year = 2017,
  level = "M"
)

crosswalk_codes(c("011", "021"), cw_86_17_m)
```

Or append the converted code directly to a data frame:

```r
df2 <- convert_gb_column(
  df,
  column = "industry_code",
  from_year = 2002,
  to_year = 2017,
  level = "M"
)
```

## Adding versions after 2017

When you add a newer PDF, extract the official old-new appendix into a table
with the adjacent years, standardize it with `build_gb_2011_2017()` as a model,
and add that pair to `pairs` before calling `compose_gb_crosswalk()`.
