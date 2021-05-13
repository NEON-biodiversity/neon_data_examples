library(neonstore)

datacache <- cachem::cache_disk(rappdirs::user_cache_dir(file.path("data", "cache")))


##### product code ID  discovery by keywords
# the list of acceptable taxon types, because I don't want to look in the help everytime
taxonTypes <- unlist(strsplit("ALGAE, BEETLE, BIRD, FISH, HERPETOLOGY, MACROINVERTEBRATE, MOSQUITO, MOSQUITO_PATHOGENS, SMALL_MAMMAL, PLANT, TICK", ", ") )

if(Sys.getenv("NEONSTORE_HOME") == ""){
    Sys.setenv(NEONSTORE_HOME = file.path('data','neonstore'))
}

if (! dir.exists(Sys.getenv("NEONSTORE_HOME"))) {
    dir.create(Sys.getenv("NEONSTORE_HOME"))
}

# optional step
# using memoize means when we re-run neon_products(), it doesn't re-download every time
products<- memoise::memoize(neonstore::neon_products, cache=datacache)


prods_by_theme <- function(keyword, code_only=TRUE) {
    i <- grepl(keyword, products()$themes)
    if(code_only){
        products()[i, c("productCode")]
    } else {
        products()[i, c("productCode", "productName","productCategory ")]
    }
}

prods_by_keyword <- function(keyword, code_only=TRUE) {
    i = list( grepl(keyword, products()$keywords, ignore.case = TRUE),
              grepl(keyword, products()$productName, ignore.case = TRUE))
    i = Reduce("|", i)  # combine these
    if(code_only){
        products()[i, c("productCode")]
    } else {
        products()[i, c("productCode", "productName","productCategory")]
    }

}

#' get the product code for Birds
#' simple function to demonstrate the prods_by_keyword() functionality of neonstore
#'   how to get a similar look-up function from neonUtilities?
#'
birdProductCode <- function(){
    # products <- neon_products()
    as.character(prods_by_keyword('bird')[1,])
    # products[grep('bird', products$productName, ignore.case = TRUE),]$productCode
}

#' retrieve and store the latest Bird Data from Neon
#'
#' param neon_token
#'
storeBirdData <- function(neon_token = get_neon_token()){
    # is there a way to cache this?  yes with neonDataStore

    # neon token is required
    if(is.na(neon_token)) {
        return(FALSE)
    }

    # downloads (unless it's already downloaded) and puts into local databaase
    neonstore:neon_download(product=birdProductCode(), .token=neon_token)
    neonstore::neon_store(product=birdProductCode())
    # return(loadByProduct(birdProductCode(), token = get_api_key()))
}


birds <- function() {
    storeBirdData()
    neon_table("brd_countdata")
}

