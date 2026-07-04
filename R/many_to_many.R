dominant_prefix <- function(codes, digits = 3, threshold = 0.5,
                            special_cutoff = NULL, special_suffix = "") {
  codes <- normalize_gb_code(codes, width = 4)
  codes <- stats::na.omit(codes)
  if (length(codes) == 0L) {
    return(NA_character_)
  }

  prefixes <- substr(codes, 1L, digits)
  tab <- sort(table(prefixes), decreasing = TRUE)
  share <- as.numeric(tab[1L]) / length(prefixes)
  if (share > threshold) {
    return(names(tab)[1L])
  }

  first_two <- suppressWarnings(as.integer(substr(codes[1L], 1L, 2L)))
  if (!is.null(special_cutoff) && !is.na(first_two) && first_two > special_cutoff) {
    return(paste0(substr(codes[1L], 1L, 2L), special_suffix))
  }

  substr(codes[1L], 1L, digits)
}

add_collapsed_targets <- function(data, from_col, to_col, to_all_col = NULL,
                                  parent_col = NULL, parent_digits = 3,
                                  threshold = 0.5, special_cutoff = NULL,
                                  special_suffix = "") {
  stopifnot(is.data.frame(data))
  if (!from_col %in% names(data)) {
    stop("Column not found: ", from_col, call. = FALSE)
  }
  if (!to_col %in% names(data)) {
    stop("Column not found: ", to_col, call. = FALSE)
  }
  if (is.null(to_all_col)) {
    to_all_col <- paste0(to_col, "_all")
  }
  if (is.null(parent_col)) {
    parent_col <- paste0(sub("^S_", "M_", to_col), "_all")
  }

  data[[from_col]] <- normalize_gb_code(data[[from_col]], width = 4)
  data[[to_col]] <- normalize_gb_code(data[[to_col]], width = 4)
  data[[to_all_col]] <- data[[to_col]]

  from_values <- unique(stats::na.omit(data[[from_col]]))
  for (from_value in from_values) {
    idx <- which(data[[from_col]] == from_value)
    targets <- unique(stats::na.omit(data[[to_col]][idx]))
    if (length(targets) > 1L) {
      data[[to_all_col]][idx] <- paste(targets, collapse = "_")
    }
  }

  data[[parent_col]] <- NA_character_
  target_sets <- unique(stats::na.omit(data[[to_all_col]]))
  for (target_set in target_sets) {
    idx <- which(data[[to_all_col]] == target_set)
    split_targets <- unlist(strsplit(target_set, "_", fixed = TRUE), use.names = FALSE)
    data[[parent_col]][idx] <- dominant_prefix(
      split_targets,
      digits = parent_digits,
      threshold = threshold,
      special_cutoff = special_cutoff,
      special_suffix = special_suffix
    )
  }

  data
}
