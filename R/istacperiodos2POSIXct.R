istacperiodos2POSIXct <- function(df, date_col) {
  
  if (requireNamespace("lubridate", versionCheck = list(op = ">=", version = "1.5.0"),
                       quietly = TRUE)) {
    
    if (nrow(df) == 0) {
      
      # hackish way to support the POSIXct parameter with 0 rows returned
      df_ct <- as.data.frame(matrix(nrow = 0, ncol = 2), stringsAsFactors = FALSE)
      names(df_ct) <- c("date_ct", "periodicidad")
      
      df <- cbind(df, df_ct)
      
      return(df)
    }
    
    # add new columns
    df$date_ct <- as.Date.POSIXct(NA)
    df$periodicidad <- NA
    
    date_vec <- df[ , date_col]
    
    # annual ----------
    annual_obs_index <- grep("[M|Q|D]", date_vec, invert = TRUE)
    
    if (length(annual_obs_index) > 0) {
      
      annual_posix <- as.Date(date_vec[annual_obs_index], "%Y")
      annual_posix_values <- lubridate::floor_date(annual_posix, unit = "year")
      
      df$date_ct[annual_obs_index] <- annual_posix_values
      df$periodicidad[annual_obs_index] <- "anual"
      
    }
    
    
    
    # quarterly ----------
    quarterly_obs_index <- grep("Q", date_vec)
    
    if (length(quarterly_obs_index) > 0) {
      
      # takes a little more work
      qtr_obs <- strsplit(as.character(date_vec[quarterly_obs_index]), "Q")
      qtr_df <- as.data.frame(matrix(unlist(qtr_obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
      names(qtr_df) <- c("year", "qtr")
      qtr_df$month <- as.numeric(qtr_df$qtr) * 3 # to turn into the max month
      qtr_format_vec <- paste0(qtr_df$year, "01", qtr_df$month) # 01 acts as a dummy day
      
      quarterly_posix <- lubridate::ydm(qtr_format_vec)
      quarterly_posix_values <- lubridate::floor_date(quarterly_posix, unit = "quarter")
      
      df$date_ct[quarterly_obs_index] <- quarterly_posix_values
      df$periodicidad[quarterly_obs_index] <- "cuatrimestral"
      
    }
    
  } else {
    
    warning("Required Namespace 'lubridate (>= 1.5.0)' not available. This option is being ignored")
    
  }
  
  df
}