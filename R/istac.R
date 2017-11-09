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
istac <- function(istac_table, islas = "all", label = TRUE, startdate, enddate, freq, mrv, POSIXct = FALSE, cache){


  if (missing(cache)) cache <- istacr::cache

  # check table ----------

  cache_tables <- cache$ID


  table_index <- istac_table %in% cache_tables


  if (!table_index) stop("'istac_table' parameter has no valid values. Please check documentation for valid inputs.")


  out <- istac_get(istac_table)


  # check label ---------
  if(label == TRUE){
    out_df <- codes2labes(out$datos_lista, out$df)

  } else
    out_df <- out$df

  # check POSIxct --------



  if (POSIXct){

    date_index <- names(out_df) %in% c("A\u00F1os","Periodos")
    vble_date <- names(out_df)[date_index]

    if (any(date_index)){
      out_df <- istacperiodos2POSIXct(out_df, vble_date)
      # Creo que la siguiente línea no es necesaria en nuestro caso.
      #if (missing(startdate) != missing(enddate)) stop("Using either startdate or enddate requires supplying both. Please provide both if a date range is wanted")

      if (missing(startdate)) startdate_db <- min(out_df$fecha) else startdate_db <- as.Date(paste0("01/01/",startdate),"%d/%m/%Y")
      if (missing(enddate)) enddate_db <- max(out_df$fecha) else enddate_db <- as.Date(paste0("01/01/",enddate),"%d/%m/%Y")

        # Habrá que comprobar fechas. Formato %d/%m/%Y o %d-%m%-%Y. Comprobar si cumple estos formatos
        # Habrá que comprobar si sale de rango de fechas. Por ahora vamos a suponer que todo sale bien. 171104
        index_date <- out_df$fecha >= startdate_db & out_df$fecha <= enddate_db
        out_df <- out_df[index_date, ]

        # check mrv ----------
        if (!missing(mrv)) {

          if (!is.numeric(mrv)) stop("If supplied, mrv must be numeric")

          if(!missing(startdate)) stop("You can supply only a startdate and enddate or mrv but not both")


            periodon <- min(match(c("anual","semestral","trimestral","mensual","quincenal","semanal"),out_df$periodicidad),na.rm = TRUE)
            periodo <- c("anual","semestral","trimestral","mensual","quincenal","semanal")[periodon]
            enddate_db <- max(out_df$fecha)
            startdate_db <-  min(out_df$fecha)
            startdate_mrv <- switch(periodo,
                               "anual" = enddate_db - lubridate::years(mrv-1),
                               "semestral" = enddate_db - lubridate::months(6*mrv-1),
                               "trimestral" = enddate_db - lubridate::months(4*mrv-1),
                               "mensual" = enddate_db - lubridate::months(mrv-1),
                               "quincenal" = enddate_db - lubridate::weeks(mrv*2-1),
                               "semanal" = enddate_db - lubridate::weeks(mrv-1))

            startdate_db <- if(startdate_db < startdate_mrv) startdate_mrv else startdate_db
            index_date <- out_df$fecha >= startdate_db & out_df$fecha <= enddate_db
            out_df <- out_df[index_date, ]


         }

        if(!missing(freq)){
          if(!(freq %in% c("anual","semestral","trimestral","mensual","quincenal","semanal")))
            stop ("freq must be 'anual','semestral','trimestral','mensual','quincenal' or 'semanal'.")

          if(!(freq %in% out_df$periodicidad)){
            warning(paste0(freq)," is not aviable in granularity of data. Showing all granularities")
            out_df
            } else
              out_df <- out_df[out_df$periodicidad == freq, ]

        }

      } else
        warning("The data is no time dependent.")


  } else {
      if(!missing(startdate) | !missing(enddate) | !missing(mrv) | !missing(freq))
        warning("startdate, enddate, mrv, freq are ignored when POSCIXct is set to FALSE.")
  }


  if(!missing(islas)){
    if(!("islas" %in% tolower(names(out_df))))
      warning("There is no 'Islas' column in the database to filter")
    else{
      if(!label){
        warning("If label = FALSE the parameter islas will set to 'all'")
        islas <- 'all'
        }

      if(!any(tolower(islas) %in% c("all","canarias","lanzarote","fuerteventura","gran canaria","tenerife","la gomera","la palma", "el hierro"))){
        warning("islas must be 'all','canarias','lanzarote','fuerteventura','gran canaria','tenerife','la gomera','la palma' or 'el hierro'. 'all' will be taken instead.")
        islas = "all"
      }
      if (islas != "all")
        out_df <- out_df[tolower(out_df$Islas) %in% tolower(islas), ]


    }





  }





  out_df
}



### quitar nombre fila cuando label = true
