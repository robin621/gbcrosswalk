## Follow-up CRAN submission

This is a follow-up submission for a package already on CRAN.

In this version I have addressed CRAN feedback by:

* removing the redundant "Tools for" opening from the Description field;
* explaining the acronyms used in the Description field:
  * GB/T: Guobiao/Tuijian, the Chinese recommended national standard prefix;
  * ISIC: International Standard Industrial Classification of All Economic
    Activities;
  * HS: Harmonized System.

## Test environments

* Windows 11 x64, R 4.5.1

## R CMD check results

0 errors | 0 warnings | 1 note

* Days since last update: 0.
  This follow-up is being submitted soon after the initial CRAN release to
  address CRAN feedback on the Description field.

## Notes

The public GitHub repository includes a large source PDF for provenance. The PDF
is excluded from CRAN-style package builds with `.Rbuildignore`; the package
ships the standardized CSV crosswalks and compact raw crosswalk tables required
for normal use.
