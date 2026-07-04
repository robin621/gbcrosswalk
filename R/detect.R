gb_code_sets <- function(pairs = load_gb_crosswalks(),
                         years = c(1986, 1994, 2002, 2011, 2017),
                         levels = c("S", "M", "L")) {
  if (!is.data.frame(pairs)) {
    pairs <- do.call(rbind, pairs)
  }
  required <- c("from_year", "to_year", "level", "from_code", "to_code", "to_code_all")
  missing <- setdiff(required, names(pairs))
  if (length(missing) > 0L) {
    stop("Crosswalk table is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  out <- list()
  for (year in as.character(years)) {
    for (level in levels) {
      from_codes <- pairs$from_code[pairs$from_year == year & pairs$level == level]
      to_codes <- pairs$to_code[pairs$to_year == year & pairs$level == level]
      to_all <- pairs$to_code_all[pairs$to_year == year & pairs$level == level]
      split_to_all <- unlist(strsplit(stats::na.omit(to_all), "_", fixed = TRUE), use.names = FALSE)
      codes <- unique(stats::na.omit(c(from_codes, to_codes, split_to_all)))
      codes <- normalize_gb_for_level(codes, level)
      out[[paste(year, level, sep = "_")]] <- unique(stats::na.omit(codes))
    }
  }
  out
}

detect_gb_year <- function(codes, pairs = load_gb_crosswalks(),
                           years = c(1986, 1994, 2002, 2011, 2017),
                           level = c("auto", "S", "M", "L"),
                           ties = c("all", "first"),
                           details = FALSE) {
  level <- match.arg(level)
  ties <- match.arg(ties)

  x <- as.character(codes)
  x <- trimws(x)
  x[x %in% c("", "NA", "N/A", "NULL")] <- NA_character_
  x <- sub("\\.0+$", "", x)
  x <- stats::na.omit(x)
  if (length(x) == 0L) {
    stop("`codes` has no non-missing values.", call. = FALSE)
  }

  if (level == "auto") {
    widths <- nchar(x[grepl("^[0-9]+$", x)])
    if (length(widths) == 0L) {
      stop("Could not infer a GB level from non-numeric codes. Pass `level` explicitly.", call. = FALSE)
    }
    max_width <- max(widths)
    levels <- if (max_width <= 2L) {
      "L"
    } else if (max_width <= 3L) {
      "M"
    } else {
      "S"
    }
  } else {
    levels <- level
  }
  sets <- gb_code_sets(pairs, years = years, levels = levels)

  rows <- list()
  n <- 0L
  for (candidate_level in levels) {
    input <- normalize_gb_for_level(x, candidate_level)
    input <- stats::na.omit(input)
    input_unique <- unique(input)
    for (year in as.character(years)) {
      key <- paste(year, candidate_level, sep = "_")
      known <- sets[[key]]
      matched <- input %in% known
      matched_unique <- input_unique %in% known
      n <- n + 1L
      rows[[n]] <- data.frame(
        year = year,
        level = candidate_level,
        n = length(input),
        n_unique = length(input_unique),
        matched = sum(matched),
        matched_unique = sum(matched_unique),
        share = if (length(input) == 0L) NA_real_ else mean(matched),
        share_unique = if (length(input_unique) == 0L) NA_real_ else mean(matched_unique),
        stringsAsFactors = FALSE
      )
    }
  }

  scores <- do.call(rbind, rows)
  scores <- scores[order(-scores$share, -scores$share_unique, scores$level, scores$year), , drop = FALSE]
  rownames(scores) <- NULL

  best_share <- scores$share[1L]
  best_share_unique <- scores$share_unique[1L]
  best <- scores[scores$share == best_share & scores$share_unique == best_share_unique, , drop = FALSE]
  if (ties == "first") {
    best <- best[1L, , drop = FALSE]
  }

  if (details) {
    return(list(best = best, scores = scores))
  }
  best
}
