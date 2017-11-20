#' Add a POSIXct dates to a ISTAC API return
#'
#' Add a POSIXct date column as well as a column with the
#' appropreiate granularity to a ISTAC API return
#'
#' @param df data frame returned from API call
#' @param date_col name of the current date field

#' @return If the package lubridate (>= 1.5.0) is available the original data frame with two new columns,
#' \code{fecha} and \code{periodicidad} is returned. If the above package is not available,
#' the orignal data frame is returned unaltered with an additional warning message.

istacperiodos2POSIXct <- function(df, date_col) {

  if (requireNamespace("lubridate", versionCheck = list(op = ">=", version = "1.5.0"),
                       quietly = TRUE)) {

    if (nrow(df) == 0) {

      # hackish way to support the POSIXct parameter with 0 rows returned
      df_ct <- as.data.frame(matrix(nrow = 0, ncol = 2), stringsAsFactors = FALSE)
      names(df_ct) <- c("fecha", "periodicidad")

      df <- cbind(df, df_ct)

      return(df)
    }

    # add new columns
    df$fecha <- as.Date.POSIXct(NA)
    df$periodicidad <- NA

    date_vec <- df[ ,date_col]

    # annual ----------
    annual_obs_index <- grep("[M|Q|W]", date_vec, invert = TRUE)

    if (length(annual_obs_index) > 0) {

      annual_posix <- as.Date(date_vec[annual_obs_index], "%Y")
      annual_posix_values <- lubridate::floor_date(annual_posix, unit = "year")

      df$fecha[annual_obs_index] <- annual_posix_values
      df$periodicidad[annual_obs_index] <- "anual"

    }

    # Biannual ----------
    # Monthly -----------

    M_obs_index <- grep("M", date_vec)

    if (length(M_obs_index) > 0) {
      unique_Mobs <- unique(date_vec[M_obs_index])
      obs <- strsplit(as.character(unique_Mobs), "M")
      date_df <- as.data.frame(matrix(unlist(obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)

      if (abs(as.numeric(date_df[1,2])-as.numeric(date_df[2,2])) == 6){
        # Biannual
        sem_obs <- strsplit(as.character(date_vec[M_obs_index]), "M")
        sem_df <- as.data.frame(matrix(unlist(sem_obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
        names(sem_df) <- c("year", "month_sem")
        #sem_df$semester <-ifelse(sem_df$month_sem == "06",1,2)
        sem_format_vec <- paste0(sem_df$year, "01", sem_df$month_sem)

        sem_posix <- lubridate::ydm(sem_format_vec)


        df$fecha[M_obs_index] <- sem_posix
        df$periodicidad[M_obs_index] <- "semestral"


      } else {
        # Monthly
        m_obs <- strsplit(as.character(date_vec[M_obs_index]), "M")
        m_df <- as.data.frame(matrix(unlist(m_obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
        names(m_df) <- c("year", "month")
        m_format_vec <- paste0(m_df$year, "01", m_df$month)

        m_posix <- lubridate::ydm(m_format_vec)
        df$fecha[M_obs_index] <- m_posix
        df$periodicidad[M_obs_index] <- "mensual"

      }
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

      df$fecha[quarterly_obs_index] <- quarterly_posix_values
      df$periodicidad[quarterly_obs_index] <- "cuatrimestral"

    }


    # Biweekly -------------
    # Weekly ---------------


    W_obs_index <- grep("W", date_vec)

    if (length(W_obs_index) > 0) {
      unique_Wobs <- unique(date_vec[W_obs_index])
      obs <- strsplit(as.character(unique_Wobs), "W")
      date_df <- as.data.frame(matrix(unlist(obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)



        w_obs <- strsplit(as.character(date_vec[W_obs_index]), "W")
        w_df <- as.data.frame(matrix(unlist(w_obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
        names(w_df) <- c("year", "week")

        w_format_vec <- paste0(w_df$year, "01-01")

        w_posix <- lubridate::ymd(w_format_vec) + lubridate::weeks(as.numeric(w_df$week) - 1)


        df$fecha[W_obs_index] <- w_posix

        if (abs(as.numeric(date_df[1,2])-as.numeric(date_df[2,2])) == 2){

            df$periodicidad[W_obs_index] <- "quincenal"
        } else {

          df$periodicidad[W_obs_index] <- "semanal"

        }
    }



  } else {

    warning("Required Namespace 'lubridate (>= 1.5.0)' not available. This option is being ignored")

  }

  df
}
