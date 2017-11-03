library(readxl)
library(purrr)
library(tidyr)
library(jsonlite)
library(dplyr)
metada <- read_xlsx("C:/Users/arama/Dropbox/170126 Trabajos José Manuel Cazorla/API ISTAC/Metadatos 2.xlsx")

# Vamos a trabajar solo con las primeras 15 tablas para empezar a hacer pruebas. Este será nuestro cache

pruebas <- head(metada,15)
pruebas <- pruebas[,-8] # Al importar aparece una variable X__1 que eliminamos

# Creamos nombre de tabla

columna <- apply(pruebas[,1:4],2,substr,1,3) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  setNames(paste0("v",1:4)) %>%
  group_by(v1,v2,v3,v4) %>%
  mutate(id = row_number()) %>%
  apply(1,paste,collapse=".") %>%
  tolower()

pruebas$namecode <- columna

lista <- pruebas$`API JSON` %>%
  map(~ .x %>%
        readLines(warn = FALSE, encoding = "UTF-8") %>%
        fromJSON(simplifyDataFrame = TRUE)) %>%
  map_df(`[`, c("title","source","surveyTitle"))

cache <- cbind(pruebas[,-6],lista)
save(cache, data/cache)

