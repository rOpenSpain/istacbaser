codes2labes <- function(datos_lista, df){

  variables <- datos_lista$categories$variable
  codigos <- datos_lista$categories$codes
  names(codigos) <- variables
  labels <- datos_lista$categories$labels
  names(labels) <- variables
  tempvar <- variables[variables %in% c("A\u00F1os","Periodos")]





  col_changes <- lapply(variables[!(variables %in% c("A\u00F1os","Periodos"))], function(x){
    columna <- df[[x]]
    c_cambio <- labels[[x]]

    c_cambio <- gsub("^ ","",c_cambio)
    c_cambio <- gsub(" $","",c_cambio)


    names(c_cambio) <- codigos[[x]]

    col_match <- match(columna, names(c_cambio))
    changes <- c_cambio[col_match]
  })

  df_final <- as.data.frame(do.call(cbind,col_changes),stringsAsFactors = FALSE)
  names(df_final) <- variables[!(variables %in% c("A\u00F1os","Periodos"))]

  if(length(tempvar) > 0)
    df_final[tempvar] <- df[tempvar]

  df_final["valor"] <- df["valor"]

  rownames(df_final) <- NULL

  df_final
}
