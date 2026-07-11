\name{gbcrosswalk-package}
\alias{gbcrosswalk-package}
\alias{gbcrosswalk}
\alias{add_collapsed_targets}
\alias{as_gb_pair}
\alias{build_gb_1986_1994}
\alias{build_gb_1994_2002}
\alias{build_gb_2002_2011}
\alias{build_gb_2002_isic}
\alias{build_gb_2011_2017}
\alias{build_hs_combined_isic3}
\alias{codes_to_gb_level}
\alias{compose_gb_crosswalk}
\alias{convert_gb_codes}
\alias{convert_gb_column}
\alias{convert_gb_to_hs}
\alias{convert_gb_to_isic}
\alias{convert_hs_to_gb}
\alias{crosswalk_codes}
\alias{detect_gb_year}
\alias{detect_hs_level}
\alias{derive_gb_levels}
\alias{dominant_prefix}
\alias{fill_down_missing}
\alias{gb_crosswalk_path}
\alias{gb_isic_crosswalk_path}
\alias{gb_raw_crosswalk_path}
\alias{hs_isic_crosswalk_path}
\alias{load_hs_isic_crosswalk}
\alias{load_gb_isic_crosswalk}
\alias{load_gb_crosswalks}
\alias{normalize_isic_code}
\alias{normalize_gb_for_level}
\alias{normalize_gb_code}
\alias{normalize_hs_code}
\alias{normalize_hs_level}
\alias{read_hs_isic_crosswalk}
\alias{read_gb_isic_crosswalk}
\alias{read_gb_crosswalk_csvs}
\alias{standardize_gb_pairs}
\alias{write_gb_crosswalk_csvs}
\title{Crosswalk Chinese GB Industry Classifications Across Years}
\description{
Utilities for cleaning, building, and composing Chinese recommended national
standard (Guobiao/Tuijian, GB/T) 4754 industry classification crosswalks. The
package standardizes adjacent pairwise crosswalks into a long format and
composes them across years.
}
\usage{
normalize_gb_code(x, width = 4)
normalize_gb_for_level(x, level = c("S", "M", "L"))
normalize_isic_code(x, level = c("S", "M", "L"))
normalize_hs_level(level = c("HS6", "HS4", "HS2"))
normalize_hs_code(x, level = c("HS6", "HS4", "HS2"))
detect_hs_level(codes)
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
convert_gb_codes(codes, from_year = NULL, to_year = NULL, level = NULL,
                 pairs = load_gb_crosswalks(),
                 years = c(1986, 1994, 2002, 2011, 2017),
                 unmatched = NA_character_)
detect_gb_year(codes, pairs = load_gb_crosswalks(),
               years = c(1986, 1994, 2002, 2011, 2017),
               level = c("auto", "S", "M", "L"),
               ties = c("all", "first"), details = FALSE)
convert_gb_column(data, column, pairs = load_gb_crosswalks(), from_year, to_year,
                  level = c("S", "M", "L"), output_col = NULL,
                  years = c(1986, 1994, 2002, 2011, 2017),
                  unmatched = NA_character_)
convert_gb_to_isic(codes, gb_year = NULL, gb_level = NULL,
                   isic_level = c("S", "M", "L"), isic_revision = "3",
                   crosswalk = load_gb_isic_crosswalk(),
                   pairs = load_gb_crosswalks(),
                   years = c(1986, 1994, 2002, 2011, 2017),
                   unmatched = NA_character_)
convert_gb_to_hs(codes, gb_year = NULL, gb_level = NULL,
                 hs_level = c("HS6", "HS4", "HS2"),
                 hs_system = "HS Combined", isic_revision = "3",
                 isic_level = c("S", "M", "L"),
                 gb_isic = load_gb_isic_crosswalk(),
                 hs_isic = load_hs_isic_crosswalk(),
                 pairs = load_gb_crosswalks(),
                 years = c(1986, 1994, 2002, 2011, 2017),
                 unmatched = NA_character_)
convert_hs_to_gb(codes, hs_level = NULL, gb_year = 2002,
                 gb_level = c("M", "S", "L"),
                 hs_system = "HS Combined", isic_revision = "3",
                 isic_level = c("S", "M", "L"),
                 hs_isic = load_hs_isic_crosswalk(),
                 gb_isic = load_gb_isic_crosswalk(),
                 pairs = load_gb_crosswalks(),
                 years = c(1986, 1994, 2002, 2011, 2017),
                 unmatched = NA_character_)
standardize_gb_pairs(pairs)
write_gb_crosswalk_csvs(pairs, dir, prefix = "gb", include_combined = TRUE)
read_gb_crosswalk_csvs(path)
read_gb_isic_crosswalk(path)
read_hs_isic_crosswalk(path)
gb_crosswalk_path(file = "gb_all_pairs.csv")
gb_isic_crosswalk_path(file = "gb_2002_isic3.csv")
hs_isic_crosswalk_path(file = "hs_combined_isic3.csv")
gb_raw_crosswalk_path(file = NULL)
load_gb_crosswalks(path = gb_crosswalk_path())
load_gb_isic_crosswalk(path = gb_isic_crosswalk_path())
load_hs_isic_crosswalk(path = hs_isic_crosswalk_path())
build_gb_1986_1994(path, sheet = 1)
build_gb_1994_2002(path)
build_gb_2002_2011(path, sheet = 1)
build_gb_2002_isic(path)
build_hs_combined_isic3(path)
build_gb_2011_2017(path, sheet = 1, old_col = NULL, new_col = NULL)
}
\arguments{
\item{x, code, codes}{Character or numeric GB, ISIC, or HS codes, depending on the function.}
\item{width}{Target code width for left-zero padding.}
\item{level, gb_level, isic_level}{One of \code{"S"} for 4-digit, \code{"M"} for 3-digit, \code{"L"} for 2-digit codes, \code{"auto"} where supported, or \code{NULL} in \code{convert_gb_codes()} and \code{convert_gb_to_isic()} to infer the GB level from the input vector.}
\item{hs_level}{HS output/input level. One of \code{"HS6"}, \code{"HS4"}, or \code{"HS2"}. In \code{convert_hs_to_gb()}, \code{NULL} infers the level from code length.}
\item{hs_system}{HS classification system to use. The bundled HS file is specifically \code{"HS Combined"}, from the source column \code{HS - Combined Product Code}; it is not a single HS1996, HS2002, HS2007, HS2012, or HS2017 vintage.}
\item{isic_revision}{ISIC revision to use. The bundled GB-ISIC and HS-ISIC links are specifically for ISIC Revision \code{"3"}.}
\item{ties}{Whether to return all tied best matches or just the first one.}
\item{details}{Whether to return all candidate-year scores as well as the best match.}
\item{data}{A data frame containing crosswalk columns or a user data frame.}
\item{column}{Name of the input code column to convert.}
\item{year, from_year, to_year, gb_year}{GB classification years. In \code{convert_gb_codes()}, \code{to_year} is required and \code{from_year} can be \code{NULL} to infer it from the input vector. In \code{convert_gb_to_isic()} and \code{convert_gb_to_hs()}, \code{gb_year} can be \code{NULL} to infer it from the input vector.}
\item{s_col, from_col, to_col, old_col, new_col}{Column names for source and target codes.}
\item{to_all_col, parent_col}{Names for collapsed target and dominant parent columns.}
\item{parent_digits, digits}{Number of prefix digits used for parent codes.}
\item{threshold}{Share required for a dominant parent prefix.}
\item{special_cutoff, special_suffix}{Optional fallback rule for service-sector-style parent codes.}
\item{levels}{Levels to include when standardizing a pairwise crosswalk.}
\item{source_pair}{Optional source label.}
\item{pairs}{A standard pair table or list of pair tables. Defaults to the package-shipped merged CSV in \code{convert_gb_column()} and is used to route non-2002 GB vintages through GB2002 in ISIC/HS helpers.}
\item{crosswalk, gb_isic, hs_isic}{GB-ISIC or HS-ISIC crosswalk tables. The defaults use package-shipped CSVs.}
\item{file}{Package-shipped filename under \code{extdata} or \code{raw-crosswalks}.}
\item{dir}{Directory where CSV files should be written.}
\item{prefix}{Filename prefix for exported CSV files.}
\item{include_combined}{Whether to also write one combined all-pairs CSV.}
\item{output_col}{Name of the appended converted-code column.}
\item{years}{Ordered vector of supported years.}
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
convert_gb_codes(c("572", "593", "843"), from_year = 2017, to_year = 2011, level = "M")
convert_gb_codes(c("572", "593", "843"), to_year = 2011)
convert_gb_to_isic(c("0111", "0112"), gb_year = 2002, gb_level = "S")
convert_gb_to_hs("152", gb_year = 2002, gb_level = "M", hs_level = "HS2", isic_level = "M")
convert_hs_to_gb(c("010110", "010111"), gb_year = 2002, gb_level = "M")
}
