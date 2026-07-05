library(gbcrosswalk)

raw_dir <- file.path("inst", "raw-crosswalks")
out_dir <- file.path("inst", "extdata")

gb_isic <- build_gb_2002_isic(file.path(raw_dir, "GB_2002_ISIC_cw.csv"))

utils::write.csv(
  gb_isic,
  file.path(out_dir, "gb_2002_isic3.csv"),
  row.names = FALSE,
  na = ""
)
