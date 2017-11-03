
# prueba git

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
