\name{gbcrosswalk-package}
\alias{gbcrosswalk-package}
\alias{gbcrosswalk}
\alias{add_collapsed_targets}
\alias{as_gb_pair}
\alias{build_gb_1986_1994}
\alias{build_gb_1994_2002}
\alias{build_gb_2002_2011}
\alias{build_gb_2011_2017}
\alias{codes_to_gb_level}
\alias{compose_gb_crosswalk}
\alias{convert_gb_column}
\alias{crosswalk_codes}
\alias{detect_gb_year}
\alias{derive_gb_levels}
\alias{dominant_prefix}
\alias{fill_down_missing}
\alias{gb_crosswalk_path}
\alias{gb_raw_crosswalk_path}
\alias{load_gb_crosswalks}
\alias{normalize_gb_for_level}
\alias{normalize_gb_code}
\alias{read_gb_crosswalk_csvs}
\alias{standardize_gb_pairs}
\alias{write_gb_crosswalk_csvs}
\title{Crosswalk Chinese GB Industry Classifications Across Years}
\description{
Utilities for cleaning, building, and composing Chinese GB/T 4754 industry
classification crosswalks. The package standardizes adjacent pairwise
crosswalks into a long format and composes them across years.
}
\usage{
normalize_gb_code(x, width = 4)
normalize_gb_for_level(x, level = c("S", "M", "L"))
codes_to_gb_level(code, level = c("S", "M", "L"))
derive_gb_levels(data, year, s_col = NULL)
fill_down_missing(x)
dominant_prefix(codes, digits = 3, threshold = 0.5,
                special_cutoff = NULL, special_suffix = "")
add_collapsed_targets(data, from_col, to_col, to_all_col = NULL,
                      parent_col = NULL, parent_digits = 3,
                      threshold = 0.5, special_cutoff = NULL,
                      special_suffix = "")
as_gb_pair(data, from_year, to_year, from_col = NULL, to_col = NULL,
           levels = c("S", "M", "L"), source_pair = NULL)
compose_gb_crosswalk(pairs, from_year, to_year, level = c("S", "M", "L"),
                     years = c(1986, 1994, 2002, 2011, 2017))
crosswalk_codes(codes, crosswalk, unmatched = NA_character_)
detect_gb_year(codes, pairs = load_gb_crosswalks(),
               years = c(1986, 1994, 2002, 2011, 2017),
               level = c("auto", "S", "M", "L"),
               ties = c("all", "first"), details = FALSE)
convert_gb_column(data, column, pairs = load_gb_crosswalks(), from_year, to_year,
                  level = c("S", "M", "L"), output_col = NULL,
                  years = c(1986, 1994, 2002, 2011, 2017),
                  unmatched = NA_character_)
standardize_gb_pairs(pairs)
write_gb_crosswalk_csvs(pairs, dir, prefix = "gb", include_combined = TRUE)
read_gb_crosswalk_csvs(path)
gb_crosswalk_path(file = "gb_all_pairs.csv")
gb_raw_crosswalk_path(file = NULL)
load_gb_crosswalks(path = gb_crosswalk_path())
build_gb_1986_1994(path, sheet = 1)
build_gb_1994_2002(path)
build_gb_2002_2011(path, sheet = 1)
build_gb_2011_2017(path, sheet = 1, old_col = NULL, new_col = NULL)
}
\arguments{
\item{x, code, codes}{Character or numeric GB codes.}
\item{width}{Target code width for left-zero padding.}
\item{level}{One of \code{"S"} for 4-digit, \code{"M"} for 3-digit, \code{"L"} for 2-digit codes, or \code{"auto"} where supported.}
\item{ties}{Whether to return all tied best matches or just the first one.}
\item{details}{Whether to return all candidate-year scores as well as the best match.}
\item{data}{A data frame containing crosswalk columns or a user data frame.}
\item{column}{Name of the input code column to convert.}
\item{year, from_year, to_year}{GB classification years.}
\item{s_col, from_col, to_col, old_col, new_col}{Column names for source and target codes.}
\item{to_all_col, parent_col}{Names for collapsed target and dominant parent columns.}
\item{parent_digits, digits}{Number of prefix digits used for parent codes.}
\item{threshold}{Share required for a dominant parent prefix.}
\item{special_cutoff, special_suffix}{Optional fallback rule for service-sector-style parent codes.}
\item{levels}{Levels to include when standardizing a pairwise crosswalk.}
\item{source_pair}{Optional source label.}
\item{pairs}{A standard pair table or list of pair tables. Defaults to the package-shipped merged CSV in \code{convert_gb_column()}.}
\item{file}{Package-shipped filename under \code{extdata} or \code{raw-crosswalks}.}
\item{dir}{Directory where CSV files should be written.}
\item{prefix}{Filename prefix for exported CSV files.}
\item{include_combined}{Whether to also write one combined all-pairs CSV.}
\item{output_col}{Name of the appended converted-code column.}
\item{years}{Ordered vector of supported years.}
\item{crosswalk}{A composed crosswalk with \code{from_code} and \code{to_code}.}
\item{unmatched}{Value returned for unmatched input codes.}
\item{path}{Path to a CSV, XLS, or XLSX crosswalk file, or a directory of CSV files.}
\item{sheet}{Excel sheet index or name.}
}
\value{
Either a character vector, a cleaned data frame, a standard pairwise crosswalk,
or a composed crosswalk depending on the function.
}
\examples{
normalize_gb_code(c("123", "0123"))
codes_to_gb_level("0123", "M")
}
