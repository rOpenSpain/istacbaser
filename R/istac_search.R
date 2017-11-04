#' Search information about data available through ISTAC API
#'
#' This funcion allows finds those ID that match the search term and
#' returns a data frame with results
#'
#' @param pattern Character string or regular expression to be matched.
#' @param fields Character vector of column names through which to search
#' @param extra if \code{FALSE}, only the ID and Title are returned,
#' if \code{TRUE}, all columns of the \code{cache} are returned.
#' @param cache Data frame with metadata about API and ISTAC information.
#' @return Data frame with metadata that match the search term.
#'
#' @examples
#' istac_search(pattern = "Superficie")
#' istac_search(pattern = "Superficie", extra = TRUE)
#'
#' istac_search(pattern = "medio ambiente", fields = "Estadísticas por temas")
#' istac_search(pattern = "medio ambiente", fields = "Estadísticas por temas", extra = TRUE)
#'
#' @export
istac_search <- function(pattern, fields = "title", extra = TRUE, cache){

  if (missing(cache)) cache <- istacr::cache


  match_index <- sort(unique(unlist(sapply(fields, FUN = function(i)
    grep(pattern, cache[, i], ignore.case = TRUE), USE.NAMES = FALSE)
  )))


  if (length(match_index) == 0) warning(paste0("no matches were found for the search term ", pattern,
                                               ". Returning an empty data frame."))


  if (extra) {

    match_df <-  cache[match_index, ]

  } else {

    match_df <- cache[match_index, c("title", "namecode")]

  }


  match_df

}
