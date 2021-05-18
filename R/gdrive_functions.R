# gdrive_functions.R
# Pat Bills, Michigan State University
#
# collection of functions demonstration how to interact with Google drive files from R
# this is an unfinished work in progress
#
# these functions require the following packages to be installed
# install.packages( c( "googlesheets4", "googledrive"))
#
# then you must "require(googledrive)" which asks you to log-in
# to prevent that from happening when this sheet is sourced, it's wrapped into a function
# that gets called prior to running other functions

#' required the google drive packages and log-in
#' this is wrapped in a function because it has the side effect of
gdrive_setup <- function(){
    require(googlesheets4)
    require(googledrive)
    # wrap these in try/catch and return FALSE if they fail
    return(TRUE)
}

#' get time stamp for a particular gfile
#' @param gfile
gfile_modified_time<function(gfile){
    ts<- gfile$drive_resource[[1]]$modifiedTime
    return(ts)
}

#' read in google sheet into memory using our shared drive
read_gsheet<- function(gsheet_name, shared_drive = "MacrosystemsBiodiversity", verbose="FALSE"){
    # try catch here1
    if(verbose){
        print(paste("searching for ", gsheet_name))
    }


    gs_file<- drive_get(gsheet_name, team_drive = shared_drive)

    if (!single_file(gs_file)){
        warning("multiple files discovered, selecting the first one on the list!")
        gs_file <- gs_file[1,]
    }

    if(verbose){
        print(paste("reading data from ", gs_file$path))
    }

    gs_file<- gs_file[1,] # get thh first one in case there are duplicates

    gs_file_info <- read_sheet(gs_file)
    gs_data <- read.csv()
    return(gs_data)

}

#' given  a CSV file name that is on google drive,
#' download and read into memory from our shared drive
read_gcsv<-function(filename, shared_drive = "MacrosystemsBiodiversity"){

    # TODO try/catch
    gs_file<- drive_get(filepath, team_drive = shared_drive)
    if(!onefile(gs_file)){
        gs_file <- gs_file[1,]
    }
    #TODO check file size before reading in and confirm large files
    local_file = file.path(tempdir(), gs_file$name)
    local_file_infos <- drive_download(gs_file, path=local_file)


    csvdata<-read.csv(localfile)
    return(csvdata)
}

#' test/example file
test_gdrive<- function(testcsvname = "bird_taxonomy.csv"){
    gdrive_setup()
    some_data <- read_gcsv(testcsvname)
    summary(some_data)
    return(some_data)
}
