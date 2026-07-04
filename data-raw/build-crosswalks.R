library(gbcrosswalk)

raw_dir <- file.path("inst", "raw-crosswalks")
out_dir <- file.path("inst", "extdata")

cw_86_94 <- build_gb_1986_1994(file.path(raw_dir, "GB_1986_1994_cw.xlsx"))
cw_94_02 <- build_gb_1994_2002(file.path(raw_dir, "GB_1994_2002_cw.csv"))
cw_02_11 <- build_gb_2002_2011(file.path(raw_dir, "GB_2002_2011_cw.xls"))
cw_11_17 <- build_gb_2011_2017(file.path(raw_dir, "GB_2011_2017_raw.csv"))

write_gb_crosswalk_csvs(
  list(cw_86_94, cw_94_02, cw_02_11, cw_11_17),
  dir = out_dir
)
