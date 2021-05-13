# using_neondivdata.R

## installing newondivData
# install.packages('devtools')
# devtools::install_github("daijiang/neonDivData")
## note this will takea some time as it moves the data files into your installation folder
## and will print something like this
## ** data
## *** moving datasets to lazyload DB
## ** byte-compile and prepare package for lazy loading
## etc

library(neonDivData)
#' list all 'data' tables from neonDivData
#'
#' return vector of strings of dataset names
neonDivData_products<- function(){
    all_data<- ls("package:neonDivData")
    data_products <- all_data[grepl("data_", all_data)]
    return(data_products)

}

#'using_neondivdata
#'one of 3 contrasting examples of using NEON data, this time using the neonDivData package.
#'if the package is installed and loaded, the data is immediately available as a data structure with
#'data_{type}.
#'prints some example info
#'return Nothing
using_neondivdata <- function(taxonType = "bird"){

    # neonDivData does not have a way to select data set by taxonType
    # but we could create a look-up function.  for now user must use correct taxa name
    dataset_name <- paste0("data_", taxonType)
    print(dataset_name)
    # example of using a shortened name, this is optional
    # and a way to get a dataset via a concatenated string
    ndd_dataset  <-get(dataset_name)
    print("column names in neonDivData file:")
    names(ndd_dataset)
    unique_taxa <- length(unique(ndd_dataset$taxon_id))

    print(paste("Unique taxa in", taxonType,":", unique_taxa))
    # to get more info about the dataset, use the help
    print(paste("opening help file for ", dataset_name, "..."))
    help(dataset_name, package = neonDivData)

}



# mapping example
# create a shortened name

# map_neondivdata_sites.R
# use the sites that come with the neonDivData package to put sites as points on the map.

library(neonDivData)
library(sf)
library(rnaturalearth)
library(ggplot2)


mapping_neondivdata_standard<- function(){
    # neon_sites i sfrom  neonDivData package here
    # coule preface with package name, or  create a subset
    world <- ne_countries(scale = "medium", returnclass = "sf")

    xlim = c(min(neon_sites$Longitude)-5, max(neon_sites$Longitude)+5)
    ylim = c(min(neon_sites$Latitude)- 5, max(neon_sites$Latitude)+5)
    ggplot(data = world) +
        geom_sf() +
        geom_point(data = neon_sites, aes(x = Longitude, y = Latitude), size = 4,
                   shape = 13, fill = "darkred") +
        coord_sf(xlim = xlim, ylim = ylim, expand = TRUE)
}

library(leaflet)
#' example mapping of neon sites using neonDivData packages
mapping_neondivdata_leaflet <- function(site_data = neonDivData::neon_sites ) {

    # site_data may be sent, but use sites table in neonDivData by default
    # the rest of the mapping assumes field names matching (e.g. Longitude)
    # site_data <- neonDivData::neon_sites

    # need to rename the names of this since they have spaces in them!
    names(site_data) <- make.names(names(site_data), unique=TRUE)

    # map with leaflet
    leaflet(data=site_data) %>%
        addTiles()  %>%
        addMarkers(~Longitude, ~Latitude, popup = ~Domain.Name, label =  ~Site.Name)
}

#' #' using_neonstore:
#' #'
#' using_neonstore <- function() {
#'     library(neonstore)
#'     # this makes it clear where data is downloading
#'     datacache <- cachem::cache_disk(rappdirs::user_cache_dir(file.path("data", "cache")))
#'
#'     # neonstore downloads files into a folder of your choice, or uses a default
#'     # this code lets you set that folder in .Renviron as configuration
#'     # and creates the folder if it does not exist
#'     if(Sys.getenv("NEONSTORE_HOME") == ""){
#'         Sys.setenv(NEONSTORE_HOME = file.path('data','neonstore'))
#'     }
#'
#'     if (! dir.exists(Sys.getenv("NEONSTORE_HOME"))) {
#'         dir.create(Sys.getenv("NEONSTORE_HOME"))
#'     }
#'
#'     prods <-neonstore::neon_products()
#'
#'     download_zoop <-function(neonstore::neon_download()) {
#'
#'     }
#' }
