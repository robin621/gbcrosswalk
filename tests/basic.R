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
  stringsAsFactors = FALSE
)
p2 <- data.frame(
  from_year = "2002", to_year = "2011", level = "S",
  from_code = c("0201", "0202"), to_code = c("1101", "1102"),
  stringsAsFactors = FALSE
)
cw <- compose_gb_crosswalk(list(p1, p2), 1994, 2011, "S", years = c(1994, 2002, 2011))
stopifnot(identical(crosswalk_codes(c("0101", "0102"), cw), c("1101", "1102")))

df <- data.frame(ind = c("0101", "0102"), stringsAsFactors = FALSE)
df <- convert_gb_column(df, "ind", list(p1, p2), 1994, 2011, "S", years = c(1994, 2002, 2011))
stopifnot(identical(df$ind_gb2011_S, c("1101", "1102")))
