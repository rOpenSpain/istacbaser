#' Download data from the ISTAC API
#'
#' This function downloads the requested information using the ISTAC API.
#'
#' @param istac_table Character string with the \code{ID} of the table requested.
#' This \code{ID} corresponds to the \code{ID} column from \code{\link{cache}}.
#' @param islas Character vector of islands name requested. Default value is special code of \code{all}.
#' Valid values for islands are: El Hierro, La Palma, La Gomera, Tenerife, Gran Canaria, Fuerteventura and Lanzarote.
#' @param label if \code{FALSE}, the data frame returned has the codes used in ISTAC API,
#' if \code{TRUE}, the data frame returned has the labels used in ISTAC API. Default value is \code{FALSE}.
#' @param POSIXct if \code{TRUE}, additonal columns \code{fecha} and \code{periodicidad} are added.
#'  \code{fecha} converts the default date into a \code{\link[base]{POSIXct}}. \code{periodicidad}
#'  denotes the time resolution that the date represents.  Useful for \code{freq} filter,  If \code{FALSE}, these fields are not added.
#' @param startdate Numeric. Must be in \%Y form (i.e. four digit year).
#' @param enddate Numeric. Must be in \%Y form (i.e. four digit year).
#' @param freq Character String. For fetching yearly ("anual"), biannual ("semestral"), quaterly ("trimestral"), monthly("mensual"), bi-weekly("quincenal"), weekly("semanal") values.
#'  Currently works along with \code{mrv}.
#' @param mrv Numeric. The number of Most Recent Values to return. A replacement of \code{startdate} and \code{enddate},
#' this number represents the number of observations you which to return starting from the most recent date of collection.
#' @param cache Data frame with tables from ISTAC API.
#' @return Data frame with all available requested data.
#' @note The \code{POSIXct} parameter requries the use of \code{\link[lubridate]{lubridate}} (>= 1.5.0). All dates
#'  are rounded down to the floor. For example a value for the year 2016 would have a \code{POSIXct} date of
#'  \code{2016-01-01}. If this package is not available and the \code{POSIXct} parameter is set to \code{TRUE},
#'  the parameter is ignored and a \code{warning} is produced.
#'
#'  \code{startdate}, \code{enddate}, \code{freq}, \code{mrv} with \code{POSISXct}=\code{FALSE} are ignored when POSCIXct is set to FALSE.
#' and a \code{warning} is produced.
#'
#'
#' @examples
#' # Percentiles de renta disponible (año anterior al de la entrevista) por hogar en Canarias y años.
#' istac("soc.cal.enc.res.3637")
#'
#' # query using startdate and enddate
#' # Percentiles de renta disponible (año anterior al de la entrevista) por hogar en Canarias y años.
#' istac("soc.cal.enc.res.3637", POSIXct = TRUE, startdate = 2010, enddate = 2015)
#'
#'
#' # query using \code{islas} filter
#' # Población según sexos y edades año a año. Islas de Canarias y años.
#' istac("dem.pob.exp.res.35", islas = "Fuerteventura")
#'
#' # if you want the most recent values
#' istac(dem.pob.exp.res.35", mrv = 4)
#'
#'
#'
#' @export
#'
istac <- function(istac_table, islas = "all", label = TRUE, POSIXct = FALSE, startdate, enddate, freq, mrv,  cache){


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
    # if(!("islas" %in% tolower(names(out_df))))
    if(!(any(grepl("islas",tolower(names(out_df))))))
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
      if (!("all" %in% islas))
        out_df <- out_df[tolower(out_df$Islas) %in% tolower(islas), ]


    }





  }





  out_df
}



### quitar nombre fila cuando label = true
