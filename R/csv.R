standardize_gb_pairs <- function(pairs) {
  if (is.data.frame(pairs)) {
    x <- pairs
  } else {
    x <- do.call(rbind, pairs)
  }

  required <- c(
    "from_year", "to_year", "level", "from_code",
    "to_code", "to_code_all", "source_pair"
  )
  missing <- setdiff(required, names(x))
  if (length(missing) > 0L) {
    stop("Crosswalk table is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  x <- x[required]
  for (col in names(x)) {
    x[[col]] <- as.character(x[[col]])
  }
  x <- unique(x)
  ord <- order(x$from_year, x$to_year, x$level, x$from_code, x$to_code, na.last = TRUE)
  ans <- x[ord, , drop = FALSE]
  rownames(ans) <- NULL
  ans
}

write_gb_crosswalk_csvs <- function(pairs, dir, prefix = "gb", include_combined = TRUE) {
  x <- standardize_gb_pairs(pairs)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  paths <- character()
  keys <- unique(paste(x$from_year, x$to_year, sep = "_"))
  for (key in keys) {
    part <- x[paste(x$from_year, x$to_year, sep = "_") == key, , drop = FALSE]
    path <- file.path(dir, paste0(prefix, "_", key, ".csv"))
    utils::write.csv(part, path, row.names = FALSE, na = "")
    paths <- c(paths, path)
  }

  if (isTRUE(include_combined)) {
    path <- file.path(dir, paste0(prefix, "_all_pairs.csv"))
    utils::write.csv(x, path, row.names = FALSE, na = "")
    paths <- c(paths, path)
  }
  paths
}

read_gb_crosswalk_csvs <- function(path) {
  if (length(path) == 1L && dir.exists(path)) {
    path <- list.files(path, pattern = "\\.csv$", full.names = TRUE)
  }
  pieces <- lapply(
    path,
    utils::read.csv,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    colClasses = "character"
  )
  standardize_gb_pairs(pieces)
}

gb_crosswalk_path <- function(file = "gb_all_pairs.csv") {
  system.file("extdata", file, package = "gbcrosswalk", mustWork = TRUE)
}

gb_raw_crosswalk_path <- function(file = NULL) {
  if (is.null(file)) {
    system.file("raw-crosswalks", package = "gbcrosswalk", mustWork = TRUE)
  } else {
    system.file("raw-crosswalks", file, package = "gbcrosswalk", mustWork = TRUE)
  }
}

load_gb_crosswalks <- function(path = gb_crosswalk_path()) {
  read_gb_crosswalk_csvs(path)
}
