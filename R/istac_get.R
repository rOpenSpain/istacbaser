#' Call the ISTAC API and return a formatted data frame
#'
#' This function calls the ISTAC API, capture the data in json
#' format and return a list with data in json format and a formatted data frame.
#'
#' # To be used inside of \code{\link{istac}}
#'
#' @param indicador A character string. The \code{ID} code of the requested table.
#' Normally gived by the \code{\link{istac_search}} function.
#' @return A list with data in json format and a formatted data frame.
#' @examples
#' # Percentiles de renta disponible (año anterior al de la entrevista) por hogar en Canarias y años.
#' istac_get("soc.cal.enc.res.3637")
istac_get <- function(indicador){

  tabla <- istac_search(pattern = indicador, fields = "ID", cache = istacr::cache, exact = TRUE)

  url.datos <- tabla$apijson

  datos_lista <- jsonlite::fromJSON(readLines(url.datos,
                                    warn = FALSE,
                                    encoding = "UTF-8"), simplifyDataFrame = TRUE)



  df <- unlist(datos_lista$data$dimCodes)
  df <- as.data.frame(matrix(df, ncol = length(datos_lista$data$dimCodes[[1]]), byrow = TRUE),
                      stringsAsFactors = FALSE)
  names(df) <- datos_lista$categories$variable
  tvalor <- gsub("\\.","",datos_lista$data$Valor)
  tvalor <- gsub(",",".",tvalor)
  df["valor"] <- as.numeric(tvalor)



  list(datos_lista = datos_lista, df = df)

}
