library(gbcrosswalk)

# Example: codes detected as GB/T 4754-2017 at 3-digit M level.
codes_2017_m <- c("572", "593", "843", "905", "018")

# 1. Detect likely source vintage.
detect_gb_year(codes_2017_m, level = "M")

# 2. Convert the vector to GB2011 M-level codes.
convert_gb_codes(
  codes_2017_m,
  from_year = 2017,
  to_year = 2011,
  level = "M"
)

# 3. If source vintage or level is unknown, leave them missing.
convert_gb_codes(codes_2017_m, to_year = 2011)

# 4. Convert a column in a data frame.
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
