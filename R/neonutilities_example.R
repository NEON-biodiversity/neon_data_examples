library(neonUtilities)

source('R/get_neon_token.R')
taxonTypes <- unlist(strsplit("ALGAE, BEETLE, BIRD, FISH, HERPETOLOGY, MACROINVERTEBRATE, MOSQUITO, MOSQUITO_PATHOGENS, SMALL_MAMMAL, PLANT, TICK", ", ") )

#' example of using neonUtilities package to get bird data and explore
using_neonutilities<-function(product_code = "DP1.10003.001"){

    # pull all data from neon for this product code (birds), using token from environment
    print("downloading all  data, this may take a while")
    neondata <- loadByProduct(product_code, check.size = F, nCores = 2, token = get_neon_token())
    # this will dowbnlaod to disk, then load into memory
    productfilename = paste0(product_code, ".Rdata")
    print(paste0("saving", productfilename))
    # assumes that the drive specified in Renviron is mounted/active
    save(neondata, file=file.path(Sys.getenv("NEON_ROOT_FOLDER"), productfilename))
    summary(neondata)

}


