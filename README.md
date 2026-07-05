# gbcrosswalk

`gbcrosswalk` converts Chinese GB/T 4754 industry codes across classification
years. The package ships with standardized crosswalk CSVs and compact raw
crosswalk tables, so common conversions work immediately after install.

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

Additional bundled classification links:

```text
GB/T 4754-2002 industry codes -> ISIC Revision 3 activity codes
HS - Combined Product Code -> ISIC Revision 3 activity codes
```

The HS source is the file's `HS - Combined Product Code` classification. It is
not labeled as a single HS1996, HS2002, HS2007, HS2012, or HS2017 revision in
the source file.

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

convert_gb_codes(
  codes_2017,
  from_year = 2017,
  to_year = 2011,
  level = "M"
)
```

Expected output:

```text
"570" "599" "834_835_836_837_839" "729_894" "019_051"
```

Underscores mean one input code maps to multiple target codes.

If you do not know the source year or granularity, leave them out. The function
will infer them from the input vector:

```r
convert_gb_codes(codes_2017, to_year = 2011)
```

You can also provide only the part you know:

```r
convert_gb_codes(codes_2017, to_year = 2011, level = "M")
convert_gb_codes(codes_2017, from_year = 2017, to_year = 2011)
```

Use the lower-level helpers when you want to inspect or reuse the composed
crosswalk table:

```r
cw_2017_2011 <- compose_gb_crosswalk(
  pairs = load_gb_crosswalks(),
  from_year = 2017,
  to_year = 2011,
  level = "M"
)

crosswalk_codes(codes_2017, cw_2017_2011)
```

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

## Convert GB To ISIC Revision 3

Use `convert_gb_to_isic()` to link GB industry codes to ISIC Revision 3 codes.
The bundled direct crosswalk is GB/T 4754-2002 to ISIC Revision 3. If your
input GB codes come from another supported GB vintage, the function first
converts them to GB2002 and then links them to ISIC Revision 3.

```r
convert_gb_to_isic(
  c("0111", "0112", "9800"),
  gb_year = 2002,
  gb_level = "S"
)
```

Expected output:

```text
"0111" "0111" "9900"
```

You can ask for coarser ISIC levels:

```r
convert_gb_to_isic(
  c("0111", "0112", "9800"),
  gb_year = 2002,
  gb_level = "S",
  isic_level = "M"
)
```

If the source GB year or GB level is unknown, leave them missing and the
function will use `detect_gb_year()` before linking:

```r
convert_gb_to_isic(c("572", "593", "843"), isic_level = "M")
```

## Convert GB To HS Combined

Use `convert_gb_to_hs()` to link GB industry codes to `HS - Combined Product
Code` values. The route is:

```text
GB/T 4754 input year -> GB/T 4754-2002 -> ISIC Revision 3 -> HS Combined
```

Ask for `HS6`, `HS4`, or `HS2` output with `hs_level`:

```r
convert_gb_to_hs(
  "152",
  gb_year = 2002,
  gb_level = "M",
  hs_level = "HS2",
  isic_level = "M"
)
```

Expected output:

```text
"11_22"
```

You can also start from supported non-2002 GB vintages:

```r
convert_gb_to_hs(
  "151",
  gb_year = 2017,
  gb_level = "M",
  hs_level = "HS2",
  isic_level = "M"
)
```

For the reverse direction, use `convert_hs_to_gb()`. If `hs_level` is omitted,
the package infers `HS6`, `HS4`, or `HS2` from code length:

```r
convert_hs_to_gb(
  c("010110", "010111", "970600"),
  gb_year = 2002,
  gb_level = "M"
)
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
gb_isic_crosswalk_path("gb_2002_isic3.csv")
load_gb_isic_crosswalk()
hs_isic_crosswalk_path("hs_combined_isic3.csv")
load_hs_isic_crosswalk()
```

The GB-year standardized crosswalk has this schema:

```text
from_year, to_year, level, from_code, to_code, to_code_all, source_pair
```

The GB-ISIC standardized crosswalk has this schema:

```text
gb_year, gb_level, gb_code, isic_revision, isic_level, isic_code, source
```

The HS-ISIC standardized crosswalk has this schema:

```text
hs_system, hs_level, hs_code, isic_revision, isic_level, isic_code, source
```

The bundled ISIC links are specifically ISIC Revision 3. The bundled HS link is
specifically `HS - Combined Product Code` to ISIC Revision 3.

The installed package also includes compact raw crosswalk inputs:

```r
gb_raw_crosswalk_path()
```

Bundled raw inputs in package builds:

```text
GB_1986_1994_cw.xlsx
GB_1994_2002_cw.csv
GB_2002_2011_cw.xls
GB_2011_2017_raw.csv
GB_2002_ISIC_cw.csv
HS_to_I3_all_cw.csv
```

The original GB/T 4754 standard PDFs are retained in the GitHub repository for
readers who want to inspect the source documents:

```text
inst/raw-crosswalks/GB_T_4754_1994.pdf
inst/raw-crosswalks/GB_T_4754_2002.pdf
inst/raw-crosswalks/GB_T_4754_2017.pdf
```

These PDFs are excluded from CRAN-style package builds to keep the source
package small.

## Rebuild Standardized CSVs

From a source checkout, the standardized CSVs can be rebuilt from the raw files:

```r
source("data-raw/build-crosswalks.R")
source("data-raw/build-isic-crosswalks.R")
source("data-raw/build-hs-crosswalks.R")
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
