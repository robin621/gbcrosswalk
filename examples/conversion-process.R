library(gbcrosswalk)

# Example: codes detected as GB/T 4754-2017 at 3-digit M level.
codes_2017_m <- c("572", "593", "843", "905", "018")

# 1. Detect likely source vintage.
detect_gb_year(codes_2017_m, level = "M")

# 2. Convert the vector to GB2011 M-level codes.
cw_2017_to_2011_m <- compose_gb_crosswalk(
  pairs = load_gb_crosswalks(),
  from_year = 2017,
  to_year = 2011,
  level = "M"
)

crosswalk_codes(codes_2017_m, cw_2017_to_2011_m)

# 3. Convert a column in a data frame.
df <- data.frame(
  firm_id = seq_along(codes_2017_m),
  industry = codes_2017_m,
  stringsAsFactors = FALSE
)

convert_gb_column(
  data = df,
  column = "industry",
  from_year = 2017,
  to_year = 2011,
  level = "M",
  output_col = "industry_gb2011"
)
