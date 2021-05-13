#' set or get the token needed to make neon api calls.
#' using either the token param, or one if it's set in .Renviron or as an environment variable (NEON_TOKEN)
#' @param token optional string to set the the environment and use for future calls
#' @return string value of the token to be used, which if not sent as a param is from the environment
#'          or NA if none is set
get_neon_token <- function(token=NA){
    if(is.na(token)){
        # no token param, look for one in environment
        token<- Sys.getenv('NEON_TOKEN') # returns empty string if var is not set
    }
    else {
        # token param set, update token in Environment
        # this will be reset if R is restarted
        Sys.setenv(NEON_TOKEN=token)
    }

    if(token==""){
        warning("NEON api toekn not set in environment, please set NEON_TOKEN in .Renviron an restart R")
        return(NA)
    }
    else
        return(token)

}



