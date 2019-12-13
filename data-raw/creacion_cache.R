library(readxl)
library(purrr)
library(tidyr)
library(jsonlite)
library(dplyr)

metadata <- read_xlsx("data-raw/Metadatos_Istac.xlsx")

if (!all(is.na(metadata$error))) metadata <- metadata[!(!is.na(metadata$error) & metadata$error == "ERROR"), ]

metadata[,"error"] <- NULL

# Creamos nombre de tabla

columna <- apply(metadata[,1:4],2,substr,1,3) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  setNames(paste0("v",1:4)) %>%
  mutate(id = row_number()) %>%
  apply(1,paste0,collapse=".") %>%
  tolower() %>%
  gsub(" ","",.)

metadata$ID <- columna

safe_scrap <- safely(~ .x %>%
                       readLines(warn = FALSE, encoding = "UTF-8") %>%
                       fromJSON(simplifyDataFrame = TRUE))

lista <- metadata$apijson %>%
  map(safe_scrap)


tablasok <- map(lista,"error") %>% map_lgl(is.null)

df <- map(lista[tablasok], "result") %>% map_df(`[`, c("title","source","surveyTitle"))
names(df) <- c("titulo","origen","encuesta")



cache2 <- cbind(metadata[tablasok, -6],df)

save(cache, file = "data/cache.Rdata")


####








