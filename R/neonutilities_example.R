library(neonUtilities)

source('R/get_neon_token.R')

taxonTypes <- unlist(strsplit("ALGAE, BEETLE, BIRD, FISH, HERPETOLOGY, MACROINVERTEBRATE, MOSQUITO, MOSQUITO_PATHOGENS, SMALL_MAMMAL, PLANT, TICK", ", ") )

#' example of using neonUtilities package to get bird data and explore
#' this is a wrapper around ` loadByProduct` which downloads the data to your computer
#' and puts it into a variable, and this saves that as Rdata into the folder of your choice
#'
#' @param product_code Neon standard product code
#' @return path to the file that was saved
pull_neon_to_projectfolder<-function(product_code = "DP1.10003.001"){

    # pull all data from neon for this product code (birds), using token from environment
    print("downloading all data, this may take a while")
    # this will dowbnlaod to disk, then load into memory
    neondata <- loadByProduct(product_code, check.size = F, nCores = 2, token = get_neon_token())

    # create some file name and path based on
    product_filename = paste0(product_code, ".Rdata")
    product_path=file.path(Sys.getenv("NEON_ROOT_FOLDER"), product_filename)

    print(paste("saving", product_code, "to", product_path))
    # assumes that the drive specified in Renviron is mounted/active
    save(neondata, file=product_path)

    # to re-read in these data use

    return(product_path)

}

#' loads previously saveed neon data as "neondata", using same file naame scheme as above
read_saved_neon_data <-function(product_code) {
    product_filename = paste0(product_code, ".Rdata")
    product_path=file.path(Sys.getenv("NEON_ROOT_FOLDER"), product_filename)
    if(file.exists(product_path)){
        load(product_path, verbose=TRUE)
        print("neondata loaded")
    }
}

save_mammal_trap_data <- function(){
    # found this from using prods_by_keyword_with_descripton('mammals') in neonstore_example
    mammal_prod_code <- "DP1.10072.001"
    #
    pull_neon_to_projectfolder(mammal_prod_code)

}


