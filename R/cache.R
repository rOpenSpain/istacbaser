#' Cached information from the ISTAC API
#'
#' This data is a cached result of the accesibles tables using the ISTAC API.
#' By default functions \code{\link{istac}} and \code{\link{istac_search}} use this
#' data for the \code{cache} parameter.
#'
#' This data was updated on November 18, 2017
#'
#' @format A data frame with 5257 rows and 11 variables:
#'
#' \describe{
#'   \item{tema}{Main topic}
#'   \item{subtemaI}{Subtopic}
#'   \item{subtemaII}{third level of the topic}
#'   \item{datos publicadosI}{fourth level of the topic}
#'   \item{datos publicadosII}{fifth level of the topic}
#'   \item{apijson}{url of the table}
#'   \item{lista_tablas}{tables list}
#'   \item{titulo}{title}
#'   \item{origen}{source}
#'   \item{encuesta}{Survey title}
#'   \item{ID}{Identificator}
#'   ...
#' }
#'
#'
"cache"
