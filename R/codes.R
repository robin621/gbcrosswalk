normalize_gb_code <- function(x, width = 4) {
  x <- as.character(x)
  x <- trimws(x)
  x[x %in% c("", "NA", "N/A", "NULL")] <- NA_character_
  is_num_like <- !is.na(x) & grepl("^[0-9]+(\\.0+)?$", x)
  x[is_num_like] <- sub("\\.0+$", "", x[is_num_like])
  short <- !is.na(x) & grepl("^[0-9]+$", x) & nchar(x) < width
  x[short] <- paste0(vapply(width - nchar(x[short]), function(n) {
    paste(rep("0", n), collapse = "")
  }, character(1)), x[short])
  x
}

normalize_gb_for_level <- function(x, level = c("S", "M", "L")) {
  level <- match.arg(level)
  width <- switch(level, S = 4L, M = 3L, L = 2L)
  x <- as.character(x)
  x <- trimws(x)
  x[x %in% c("", "NA", "N/A", "NULL")] <- NA_character_
  is_num_like <- !is.na(x) & grepl("^[0-9]+(\\.0+)?$", x)
  x[is_num_like] <- sub("\\.0+$", "", x[is_num_like])

  numeric_code <- !is.na(x) & grepl("^[0-9]+$", x)
  short <- numeric_code & nchar(x) < width
  x[short] <- paste0(vapply(width - nchar(x[short]), function(n) {
    paste(rep("0", n), collapse = "")
  }, character(1)), x[short])
  long <- numeric_code & nchar(x) > width
  x[long] <- substr(x[long], 1L, width)
  x
}

codes_to_gb_level <- function(code, level = c("S", "M", "L")) {
  level <- match.arg(level)
  digits <- switch(level, S = 4L, M = 3L, L = 2L)
  code <- normalize_gb_code(code, width = 4)
  out <- substr(code, 1L, digits)
  out[is.na(code)] <- NA_character_
  out
}

derive_gb_levels <- function(data, year, s_col = NULL) {
  stopifnot(is.data.frame(data))
  year <- as.character(year)
  if (is.null(s_col)) {
    s_col <- paste0("S_", year)
  }
  if (!s_col %in% names(data)) {
    stop("Column not found: ", s_col, call. = FALSE)
  }

  s_name <- paste0("S_", year)
  m_name <- paste0("M_", year)
  l_name <- paste0("L_", year)

  data[[s_name]] <- normalize_gb_code(data[[s_col]], width = 4)
  data[[m_name]] <- codes_to_gb_level(data[[s_name]], "M")
  data[[l_name]] <- codes_to_gb_level(data[[s_name]], "L")
  data
}

fill_down_missing <- function(x) {
  if (length(x) == 0L) {
    return(x)
  }
  for (i in seq_along(x)) {
    if (i > 1L && is.na(x[i])) {
      x[i] <- x[i - 1L]
    }
  }
  x
}
