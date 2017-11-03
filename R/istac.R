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
