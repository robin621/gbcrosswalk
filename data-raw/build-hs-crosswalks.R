library(gbcrosswalk)

raw_dir <- file.path("inst", "raw-crosswalks")
out_dir <- file.path("inst", "extdata")

hs_isic <- build_hs_combined_isic3(
  file.path(raw_dir, "HS_to_I3_all_cw.csv")
)

utils::write.csv(
  hs_isic,
  file.path(out_dir, "hs_combined_isic3.csv"),
  row.names = FALSE,
  na = ""
)
