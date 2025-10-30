#' Life table values for United States, Females, 1935 and 1995
#'
#' A subset of data from 'Life Tables for the United States Social Security Area, 1900-2080' for United States women born in 1935 and 1995.
#'
#' @format
#' A data frame with 19 rows and 7 columns:
#' \describe{
#'   \item{Age}{ordered age groups as factor type}
#'   \item{nm1x}{age specific death rate in the age group x; x + n in the initial time period ‘1935’}
#'   \item{l1x}{number of persons alive at exact age x, in the initial time period ‘1935’ expressed as decimal form and as a proportion of the starting the age group}
#'   \item{e1x}{expectation of life at exact age x, in the initial time period ‘1935’}
#'   \item{nm2x}{age specific death rate in the age group x; x + n in the latter time period ‘1995’}
#'   \item{l2x}{number of persons alive at exact age x, in the latter time period ‘1995’ expressed as decimal form and as a proportion of the starting the age group}
#'   \item{e2x}{expectation of life at exact age x, in the latter time period ‘1995’}
#'
#'  where *n* = length of the age interval
#' }
#' @source Murthy, P.K. (2005). A comparison of different methods for decomposition of changes in expectation of life at birth and differentials in life expectancy at birth. Demographic Research, 12, pp.141–172. doi: \doi{10.4054/demres.2005.12.7}, Appendix 1, available at <https://www.demographic-research.org/volumes/vol12/7/12-7.pdf>
#' @source Bell, F.C., A.H. Wade and S.C. Goss, (1992), Life Tables for the United States Social Security Aria: 1900-2080. Baltimore, Maryland, US Social Security Administration Office of the Actuary, Actuarial Study No.107, \[nmx, and ex columns were calculated from lx; nLx and Tx columns given in: Preston, S.H., P.Heuveline and M.Guillot (2001) Demography: Measuring and Modeling Population Processes, United Kingdom: Blackwell Publishers Ltd., Box: 3.4, P.65\]

"us_females"

#' Age and Cause Decomposition of Difference in Life Expectancies at Birth, India and China, males, 1990
#'
#' A subset of data from The Global Burden of Disease Study 1996.
#'
#' @format
#' A data frame with 7 rows and 10 columns:
#' \describe{
#'   \item{Age}{ordered age groups as factor type}
#'   \item{India_nmx}{all-cause mortality rate between ages x and x + n for males in India, 1990}
#'   \item{India_CD}{proportion of deaths from communicable diseases between ages x and x + n for males in India, 1990}
#'   \item{India_NCD}{proportion of deaths from non-communicable diseases between ages x and x + n for males in India, 1990}
#'   \item{India_Injuries}{proportion of deaths from injuries between ages x and x + n for males in India, 1990}
#'   \item{China_nmx}{all-cause mortality rate between ages x and x + n for males in China, 1990}
#'   \item{China_CD}{proportion of deaths from communicable diseases between ages x and x + n for males in China, 1990}
#'   \item{China_NCD}{proportion of deaths from non-communicable diseases between ages x and x + n for males in China, 1990}
#'   \item{China_Injuries}{proportion of deaths from injuries between ages x and x + n for males in China, 1990}
#'   \item{nDx}{contribution of all-cause mortality differences in groups 1 and 2 in age groups x to x + n. Computationally the same as the total effect column computed from `decomp_LE()`.}
#'
#'  where *n* = length of the age interval
#' }
#' @source Murray, C. J. and A. D. Lopez, 1996. *The Global Burden of Disease: A Comprehensive Assessment of Mortality and Disability from Diseases, Injuries, and Risk Factors in 1990 and Projected to 2020*. Boston, Harvard University, School of Public Health.

"india_china_males_1990"
