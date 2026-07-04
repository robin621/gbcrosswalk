# This script is intentionally a template. Keep raw files outside the package
# and save cleaned package data only after you inspect the outputs.

library(gbcrosswalk)

raw_dir <- "C:/Users/wangy/OneDrive/GitHub/cncustoms_clone"

cw_86_94 <- build_gb_1986_1994(file.path(raw_dir, "GB_1986_1994_cw.xlsx"))
cw_94_02 <- build_gb_1994_2002(file.path(raw_dir, "GB_1994_2002_cw.csv"))
cw_02_11 <- build_gb_2002_2011(file.path(raw_dir, "GB_2002_2011_cw.xls"))

# Extract Appendix B from GB/T 4754-2017 to a CSV/XLSX with columns S_2011
# and S_2017, then uncomment:
# cw_11_17 <- build_gb_2011_2017(file.path(raw_dir, "GB_2011_2017_cw.csv"))

# gb_pairs <- rbind(cw_86_94, cw_94_02, cw_02_11, cw_11_17)
# usethis::use_data(gb_pairs, overwrite = TRUE)
