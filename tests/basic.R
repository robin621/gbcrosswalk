library(gbcrosswalk)

stopifnot(identical(
  normalize_gb_code(c("123", "0123", 123, NA)),
  c("0123", "0123", "0123", NA_character_)
))
stopifnot(identical(codes_to_gb_level("0123", "M"), "012"))
stopifnot(identical(normalize_gb_for_level(c("0111", "11"), "M"), c("011", "011")))
stopifnot(identical(fill_down_missing(c("a", NA, "b", NA)), c("a", "a", "b", "b")))

p1 <- data.frame(
  from_year = "1994", to_year = "2002", level = "S",
  from_code = c("0101", "0102"), to_code = c("0201", "0202"),
  to_code_all = c("0201", "0202"),
  stringsAsFactors = FALSE
)
p2 <- data.frame(
  from_year = "2002", to_year = "2011", level = "S",
  from_code = c("0201", "0202"), to_code = c("1101", "1102"),
  to_code_all = c("1101", "1102"),
  stringsAsFactors = FALSE
)
cw <- compose_gb_crosswalk(list(p1, p2), 1994, 2011, "S", years = c(1994, 2002, 2011))
stopifnot(identical(crosswalk_codes(c("0101", "0102"), cw), c("1101", "1102")))
stopifnot(identical(
  convert_gb_codes(c("0101", "0102"), 1994, 2011, "S", list(p1, p2), years = c(1994, 2002, 2011)),
  c("1101", "1102")
))
stopifnot(identical(
  convert_gb_codes(c("0101", "0102"), to_year = 2011, pairs = list(p1, p2), years = c(1994, 2002, 2011)),
  c("1101", "1102")
))

df <- data.frame(ind = c("0101", "0102"), stringsAsFactors = FALSE)
df <- convert_gb_column(df, "ind", list(p1, p2), 1994, 2011, "S", years = c(1994, 2002, 2011))
stopifnot(identical(df$ind_gb2011_S, c("1101", "1102")))

stopifnot(file.exists(gb_crosswalk_path("gb_all_pairs.csv")))
stopifnot(file.exists(gb_raw_crosswalk_path("GB_1994_2002_cw.csv")))
stopifnot(file.exists(gb_isic_crosswalk_path("gb_2002_isic3.csv")))
stopifnot(file.exists(gb_raw_crosswalk_path("GB_2002_ISIC_cw.csv")))

stopifnot(identical(
  convert_gb_to_isic(c("0111", "0112", "9800"), gb_year = 2002, gb_level = "S"),
  c("0111", "0111", "9900")
))
stopifnot(identical(
  convert_gb_to_isic(c("011", "980"), gb_year = 2002, gb_level = "M", isic_level = "M"),
  c("011", "990")
))
stopifnot(identical(
  convert_gb_to_isic(c("572", "593", "843"), gb_year = 2017, gb_level = "M", isic_level = "M"),
  c("603", "630", "851")
))

detected <- detect_gb_year(c("0111", "0164", "9700"), level = "S")
stopifnot(detected$year[1] == "2017")

detected_m <- detect_gb_year(c("011", "016", "970"), level = "M")
stopifnot(detected_m$year[1] == "2017")

detected_auto <- detect_gb_year(c("011", "016", "970"))
stopifnot(detected_auto$level[1] == "M")

reviewed_2017_fixes <- convert_gb_codes(
  c("1321", "3964", "6999", "7296", "8740"),
  from_year = 2017,
  to_year = 2011,
  level = "S"
)
stopifnot(identical(
  reviewed_2017_fixes,
  c("1320_1363", "3599_3855_3859", "6990_7296", "7296", "8610_8620")
))
