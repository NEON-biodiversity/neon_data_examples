# functions to standaardize how the MSB project acquires and saves NEON data.
# this should correspond to our workflow doc

library(neonUtilities)

# functions to read your neon api token from the environment
# see the readme for more info
source('R/get_neon_token.R')


taxonTypes <- unlist(strsplit("ALGAE, BEETLE, BIRD, FISH, HERPETOLOGY, MACROINVERTEBRATE, MOSQUITO, MOSQUITO_PATHOGENS, SMALL_MAMMAL, PLANT, TICK", ", ") )

#' standardized way to name a neon file and path to it
#' extraction this to a function as it's used in multiple places
#' @param product_code neon product id (eg dp...)
#' @param neon_downloads_path optional folder for downloads, defaults to neon_downloads which is our standard
#'
#' @return full file path that starts with  Renviron setting NEON_ROOT_PATH
standard_neon_file_path<- function(product_code,neon_downloads_path = "neon_downloads"){
    product_filename = paste0(product_code, ".Rdata")
    # the folder where the path goes is a combo of root folder, a "downloads folder" , and a file name
    product_path=file.path(
        Sys.getenv("NEON_ROOT_FOLDER"),
        neon_downloads_path,
        product_filename)
    return(product_path)
}

#' example of using neonUtilities package to get bird data and explore
#' this is a wrapper around ` loadByProduct` which downloads the data to your computer
#' and puts it into a variable, and this saves that as Rdata into the folder of your choice
#'
#' @param product_code Neon standard product code
#' @param neon_downloads_path Folder or folders path where to store neon downloads in the root folder
#' @return path to the file that was saved
pull_neon_to_projectfolder<-function(product_code = "DP1.10003.001", neon_downloads_path = "neon_downloads"){

    # pull all data from neon for this product code (birds), using token from environment
    print("downloading all data, this may take a while")
    # this will dowbnlaod to disk, then load into memory
    neondata <- loadByProduct(product_code, check.size = F, nCores = 2, token = get_neon_token())
    # use our function to create the name and folder path
    product_path=standard_neon_file_path(product_code)

    print(paste("saving", product_code, "to", product_path))
    # assumes that the drive specified in Renviron is mounted/active
    save(neondata, file=product_path)

    # to re-read in these data use

    return(product_path)

}

#' loads previously saveed neon data as "neondata", using same file naame scheme as above
read_saved_neon_data <-function(product_code) {
    product_path=standard_neon_file_path(product_code)
    if(file.exists(product_path)){
        load(product_path, verbose=TRUE)
        print("neondata loaded")
    }
}

#' saves to the one of the data items from a Neon product to our L0 folder
#' if the neon product file has not been pulled and downloaded, it downloads and saves it.
#' @param neon_prod_code prod code id eg. dp...
#' @param neon_dataframe_name the name of the item in the list that neon_utilities creates that
#'                            data frame of interest
#'
save_neon_csv <- function(neon_prod_code, neon_dataframe_name){

    # found this from using prods_by_keyword_with_descripton('mammals') in neonstore_example


    # create standard file name and path
    neon_prorduct_file <- standard_neon_file_path(neon_prod_code)
    # if the file doesn't exist in folder, download it via neon utilities
    if(! file.exists(neon_prorduct_file)) {
        # this function returns the data list
        mammal_data <- pull_neon_to_projectfolder(neon_prod_code)
    } else {
        # file already exists, so read it in
        mammal_data <- read_saved_neon_data(neon_prorduct_file)
    }

    # now just write the part we need to L0 folder
    L0_file_path<- file.path(sys.getenv("NEON_ROOT_FOLDER"),
        "neon_organism",
        neon_dataframe_name)

    # neon data products are lists - select just the per trapa csv, and save to disk
    write.csv(neon_prorduct_file[[neon_dataframe_name]], file=L0_file_path)
    if(file.exists(L0_file_path)) { print(paste("success! wrote csv to", L0_file_path)) }

    return(L0_file_path)

}

save_mammal_trap_csv <- function(){
    save_neon_csv(neon_prod_code = "DP1.10072.001",
                  neon_dataframe_name= "mam_pertrapnight")
}


