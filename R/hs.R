normalize_hs_level <- function(level = c("HS6", "HS4", "HS2")) {
  level <- toupper(trimws(as.character(level[1L])))
  level <- gsub("[^A-Z0-9]", "", level)
  if (level %in% c("6", "06", "HS6", "HS06")) {
    return("HS6")
  }
  if (level %in% c("4", "04", "HS4", "HS04")) {
    return("HS4")
  }
  if (level %in% c("2", "02", "HS2", "HS02")) {
    return("HS2")
  }
  stop("`level` must be one of HS6, HS4, or HS2.", call. = FALSE)
}

normalize_hs_code <- function(x, level = c("HS6", "HS4", "HS2")) {
  level <- normalize_hs_level(level)
  digits <- switch(level, HS6 = 6L, HS4 = 4L, HS2 = 2L)
  code <- as.character(x)
  code <- trimws(code)
  code[code %in% c("", "NA", "N/A", "NULL")] <- NA_character_
  is_num_like <- !is.na(code) & grepl("^[0-9]+(\\.0+)?$", code)
  code[is_num_like] <- sub("\\.0+$", "", code[is_num_like])
  short <- !is.na(code) & grepl("^[0-9]+$", code) & nchar(code) < 6L
  code[short] <- paste0(vapply(6L - nchar(code[short]), function(n) {
    paste(rep("0", n), collapse = "")
  }, character(1)), code[short])
  long <- !is.na(code) & grepl("^[0-9]+$", code) & nchar(code) > 6L
  code[long] <- substr(code[long], 1L, 6L)
  out <- substr(code, 1L, digits)
  out[is.na(code)] <- NA_character_
  out
}

detect_hs_level <- function(codes) {
  x <- as.character(codes)
  x <- trimws(x)
  x[x %in% c("", "NA", "N/A", "NULL")] <- NA_character_
  x <- sub("\\.0+$", "", x)
  x <- stats::na.omit(x)
  widths <- nchar(x[grepl("^[0-9]+$", x)])
  if (length(widths) == 0L) {
    stop("Could not infer an HS level from non-numeric codes. Pass `hs_level` explicitly.",
         call. = FALSE)
  }
  max_width <- max(widths)
  if (max_width <= 2L) {
    "HS2"
  } else if (max_width <= 4L) {
    "HS4"
  } else {
    "HS6"
  }
}

build_hs_combined_isic3 <- function(path) {
  x <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    colClasses = "character"
  )
  names(x) <- trimws(names(x))

  hs_col <- c("HS - Combined  Product Code", "HS", "hs_code")
  hs_col <- hs_col[hs_col %in% names(x)][1L]
  if (is.na(hs_col)) {
    hs_col <- grep("^HS.*Combined.*Product.*Code$", names(x), value = TRUE)[1L]
  }
  isic_col <- c("ISIC Revision 3 Product Code", "ISIC", "isic_code")
  isic_col <- isic_col[isic_col %in% names(x)][1L]
  if (is.na(isic_col)) {
    isic_col <- grep("^ISIC.*Revision.*3.*Product.*Code$", names(x), value = TRUE)[1L]
  }
  if (is.na(hs_col) || is.na(isic_col)) {
    stop("Could not infer HS Combined/ISIC Revision 3 columns.", call. = FALSE)
  }

  hs6 <- normalize_hs_code(x[[hs_col]], "HS6")
  isic_s <- normalize_isic_code(x[[isic_col]], "S")
  keep <- !is.na(hs6) & !is.na(isic_s)
  hs6 <- hs6[keep]
  isic_s <- isic_s[keep]

  out <- list()
  n <- 0L
  for (hs_level in c("HS6", "HS4", "HS2")) {
    hs_digits <- switch(hs_level, HS6 = 6L, HS4 = 4L, HS2 = 2L)
    for (isic_level in c("S", "M", "L")) {
      isic_digits <- switch(isic_level, S = 4L, M = 3L, L = 2L)
      n <- n + 1L
      out[[n]] <- data.frame(
        hs_system = "HS Combined",
        hs_level = hs_level,
        hs_code = substr(hs6, 1L, hs_digits),
        isic_revision = "3",
        isic_level = isic_level,
        isic_code = substr(isic_s, 1L, isic_digits),
        source = "HS_Combined_ISIC_Rev3",
        stringsAsFactors = FALSE
      )
    }
  }

  ans <- unique(do.call(rbind, out))
  ans <- ans[order(
    ans$hs_system, ans$hs_level, ans$hs_code,
    ans$isic_revision, ans$isic_level, ans$isic_code
  ), , drop = FALSE]
  rownames(ans) <- NULL
  ans
}

read_hs_isic_crosswalk <- function(path) {
  x <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    colClasses = "character"
  )
  required <- c(
    "hs_system", "hs_level", "hs_code", "isic_revision",
    "isic_level", "isic_code", "source"
  )
  missing <- setdiff(required, names(x))
  if (length(missing) > 0L) {
    stop("HS-ISIC crosswalk is missing columns: ",
         paste(missing, collapse = ", "), call. = FALSE)
  }
  x <- x[required]
  for (col in names(x)) {
    x[[col]] <- as.character(x[[col]])
  }
  unique(x)
}

hs_isic_crosswalk_path <- function(file = "hs_combined_isic3.csv") {
  system.file("extdata", file, package = "gbcrosswalk", mustWork = TRUE)
}

load_hs_isic_crosswalk <- function(path = hs_isic_crosswalk_path()) {
  read_hs_isic_crosswalk(path)
}

.collapse_lookup_values <- function(codes, lookup, unmatched = NA_character_) {
  out <- lapply(codes, function(code) {
    if (is.na(code)) {
      return(unmatched)
    }
    parts <- unique(stats::na.omit(strsplit(code, "_", fixed = TRUE)[[1L]]))
    value <- unique(stats::na.omit(unlist(lookup[parts], use.names = FALSE)))
    if (length(value) == 0L) {
      unmatched
    } else {
      paste(value, collapse = "_")
    }
  })
  unlist(out, use.names = FALSE)
}

convert_gb_to_hs <- function(codes, gb_year = NULL, gb_level = NULL,
                             hs_level = c("HS6", "HS4", "HS2"),
                             hs_system = "HS Combined",
                             isic_revision = "3",
                             isic_level = c("S", "M", "L"),
                             gb_isic = load_gb_isic_crosswalk(),
                             hs_isic = load_hs_isic_crosswalk(),
                             pairs = load_gb_crosswalks(),
                             years = c(1986, 1994, 2002, 2011, 2017),
                             unmatched = NA_character_) {
  hs_level <- normalize_hs_level(hs_level)
  hs_system <- as.character(hs_system)
  isic_revision <- as.character(isic_revision)
  isic_level <- match.arg(toupper(isic_level[1L]), c("S", "M", "L"))

  isic_codes <- convert_gb_to_isic(
    codes = codes,
    gb_year = gb_year,
    gb_level = gb_level,
    isic_level = isic_level,
    isic_revision = isic_revision,
    crosswalk = gb_isic,
    pairs = pairs,
    years = years,
    unmatched = unmatched
  )

  cw <- hs_isic[
    toupper(hs_isic$hs_system) == toupper(hs_system) &
      hs_isic$hs_level == hs_level &
      hs_isic$isic_revision == isic_revision &
      hs_isic$isic_level == isic_level,
    , drop = FALSE
  ]
  if (nrow(cw) == 0L) {
    stop("No HS-ISIC crosswalk for requested HS system/levels/revision.",
         call. = FALSE)
  }

  lookup <- split(cw$hs_code, cw$isic_code)
  .collapse_lookup_values(isic_codes, lookup, unmatched = unmatched)
}

convert_hs_to_gb <- function(codes, hs_level = NULL,
                             gb_year = 2002,
                             gb_level = c("M", "S", "L"),
                             hs_system = "HS Combined",
                             isic_revision = "3",
                             isic_level = c("S", "M", "L"),
                             hs_isic = load_hs_isic_crosswalk(),
                             gb_isic = load_gb_isic_crosswalk(),
                             pairs = load_gb_crosswalks(),
                             years = c(1986, 1994, 2002, 2011, 2017),
                             unmatched = NA_character_) {
  if (is.null(hs_level)) {
    hs_level <- detect_hs_level(codes)
  }
  hs_level <- normalize_hs_level(hs_level)
  gb_level <- match.arg(toupper(gb_level[1L]), c("M", "S", "L"))
  hs_system <- as.character(hs_system)
  gb_year <- as.character(gb_year)
  isic_revision <- as.character(isic_revision)
  isic_level <- match.arg(toupper(isic_level[1L]), c("S", "M", "L"))
  input <- normalize_hs_code(codes, hs_level)

  hs_cw <- hs_isic[
    toupper(hs_isic$hs_system) == toupper(hs_system) &
      hs_isic$hs_level == hs_level &
      hs_isic$isic_revision == isic_revision &
      hs_isic$isic_level == isic_level,
    , drop = FALSE
  ]
  if (nrow(hs_cw) == 0L) {
    stop("No HS-ISIC crosswalk for requested HS system/levels/revision.",
         call. = FALSE)
  }

  gb_cw <- gb_isic[
    gb_isic$gb_year == "2002" &
      gb_isic$gb_level == gb_level &
      gb_isic$isic_revision == isic_revision &
      gb_isic$isic_level == isic_level,
    , drop = FALSE
  ]
  if (nrow(gb_cw) == 0L) {
    stop("No GB-ISIC crosswalk for requested GB/ISIC levels/revision.",
         call. = FALSE)
  }

  isic_lookup <- split(hs_cw$isic_code, hs_cw$hs_code)
  isic_codes <- .collapse_lookup_values(input, isic_lookup, unmatched = unmatched)

  gb_lookup <- split(gb_cw$gb_code, gb_cw$isic_code)
  gb_2002 <- .collapse_lookup_values(isic_codes, gb_lookup, unmatched = unmatched)

  if (identical(gb_year, "2002")) {
    return(gb_2002)
  }

  out <- lapply(gb_2002, function(code) {
    if (is.na(code)) {
      return(unmatched)
    }
    parts <- unique(stats::na.omit(strsplit(code, "_", fixed = TRUE)[[1L]]))
    converted <- convert_gb_codes(
      codes = parts,
      from_year = 2002,
      to_year = gb_year,
      level = gb_level,
      pairs = pairs,
      years = years,
      unmatched = unmatched
    )
    converted <- unique(stats::na.omit(converted))
    if (length(converted) == 0L) {
      unmatched
    } else {
      paste(converted, collapse = "_")
    }
  })
  unlist(out, use.names = FALSE)
}
