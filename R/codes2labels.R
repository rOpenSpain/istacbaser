codes2labes <- function(datos_lista, df){
  
  variables <- datos_lista$categories$variable
  codigos <- datos_lista$categories$codes
  names(codigos) <- variables
  labels <- datos_lista$categories$labels
  names(labels) <- variables
  
  
  
  
  
  col_changes <- lapply(variables, function(x){
    columna <- df[[x]]
    c_cambio <- labels[[x]]
    names(c_cambio) <- codigos[[x]]
    
    col_match <- match(columna, names(c_cambio))
    changes <- c_cambio[col_match] 
  })
  
  df_final <- as.data.frame(do.call(cbind,col_changes),stringsAsFactors = FALSE)
  names(df_final) <- variables
  df_final["valor"] <- df$valor
}
