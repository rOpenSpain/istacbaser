#' Download data from the ISTAC API
#'
#' This function downloads the requested information using the ISTAC API.
#'
#' @param istac_table Character string with the namecode of the table requested.
#' This namecode corresponds to the \code{namecode} column from \code{\link{cache}}.
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
#' @param freq Character String. For fetching quarterly ("Q"), monthly("M") or yearly ("Y") values.
#'  Currently works along with \code{mrv}.
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



  if (POSIXct){

    date_index <- names(out_df) %in% c("A\u00F1os","Per\u00EDodo")
    vble_date <- names(out_df)[date_index]

    if (any(date_index)){
      out_df <- istacperiodos2POSIXct(out_df, vble_date)
      # Creo qu ela siguiente línea no es necesario en nuestro caso.
      #if (missing(startdate) != missing(enddate)) stop("Using either startdate or enddate requires supplying both. Please provide both if a date range is wanted")

      if (missing(startdate)) startdate <- min(out_df$fecha) else startdate <- as.Date(startdate,"%d/%m/%Y")
      if (missing(enddate)) enddate <- max(out_df$fecha) else enddate <- as.Date(enddate,"%d/%m/%Y")

        # Habrá que comprobar fechas. Formato %d/%m/%Y o %d-%m%-%Y. Comprobar si cumple estos formatos
        # Habrá que comprobar si sale de rango de fechas. Por ahora vamos a suponer que todo sale bien. 171104
        index_date <- out_df$fecha >= startdate & out_df$fecha <= enddate
        out_df <- out_df[index_date, ]

        # check mrv ----------
        if (!missing(mrv)) {

          if (!is.numeric(mrv)) stop("If supplied, mrv must be numeric")

          if(!missing(stardate) == !missing(mrv)) stop("You can supply only a startdate and enddate or mrv but not both")

          if (missing(freq)){
            periodon <- min(match(c("anual","cuatrimestral","mensual"),out_df$periodicidad),na.rm = TRUE)
            periodo <- c("anual","cuatrimestral","mensual")[periodon]
            enddate <- max(out_df$fecha)
            startdate <-  min(out_df$fecha)
            startdate_mrv <- switch(periodo,
                               "anual" = enddate - lubridate::years(mrv),
                               "cuatrimestral" = enddate - lubridate::months(4*mrv),
                               "mensual" = endadte - lubridate::months(mrv))
            stardate <- ifelse(startdate < startdate_mrv, startdate_mrv, startdate)
            index_date <- out_df$fecha >= startdate & out_df$fecha <= enddate
            out_df <- out_df[index_date, ]

          }

        }

      } else
        warning("The data is no time dependence.")


    }


  out_df
}
