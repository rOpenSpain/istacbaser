istac_get <- function(indicador){

  tabla <- istac_search(pattern = indicador, fields = "namecode", cache = cache)

  url.datos <- tabla$`API JSON`

  datos_lista <- jsonlite::fromJSON(readLines(url.datos,
                                    warn = FALSE,
                                    encoding = "UTF-8"), simplifyDataFrame = TRUE)



  df <- unlist(datos_lista$data$dimCodes)
  df <- as.data.frame(matrix(df, ncol = length(datos_lista$data$dimCodes[[1]]), byrow = TRUE),
                      stringsAsFactors = FALSE)
  names(df) <- datos_lista$categories$variable
  df["valor"] <- as.numeric(datos_lista$data$Valor)






  # df <- datos_lista$data$dimCodes %>%
  #   unlist() %>%
  #   matrix(ncol = length(datos_lista$data$dimCodes[[1]]), byrow = TRUE) %>%
  #  as.data.frame() %>%
  #  setNames(nm = datos_lista$categories$variable) %>%
  #  mutate(valor = datos_lista$data$Valor)

  df

}
