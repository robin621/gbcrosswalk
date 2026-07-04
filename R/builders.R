require_readxl <- function() {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Package `readxl` is required for Excel input.", call. = FALSE)
  }
}

read_crosswalk_file <- function(path, sheet = 1) {
  ext <- tolower(tools::file_ext(path))
  if (ext %in% c("xls", "xlsx")) {
    require_readxl()
    as.data.frame(readxl::read_excel(path, sheet = sheet), stringsAsFactors = FALSE)
  } else if (ext == "csv") {
    utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  } else {
    stop("Unsupported input type: ", ext, call. = FALSE)
  }
}

build_gb_1994_2002 <- function(path) {
  x <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  names(x)[names(x) == "GB02"] <- "S_2002"
  names(x)[names(x) == "GB94"] <- "S_1994"
  if (!all(c("S_1994", "S_2002") %in% names(x))) {
    stop("Expected columns GB94/GB02 or S_1994/S_2002.", call. = FALSE)
  }
  x <- derive_gb_levels(x, 1994, "S_1994")
  x <- derive_gb_levels(x, 2002, "S_2002")
  x <- x[rowSums(is.na(x)) < ncol(x), , drop = FALSE]
  x <- add_collapsed_targets(
    x, "S_1994", "S_2002",
    to_all_col = "S_2002_all",
    parent_col = "M_2002_all",
    special_cutoff = 66
  )
  as_gb_pair(x, 1994, 2002)
}

build_gb_1986_1994 <- function(path, sheet = 1) {
  x <- read_crosswalk_file(path, sheet = sheet)
  legacy <- c(
    L_86 = "L_1986", M_86 = "M_1986", S_86 = "S_1986",
    L_94 = "L_1994", M_94 = "M_1994", S_94 = "S_1994"
  )
  for (old in names(legacy)) {
    names(x)[names(x) == old] <- legacy[[old]]
  }
  if (!all(c("S_1986", "S_1994") %in% names(x))) {
    stop("Expected columns S_1986 and S_1994.", call. = FALSE)
  }
  for (year in c("1986", "1994")) {
    s <- paste0("S_", year)
    m <- paste0("M_", year)
    l <- paste0("L_", year)
    if (!m %in% names(x)) x[[m]] <- NA_character_
    if (!l %in% names(x)) x[[l]] <- NA_character_
    x[[s]] <- normalize_gb_for_level(x[[s]], "S")
    x[[m]] <- normalize_gb_for_level(x[[m]], "M")
    x[[l]] <- normalize_gb_for_level(x[[l]], "L")
  }

  for (year in c("1986", "1994")) {
    m <- paste0("M_", year)
    s <- paste0("S_", year)
    l <- paste0("L_", year)
    x[[m]][is.na(x[[m]])] <- codes_to_gb_level(x[[s]][is.na(x[[m]])], "M")
    x[[l]][is.na(x[[l]])] <- codes_to_gb_level(x[[s]][is.na(x[[l]])], "L")
  }

  x <- x[!is.na(x$M_1994) & !is.na(x$S_1994), , drop = FALSE]
  x <- add_collapsed_targets(
    x, "S_1986", "S_1994",
    to_all_col = "S_1994_all",
    parent_col = "M_1994_all",
    special_cutoff = 60,
    special_suffix = "0"
  )
  as_gb_pair(x, 1986, 1994)
}

build_gb_2002_2011 <- function(path, sheet = 1) {
  x <- read_crosswalk_file(path, sheet = sheet)
  if (nrow(x) >= 3L && ncol(x) >= 5L) {
    x <- x[-seq_len(3L), -c(2L, 4L, 5L), drop = FALSE]
  }
  if (ncol(x) < 2L) {
    stop("Expected at least two columns containing 2011 and 2002 codes.", call. = FALSE)
  }
  x <- x[, seq_len(2L), drop = FALSE]
  names(x) <- c("S_2011", "S_2002")
  x <- x[!x$S_2011 %in% LETTERS, , drop = FALSE]
  x$S_2011 <- normalize_gb_code(x$S_2011, width = 4)
  x$S_2002 <- normalize_gb_code(x$S_2002, width = 4)
  x <- x[nchar(x$S_2011) == 4L | nchar(x$S_2002) == 4L, , drop = FALSE]
  x <- x[!is.na(x$S_2011) | !is.na(x$S_2002), , drop = FALSE]
  x$S_2011 <- fill_down_missing(x$S_2011)
  x <- derive_gb_levels(x, 2011, "S_2011")
  x <- derive_gb_levels(x, 2002, "S_2002")
  x <- add_collapsed_targets(
    x, "S_2002", "S_2011",
    to_all_col = "S_2011_all",
    parent_col = "M_2011_all",
    special_cutoff = 66
  )
  as_gb_pair(x, 2002, 2011)
}

build_gb_2011_2017 <- function(path, sheet = 1,
                               old_col = NULL, new_col = NULL) {
  x <- read_crosswalk_file(path, sheet = sheet)

  if (is.null(old_col)) {
    old_candidates <- c(
      "S_2011", "GB2011", "GB_2011", "old_code",
      "\u65e7\u4ee3\u7801", "\u65e7\u7c7b\u76ee\u4ee3\u7801"
    )
    old_col <- old_candidates[old_candidates %in% names(x)][1L]
  }
  if (is.null(new_col)) {
    new_candidates <- c(
      "S_2017", "GB2017", "GB_2017", "new_code",
      "\u65b0\u4ee3\u7801", "\u65b0\u7c7b\u76ee\u4ee3\u7801"
    )
    new_col <- new_candidates[new_candidates %in% names(x)][1L]
  }
  if (is.na(old_col) || is.na(new_col)) {
    stop("Could not infer 2011/2017 columns. Pass `old_col` and `new_col`.", call. = FALSE)
  }

  names(x)[names(x) == old_col] <- "S_2011"
  names(x)[names(x) == new_col] <- "S_2017"
  x$S_2011 <- fill_down_missing(normalize_gb_code(x$S_2011, width = 4))
  x$S_2017 <- fill_down_missing(normalize_gb_code(x$S_2017, width = 4))
  x <- x[!is.na(x$S_2011) | !is.na(x$S_2017), , drop = FALSE]
  x <- derive_gb_levels(x, 2011, "S_2011")
  x <- derive_gb_levels(x, 2017, "S_2017")
  x <- add_collapsed_targets(
    x, "S_2011", "S_2017",
    to_all_col = "S_2017_all",
    parent_col = "M_2017_all",
    special_cutoff = 66
  )
  as_gb_pair(x, 2011, 2017)
}
