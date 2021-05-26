# functions to standaardize how the MSB project acquires and saves NEON data.
# this should correspond to our workflow doc

library(neonUtilities)
library(dplyr)


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
        varnames<- load(product_path, verbose=TRUE)
        # check if neondata in this varnames
        if("neondata" %in% varnames) {
            print("neondata loaded")
            return(neondata)
        } else {
            warning(paste("neon data file not loaded", product_path))
            return(NULL)
        }
    }

}

#' saves to the one of the data items from a Neon product to our L0 folder
#' if the neon product file has not been pulled and downloaded, it downloads and saves it.
#' @param neon_prod_code prod code id eg. dp...
#' @param neon_dataframe_name the name of the item in the list that neon_utilities creates that
#'                            data frame of interest
#'
save_neon_csv <- function(neon_prod_code, neon_dataframe_name, provisional=FALSE){

    # found this from using prods_by_keyword_with_descripton('mammals') in neonstore_example


    # create standard file name and path
    neon_product_file <- standard_neon_file_path(neon_prod_code)
    # if the file doesn't exist in folder, download it via neon utilities
    if(! file.exists(neon_product_file)) {
        # this function returns the data list
        neondata <- pull_neon_to_projectfolder(neon_prod_code)
    } else {
        # file already exists, so read it in as "neondata"
        neondata <- read_saved_neon_data(neon_prod_code)
    }

    # now just write the part we need to L0 folder
    L0_file_path<- file.path(Sys.getenv("NEON_ROOT_FOLDER"),
        "neon_observations",
        paste0(neon_dataframe_name, ".csv")
    )


    # TODO check if neondata[[neon_dataframe_name]] actually in
    if(!neon_dataframe_name %in% names(neondata) ) {
        warning(paste(neon_dataframe_name, "not found in neon product data"))
        return(NULL)
    }

    neon_obs_data <- neondata[[neon_dataframe_name]]

    # filter out provisional data
    if(provisional==FALSE){
        neon_obs_data <- neon_obs_data[neon_obs_data$release != "PROVISIONAL",]
    }

    # neon data products are lists - select just the per trapa csv, and save to disk
    write.csv(neon_obs_data, file=L0_file_path, row.names = FALSE)
    if(file.exists(L0_file_path)) { print(paste("success! wrote csv to", L0_file_path)) }

    return(L0_file_path)

}

read_csv_file <- function(){

    # now just write the part we need to L0 folder
    L0_file_path<- file.path(Sys.getenv("NEON_ROOT_FOLDER"),
                             "neon_observations",
                             paste0(neon_dataframe_name, ".csv")
    )
}

#' one-off function to demonstrate and record how to save mammal trap data
#' using genericized save_neon_csv() function.
#' @return full path to newly saved file, which could opened with `read.csv()`
save_mammal_trap_csv <- function(){
    mammal_file <- save_neon_csv(neon_prod_code = "DP1.10072.001",
                  neon_dataframe_name= "mam_pertrapnight")
    return(mammal_file)

}


#' simple wrapper to get taxon table from neonUtilities and save it to Google drive
#' useful to 1) freeze current taxon list we use as aa project 2) don't re-download from NEON every time
#' However in your own code you could get this table by simply using `fish_taxa<- neonUtilities::getTaxonTable('FISH')`
save_taxon_csv<- function(taxonTypeCode, taxa_folder="neon_taxa" ){
    taxa_table <- getTaxonTable(toupper(taxonTypeCode)) # must be upper case
    taxa_file_name <- paste0(tolower(taxonTypeCode), "_taxonomy.csv")
    taxa_path <- file.path(Sys.getenv("NEON_ROOT_FOLDER"),taxa_folder)
    if(dir.exists(taxa_path)){
        taxa_file_path = file.path(taxa_path, taxa_file_name)
        write.csv(taxa_table, file=taxa_file_path, row.names=FALSE)
        print(paste("successfully wrote file ", taxa_file_path))
        return(taxa_file_path)
    } else {
        warning(paste("taxa folder does not exist", taxa_path))
        return(NULL)
    }
}

save_all_taxa_tables <- function(){
    for(taxonTypeCode in taxonTypes){
        print(taxonTypeCode)
        save_taxon_csv(taxonTypeCode)

    }
}

### SPATIAL
library(jsonlite)
library(httr)
#' pull current coordinates via the NEON API.
#' note these are in the neonDivData `neonsites` data package
get_neon_site_coordinates_from_api<- function(){
    site_locs <- GET('http://data.neonscience.org/api/v0/locations/sites') %>%
        content(as = 'text') %>%
        fromJSON(simplifyDataFrame = TRUE, flatten = TRUE)

    # remove NAs - why are there NAs?
    site_locs <- site_locs$data[,1:19] %>%
        filter(!is.na(locationDecimalLatitude) & !is.na(locationDecimalLongitude))

    # pull just the coordinates from the locs
    site_coords <- site_locs %>%
        dplyr::select(locationName, locationDecimalLongitude, locationDecimalLatitude, locationElevation) %>%
        setNames(c('siteID', 'lon', 'lat', 'elevation'))

    return(site_coords)
}

#' save the NEON site coordinates to google drive for re-use
#' this should only have to run once, saved as function for documentation
write_neon_site_coords<- function(){
    site.df <- get_neon_site_coordinates_from_api()
    site_file_name <- "neon_site_coords.csv"
    site_file_path <- file.path(Sys.getenv("NEON_ROOT_FOLDER"),"spatial_data",site_file_name )
    write.csv(site.df, file=site_file_path, row.names=FALSE)
    if(file.exists(site_file_path)){ print( paste("site file coordinate file saved as ", site_file_path))}
    return(site_file_path)
}

