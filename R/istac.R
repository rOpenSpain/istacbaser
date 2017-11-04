#' Download data from the ISTAC API
#'
#' This function downloads the requested information using the ISTAC API.
#'
#' @param istac_table Character string with the ID code of the table requested.
#' This ID code corresponds to the \code{namecode} column from \code{\link{cache}}.
#' @param islas Character vector of islands codes requested. Default value is special code of \code{all}.
#' @param label if \code{FALSE}, the data frame returned has the codes used in ISTAC API,
#' if \code{TRUE}, the data frame returned has the labels used in ISTAC API. Default value is \code{FALSE}.
#' @param startdate Numeric or character. If numeric it must be in \%Y form (i.e. four digit year).
#' For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#' and for quarterly data, "2016Q1". This also accepts a special value of "YTD", useful for more frequently
#' updated subannual indicators.
#' @param enddate Numeric or character. If numeric it must be in \%Y form (i.e. four digit year).
#' For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#' and for quarterly data, "2016Q1".
#' @param mrv Numeric. The number of Most Recent Values to return. A replacement of \code{startdate} and \code{enddate},
#' this number represents the number of observations you which to return starting from the most recent date of collection.
#' Useful in conjuction with \code{freq}.
#' @return Data frame with all available requested data.
#'
#' @export
istac <- function(istac_table, islas = "all", label = FALSE, startdate, enddate, freq, mrv, POSIXct = FALSE, cache){


  if (missing(cache)) cache <- istacr::cache

  # check table ----------

  cache_tables <- cache$namecode


  table_index <- istac_table %in% cache_tables


  if (!table_index) stop("'istac_table' parameter has no valid values. Please check documentation for valid inputs")


  out_df <- istac_get(istac_table)

  # check POSIxct --------



  if (!POSIXct)
    out_df
  else {

    date_index <- names(out_df) %in% c("A\u00F1os","Per\u00EDodo")
    vble_date <- names(out_df)[date_index]

    if(any(date_index))
      out_df <- istacperiodos2POSIXct(out_df, vble_date)
    else
      warning("The data is no time dependence.")

if(label) code2labs

  }



  # check dates ----------

  #if (POSIXct & (!missing(startdate) | ! missing(enddate))) stop("stardate and endate are possible only with POSIXct = TRUE")
  #if (missing(startdate) != missing(enddate))
  #  stop("Using either startdate or enddate requries supplying both. Please provide both if a date range is wanted")
  #else
  # Falta comprobar si stardate y endate están en formato correcto
  #   out_df <- out_df[out_df$date_ct >= as.Date(stardate, "%d-%m-%Y") & out_df$date_ct <= as.Date(enddate, "%d-%m-%Y"), ]



  out_df
}
