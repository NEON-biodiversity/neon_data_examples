library(sp)
library(rgdal)
library(maptools)
library(broom)
library(ggplot2)
library(neonUtilities)
library(geoNEON)

options(stringsAsFactors=F)


getShapeFiles <- function(shapefilespath="NEONDomains_0", datapath="data", overwrite=FALSE){
    if(! dir.exists(datapath)){
        dir.create(datapath)
    }
    
    shapefilespath<-file.path(datapath, shapefilespath)
    
    if(! dir.exists(shapefilespath)){
        dir.create(shapefilespath)
    }
    
    if(! file.exists(file.path(shapefilespath, 'NEON_Domains.shp')) || overwrite==TRUE ) {
        # check if data is already downloaded in the path
    # if files are not present or if overwrite==TRUE 
        downloaddir <- tempdir()
        zipfilename <- "NEONDomains_0.zip"
        zipfilepath = file.path(downloaddir, "NEONDomains_0")
        url <- paste0("https://www.neonscience.org/sites/default/files/", zipfilename)
        download.file(url, zipfilepath)
        # download the url to zipfilepath
        # unzip zipfilepath into the data path
        unzip( zipfilepath,exdir = shapefilespath)
        
        exts = c("dbf", "shp", "prj", "sbn", "sbx", "shx", "shp.xml")
        
        all_files_downloaded = all(file.exists(file.path(shapefilespath, paste0("NEON_Domains.", exts))))
        if(! all_files_downloaded){ warning(paste("not all files expected were downloaded into ", shapefilespath))}
        
        # return T/F depending if all files were found
        return(all_files_downloaded)
        
        
    } else {
        warning("shape files already present, skipped downloading (use overwrite=TRUE to force)")
        
    }
}

domain_map <- function(shapefilespath="NEONDomains_0", datapath="data") {
    wd = file.path(datapath, shapefilespath)
    neonDomains <- readOGR(wd, layer="NEON_Domains")
    neonDomains@data$id <- rownames(neonDomains@data)
    neonDomains_points <- tidy(neonDomains, region="id")
    neonDomainsDF <- merge(neonDomains_points, neonDomains@data, by = "id")
    domainMap <- ggplot(neonDomainsDF, aes(x=long, y=lat)) + 
        geom_map(map = neonDomainsDF,
                 aes(map_id = id),
                 fill="white", color="black", size=0.3)
    
    return(domainMap)
}


taxonTypes <- unlist(strsplit("ALGAE, BEETLE, BIRD, FISH, HERPETOLOGY, MACROINVERTEBRATE, MOSQUITO, MOSQUITO_PATHOGENS, SMALL_MAMMAL, PLANT, TICK", ", ") )

