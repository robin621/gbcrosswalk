as_gb_pair <- function(data, from_year, to_year,
                       from_col = NULL, to_col = NULL,
                       levels = c("S", "M", "L"),
                       source_pair = NULL) {
  stopifnot(is.data.frame(data))
  from_year <- as.character(from_year)
  to_year <- as.character(to_year)
  if (is.null(source_pair)) {
    source_pair <- paste0(from_year, "_", to_year)
  }

  out <- list()
  n <- 0L
  for (level in levels) {
    f_col <- if (is.null(from_col)) paste0(level, "_", from_year) else from_col
    t_col <- if (is.null(to_col)) paste0(level, "_", to_year) else to_col
    t_all_col <- paste0(t_col, "_all")

    if (!f_col %in% names(data) || !t_col %in% names(data)) {
      next
    }

    n <- n + 1L
    to_all <- if (t_all_col %in% names(data)) data[[t_all_col]] else data[[t_col]]
    out[[n]] <- data.frame(
      from_year = from_year,
      to_year = to_year,
      level = level,
      from_code = as.character(data[[f_col]]),
      to_code = as.character(data[[t_col]]),
      to_code_all = as.character(to_all),
      source_pair = source_pair,
      stringsAsFactors = FALSE
    )
  }

  if (length(out) == 0L) {
    stop("No requested level columns were found.", call. = FALSE)
  }

  ans <- unique(do.call(rbind, out))
  ans <- ans[!is.na(ans$from_code) | !is.na(ans$to_code), , drop = FALSE]
  rownames(ans) <- NULL
  ans
}

compose_gb_crosswalk <- function(pairs, from_year, to_year, level = c("S", "M", "L"),
                                 years = c(1986, 1994, 2002, 2011, 2017)) {
  level <- match.arg(level)
  from_year <- as.character(from_year)
  to_year <- as.character(to_year)
  years <- as.character(years)

  if (is.data.frame(pairs)) {
    pair_table <- pairs
  } else {
    pair_table <- do.call(rbind, pairs)
  }

  required <- c("from_year", "to_year", "level", "from_code", "to_code")
  missing <- setdiff(required, names(pair_table))
  if (length(missing) > 0L) {
    stop("Pair table is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  i_from <- match(from_year, years)
  i_to <- match(to_year, years)
  if (is.na(i_from) || is.na(i_to)) {
    stop("from_year and to_year must appear in `years`.", call. = FALSE)
  }
  if (i_from == i_to) {
    return(data.frame(
      from_year = from_year, to_year = to_year, level = level,
      from_code = character(), to_code = character(),
      stringsAsFactors = FALSE
    ))
  }

  path <- years[seq(i_from, i_to, by = if (i_to > i_from) 1L else -1L)]
  forward <- i_to > i_from
  result <- NULL

  for (step in seq_len(length(path) - 1L)) {
    a <- path[step]
    b <- path[step + 1L]
    if (forward) {
      edge <- pair_table[pair_table$from_year == a & pair_table$to_year == b &
                           pair_table$level == level, , drop = FALSE]
      edge <- unique(edge[c("from_code", "to_code")])
    } else {
      edge <- pair_table[pair_table$from_year == b & pair_table$to_year == a &
                           pair_table$level == level, , drop = FALSE]
      edge <- unique(data.frame(
        from_code = edge$to_code,
        to_code = edge$from_code,
        stringsAsFactors = FALSE
      ))
    }

    if (nrow(edge) == 0L) {
      stop("No adjacent crosswalk for ", a, " -> ", b, " at level ", level, ".", call. = FALSE)
    }

    edge <- edge[!is.na(edge$from_code) & !is.na(edge$to_code), , drop = FALSE]
    if (is.null(result)) {
      result <- edge
    } else {
      merged <- merge(
        result,
        edge,
        by.x = "to_code",
        by.y = "from_code",
        all.x = TRUE,
        sort = FALSE
      )
      result <- unique(data.frame(
        from_code = merged$from_code,
        to_code = merged$to_code.y,
        stringsAsFactors = FALSE
      ))
    }
  }

  result <- unique(result[!is.na(result$from_code) & !is.na(result$to_code), , drop = FALSE])
  data.frame(
    from_year = from_year,
    to_year = to_year,
    level = level,
    from_code = result$from_code,
    to_code = result$to_code,
    stringsAsFactors = FALSE
  )
}

crosswalk_codes <- function(codes, crosswalk, unmatched = NA_character_) {
  required <- c("from_code", "to_code")
  missing <- setdiff(required, names(crosswalk))
  if (length(missing) > 0L) {
    stop("Crosswalk is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  input <- as.character(codes)
  lookup <- split(crosswalk$to_code, crosswalk$from_code)
  out <- lapply(input, function(code) {
    value <- unique(stats::na.omit(lookup[[code]]))
    if (length(value) == 0L) {
      unmatched
    } else {
      paste(value, collapse = "_")
    }
  })
  unlist(out, use.names = FALSE)
}

convert_gb_codes <- function(codes, from_year = NULL, to_year = NULL, level = NULL,
                             pairs = load_gb_crosswalks(),
                             years = c(1986, 1994, 2002, 2011, 2017),
                             unmatched = NA_character_) {
  if (is.null(to_year)) {
    stop("`to_year` is required.", call. = FALSE)
  }

  if (!is.null(level)) {
    level <- match.arg(toupper(level), c("S", "M", "L", "AUTO"))
    if (identical(level, "AUTO")) {
      level <- NULL
    }
  }

  if (is.null(from_year) || is.null(level)) {
    detected <- detect_gb_year(
      codes = codes,
      pairs = pairs,
      years = years,
      level = if (is.null(level)) "auto" else level,
      ties = "first",
      details = FALSE
    )
    if (is.null(from_year)) {
      from_year <- detected$year[1L]
    }
    if (is.null(level)) {
      level <- detected$level[1L]
    }
  }

  from_year <- as.character(from_year)
  to_year <- as.character(to_year)
  input <- normalize_gb_for_level(codes, level)

  if (identical(from_year, to_year)) {
    return(input)
  }

  cw <- compose_gb_crosswalk(
    pairs = pairs,
    from_year = from_year,
    to_year = to_year,
    level = level,
    years = years
  )
  crosswalk_codes(input, cw, unmatched = unmatched)
}

convert_gb_column <- function(data, column, pairs = load_gb_crosswalks(), from_year, to_year,
                              level = c("S", "M", "L"), output_col = NULL,
                              years = c(1986, 1994, 2002, 2011, 2017),
                              unmatched = NA_character_) {
  stopifnot(is.data.frame(data))
  level <- match.arg(level)
  if (!column %in% names(data)) {
    stop("Column not found: ", column, call. = FALSE)
  }
  if (is.null(output_col)) {
    output_col <- paste0(column, "_gb", to_year, "_", level)
  }

  input <- normalize_gb_for_level(data[[column]], level)
  if (as.character(from_year) == as.character(to_year)) {
    data[[output_col]] <- input
    return(data)
  }

  cw <- compose_gb_crosswalk(
    pairs = pairs,
    from_year = from_year,
    to_year = to_year,
    level = level,
    years = years
  )
  data[[output_col]] <- crosswalk_codes(input, cw, unmatched = unmatched)
  data
}
