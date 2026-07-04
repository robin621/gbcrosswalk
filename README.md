# gbcrosswalk

`gbcrosswalk` converts Chinese GB/T 4754 industry codes across classification
years. The package ships with both standardized crosswalk CSVs and the raw
source crosswalk files, so common conversions work immediately after install.

Supported GB vintages:

```text
1986, 1994, 2002, 2011, 2017
```

Supported granularities:

```text
S = 4-digit small class
M = 3-digit middle class
L = 2-digit large class
```

## Install

```r
remotes::install_github("robin621/gbcrosswalk")
```

or from a local checkout:

```r
install.packages(".", repos = NULL, type = "source")
```

## Convert Codes

Load the package:

```r
library(gbcrosswalk)
```

Convert a vector of GB2017 3-digit codes to GB2011 3-digit codes:

```r
codes_2017 <- c("572", "593", "843", "905", "018")

cw_2017_2011 <- compose_gb_crosswalk(
  pairs = load_gb_crosswalks(),
  from_year = 2017,
  to_year = 2011,
  level = "M"
)

crosswalk_codes(codes_2017, cw_2017_2011)
```

Expected output:

```text
"570" "599" "834_835_836_837_839" "729_894" "019_051"
```

Underscores mean one input code maps to multiple target codes.

## Convert A Data Column

Use `convert_gb_column()` when your industry codes live inside a data frame:

```r
df <- data.frame(
  firm_id = 1:5,
  industry = c("572", "593", "843", "905", "018")
)

df_2011 <- convert_gb_column(
  data = df,
  column = "industry",
  from_year = 2017,
  to_year = 2011,
  level = "M",
  output_col = "industry_gb2011"
)

df_2011
```

This appends a new column and preserves the original:

```text
  firm_id industry        industry_gb2011
1       1      572                    570
2       2      593                    599
3       3      843 834_835_836_837_839
4       4      905                729_894
5       5      018                019_051
```

## Detect The Source Year

If you do not know which GB vintage a vector comes from, score it against all
available years:

```r
detect_gb_year(c("572", "593", "843", "905", "018"), level = "M")
```

Use `details = TRUE` to inspect every candidate:

```r
detect_gb_year(c("572", "593", "843", "905", "018"), level = "M", details = TRUE)
```

For mixed or unknown granularity, omit `level`; the function infers `S`, `M`,
or `L` from code length:

```r
detect_gb_year(c("0111", "0164", "9700"))
detect_gb_year(c("011", "016", "970"))
```

## Common Workflows

Convert GB2002 small-class codes to GB2017 small-class codes:

```r
crosswalk_codes(
  codes = c("0111", "1810", "3911"),
  crosswalk = compose_gb_crosswalk(
    load_gb_crosswalks(),
    from_year = 2002,
    to_year = 2017,
    level = "S"
  )
)
```

Convert GB1986 large-class codes to GB2011 large-class codes:

```r
crosswalk_codes(
  codes = c("01", "02", "08"),
  crosswalk = compose_gb_crosswalk(
    load_gb_crosswalks(),
    from_year = 1986,
    to_year = 2011,
    level = "L"
  )
)
```

## Crosswalk Files

The package includes standardized CSVs:

```r
gb_crosswalk_path("gb_all_pairs.csv")
load_gb_crosswalks()
```

Each standardized crosswalk has this schema:

```text
from_year, to_year, level, from_code, to_code, to_code_all, source_pair
```

The package also includes the raw source files:

```r
gb_raw_crosswalk_path()
gb_raw_crosswalk_path("GB_T_4754_2017.pdf")
```

Bundled raw inputs:

```text
GB_1986_1994_cw.xlsx
GB_1994_2002_cw.csv
GB_2002_2011_cw.xls
GB_2011_2017_raw.csv
GB_T_4754_2017.pdf
```

## Rebuild Standardized CSVs

The standardized CSVs can be rebuilt from the package-shipped raw files:

```r
source("data-raw/build-crosswalks.R")
```

The rebuild script writes refreshed CSVs to `inst/extdata/`.

## Add A Newer GB Version

When you add a post-2017 PDF:

1. Extract the official old-new appendix into a CSV with old and new code
   columns.
2. Add the raw PDF and extracted CSV under `inst/raw-crosswalks/`.
3. Add a builder following `build_gb_2011_2017()`.
4. Add the adjacent pair to `data-raw/build-crosswalks.R`.
5. Rebuild `inst/extdata/gb_all_pairs.csv`.

Once the adjacent pair is included, `compose_gb_crosswalk()` can route through
it automatically.
