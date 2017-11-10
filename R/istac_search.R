#' Search information about data available through ISTAC API
#'
#' This funcion allows finds those tables that match the search term and
#' returns a data frame with results
#'
#' @param pattern Character string or regular expression to be matched.
#' @param fields Character vector of column name through which to search.
#' @param extra if \code{FALSE}, only the namecode and title are returned,
#' if \code{TRUE}, all columns of the \code{cache} are returned.
#' @param cache Data frame with metadata about API and ISTAC information.
#' @return Data frame with metadata that match the search term.
#'
#' @examples
#' istac_search(pattern = "superficie")
#' istac_search(pattern = "superficie", extra = TRUE)
#'
#' istac_search(pattern = "medio ambiente", fields = "Estadísticas por temas")
#' istac_search(pattern = "medio ambiente", fields = "Estadísticas por temas", extra = TRUE)
#'
#' # with regular expression operators
#' # 'islote' OR 'roque'
#' istac_search(pattern = "islote|roque")
#'
#' @export
istac_search <- function(pattern, fields = "titulo", extra = TRUE, exact = FALSE, cache){

  if (missing(cache)) cache <- istacr::cache


  match_index <- sort(unique(unlist(sapply(fields, FUN = function(i)
    if(!exact) grep(pattern, cache[, i], ignore.case = TRUE)
    else grep(paste0("^",pattern,"$"), cache[, i], ignore.case = TRUE),
    USE.NAMES = FALSE)
  )))


  if (length(match_index) == 0) warning(paste0("no matches were found for the search term ", pattern,
                                               ". Returning an empty data frame."))


  if (extra) {

    match_df <-  cache[match_index, ]

  } else {

    match_df <- cache[match_index, c("titulo", "ID")]

  }


  match_df

}
