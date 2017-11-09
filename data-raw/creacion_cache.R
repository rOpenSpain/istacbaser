library(readxl)
library(purrr)
library(tidyr)
library(jsonlite)
library(dplyr)
metadata <- read_xlsx("C:/Users/arama/Dropbox/170126 Trabajos José Manuel Cazorla/API ISTAC/Metadatos Istac completo2.xlsx",
                      col_types = rep("text",9))

# Vamos a trabajar solo con las primeras 15 tablas para empezar a hacer pruebas. Este será nuestro cache

pruebas <- head(metadata,50)
if (!all(is.na(pruebas$error))) pruebas <- pruebas[pruebas$error != "ERROR", ]

pruebas[,"error"] <- NULL

# Creamos nombre de tabla

columna <- apply(pruebas[,1:4],2,substr,1,3) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  setNames(paste0("v",1:4)) %>%
  mutate(id = row_number()) %>%
  apply(1,paste0,collapse=".") %>%
  tolower() %>%
  gsub(" ","",.)

pruebas$ID <- columna

lista <- pruebas$apijson %>%
  map(~ .x %>%
        readLines(warn = FALSE, encoding = "UTF-8") %>%
        fromJSON(simplifyDataFrame = TRUE)) %>%
  map_df(`[`, c("title","source","surveyTitle")) %>%
  setNames(c("titulo","origen","encuesta"))

cache <- cbind(pruebas[, -6],lista)

save(cache, file = "data/cache1.Rdata")


