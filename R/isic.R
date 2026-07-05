normalize_isic_code <- function(x, level = c("S", "M", "L")) {
  level <- match.arg(toupper(level[1L]), c("S", "M", "L"))
  digits <- switch(level, S = 4L, M = 3L, L = 2L)
  code <- normalize_gb_code(x, width = 4)
  out <- substr(code, 1L, digits)
  out[is.na(code)] <- NA_character_
  out
}

build_gb_2002_isic <- function(path) {
  x <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    colClasses = "character"
  )
  names(x) <- trimws(names(x))
  gb_col <- c("GB02", "INDCD4_02", "S_2002", "gb_code")
  gb_col <- gb_col[gb_col %in% names(x)][1L]
  isic_col <- c("ISIC02", "ISIC_02", "ISIC", "isic_code")
  isic_col <- isic_col[isic_col %in% names(x)][1L]
  if (is.na(gb_col) || is.na(isic_col)) {
    stop("Could not infer GB2002/ISIC columns.", call. = FALSE)
  }

  gb_s <- normalize_gb_code(x[[gb_col]], width = 4)
  isic_s <- normalize_isic_code(x[[isic_col]], "S")
  keep <- !is.na(gb_s) & !is.na(isic_s)
  gb_s <- gb_s[keep]
  isic_s <- isic_s[keep]

  out <- list()
  n <- 0L
  for (gb_level in c("S", "M", "L")) {
    gb_digits <- switch(gb_level, S = 4L, M = 3L, L = 2L)
    for (isic_level in c("S", "M", "L")) {
      isic_digits <- switch(isic_level, S = 4L, M = 3L, L = 2L)
      n <- n + 1L
      out[[n]] <- data.frame(
        gb_year = "2002",
        gb_level = gb_level,
        gb_code = substr(gb_s, 1L, gb_digits),
        isic_revision = "3",
        isic_level = isic_level,
        isic_code = substr(isic_s, 1L, isic_digits),
        source = "GB_2002_ISIC",
        stringsAsFactors = FALSE
      )
    }
  }

  ans <- unique(do.call(rbind, out))
  ans <- ans[order(
    ans$gb_year, ans$gb_level, ans$gb_code,
    ans$isic_revision, ans$isic_level, ans$isic_code
  ), , drop = FALSE]
  rownames(ans) <- NULL
  ans
}

read_gb_isic_crosswalk <- function(path) {
  x <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    colClasses = "character"
  )
  required <- c(
    "gb_year", "gb_level", "gb_code", "isic_revision",
    "isic_level", "isic_code", "source"
  )
  missing <- setdiff(required, names(x))
  if (length(missing) > 0L) {
    stop("GB-ISIC crosswalk is missing columns: ",
         paste(missing, collapse = ", "), call. = FALSE)
  }
  x <- x[required]
  for (col in names(x)) {
    x[[col]] <- as.character(x[[col]])
  }
  unique(x)
}

gb_isic_crosswalk_path <- function(file = "gb_2002_isic3.csv") {
  system.file("extdata", file, package = "gbcrosswalk", mustWork = TRUE)
}

load_gb_isic_crosswalk <- function(path = gb_isic_crosswalk_path()) {
  read_gb_isic_crosswalk(path)
}

convert_gb_to_isic <- function(codes, gb_year = NULL, gb_level = NULL,
                               isic_level = c("S", "M", "L"),
                               isic_revision = "3",
                               crosswalk = load_gb_isic_crosswalk(),
                               pairs = load_gb_crosswalks(),
                               years = c(1986, 1994, 2002, 2011, 2017),
                               unmatched = NA_character_) {
  isic_level <- match.arg(toupper(isic_level[1L]), c("S", "M", "L"))
  isic_revision <- as.character(isic_revision)

  if (!is.null(gb_level)) {
    gb_level <- match.arg(toupper(gb_level[1L]), c("S", "M", "L", "AUTO"))
    if (identical(gb_level, "AUTO")) {
      gb_level <- NULL
    }
  }

  if (is.null(gb_year) || is.null(gb_level)) {
    detected <- detect_gb_year(
      codes = codes,
      pairs = pairs,
      years = years,
      level = if (is.null(gb_level)) "auto" else gb_level,
      ties = "first",
      details = FALSE
    )
    if (is.null(gb_year)) {
      gb_year <- detected$year[1L]
    }
    if (is.null(gb_level)) {
      gb_level <- detected$level[1L]
    }
  }

  gb_year <- as.character(gb_year)
  if (identical(gb_year, "2002")) {
    gb_2002 <- normalize_gb_for_level(codes, gb_level)
  } else {
    gb_2002 <- convert_gb_codes(
      codes = codes,
      from_year = gb_year,
      to_year = 2002,
      level = gb_level,
      pairs = pairs,
      years = years,
      unmatched = unmatched
    )
  }

  cw <- crosswalk[
    crosswalk$gb_year == "2002" &
      crosswalk$gb_level == gb_level &
      crosswalk$isic_revision == isic_revision &
      crosswalk$isic_level == isic_level,
    , drop = FALSE
  ]
  if (nrow(cw) == 0L) {
    stop("No GB-ISIC crosswalk for requested levels/revision.", call. = FALSE)
  }

  lookup <- split(cw$isic_code, cw$gb_code)
  out <- lapply(gb_2002, function(code) {
    if (is.na(code)) {
      return(unmatched)
    }
    gb_parts <- unique(stats::na.omit(strsplit(code, "_", fixed = TRUE)[[1L]]))
    value <- unique(stats::na.omit(unlist(lookup[gb_parts], use.names = FALSE)))
    if (length(value) == 0L) {
      unmatched
    } else {
      paste(value, collapse = "_")
    }
  })
  unlist(out, use.names = FALSE)
}
