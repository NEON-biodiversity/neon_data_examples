# neon4msb: NEON Data Explorer

Notes on Using NEON Data for the MSB Project

 * **this is in draft form and contributions are needed** *

NEON data is very complex and thoroughly documented.  However, When approaching NEON data and it's download processes, you are confronted with many decisions. 

This repository is here to provide some example code and to summarize some of the ways  to acquire NEON data for an analysis.  Note NEON has provided amazing documentation and tools to help get started, but there is a learning curve.  This project's documentation and code is no substitute for their tutorials.  We encourage you to begin with [NEON's getting started guide](https://www.neonscience.org/resources/getting-started-neon-data-resources), but to come back and see a couple of options, and some practices for the MSB project.  

### Getting started / Background

The NEON website is well organized and guides you to good coverage of what NEON data is, for example *
[Getting Started with NEON Data & Resources](https://www.neonscience.org/resources/getting-started-neon-data-resources)*


For several of these methods, you need a 'token' that identifies you to NEON.   This ensures tht NEON's servers are not overwhelemed with anonymous download requests.  The token is free to use.  

### NEON Web download


This is always a viable option with the advantage of being able to explore and read summaries etc on-line.  

https://data.neonscience.org or to explore via the web, see the [Explore Data Products](https://data.neonscience.org/data-products/explore) section.  Most tutorials are for R and Python via the NEON API.   The API may be used directly in the programming language of your choice, but that's beyond this note. 


### using R package neonUtilities


For  data packages not covered by the methods below, or if you need to see detailed metadata and validation, this is by 
far the preferred method.   

There is a good overview  tutorial based on R :  [Download and Explore NEON Data](https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data)

and this has more detail on the neonUtilities package: 
[Use the neonUtilities Package to Access NEON Data](https://www.neonscience.org/resources/learning-hub/tutorials/neondatastackr)


NEON data is available as zip files per year per site, and to combine them they must be stacked.  neonUtilities has functions for that, but better is has the workhorse function `loadByProduct()`  which, given a data product ID, will download all sites and all years available, unzip and stack them into a single list.  The result in R is a list of several tables including meta data.  For each of these products, you need to know the name of the data file therein and extract that.  For example, zooplankton data


```R
 neon_token='your token here'
 dpID= "DP1.20219.001"
 zooplankton<-neon_get_product_all_sites(dpID, neon_token)
 zooplankton_processed_data <- zooplankton$zoo_taxonomyProcessed
 nrow(zooplankton_processed_data)
 ```
 
However you don't want to do this every time you want to run an analysis, so you may want to save into the L0 folder for your project on the MSB google shared drive (e.g. on your computur), and read in the file in from our local store

 ```R
 # after downloading above, save to disk
 # this folder is example path on a Mac to the google shated fdrive
 data_folder = "/Volumes/GoogleDrive/Shared drives/MacrosystemsBiodiversity/data/organism/L0"
 file_name="zooplankton.csv"
 write.csv(zooplankton_processed_data, file.path( data_folder, file_name))
```

#### Taxonomy using neonUtilities : 


It's possible to pull the list of species sampled from the data table (for example to get tree species)

```R
plant_data <- loadByProduct(dpID = "DP1.10098.001", site = "all",  token = neon_token) 
tree_species <- woody_data$vst_mappingandtagging %>% 
       select(taxonID, scientificName) %>%  unique() 

```

But neonUtilities has functions to pull just taxa, however you need to know the codes/words to filter the data on

```R
plant_taxa <- getTaxonTable("PLANT",recordReturnLimit = NA, stream = "true", token = neon_token)
tree_species <- plant_taxa %>% dplyr::filter(x="wood")
```

### Using neonStore 

The [neonStore](https://cran.r-project.org/package=neonstore) R package is not from NEON, bhut from Dr. Carl Boettiger, Berkeley although one of the authors is Clair Lunch from NEON/Batelle who is primary author of the neonUtilities pacakge. 


The goal of  [neonStore](https://cran.r-project.org/package=neonstore) is to simplify the download and access process by always saving the results to the disk, to provide a cache system where you can require a NEON data product and it won't re-download if you already have it, and lastly use a SQL database to make querying the data fast.  

The main different between neonUtilities is that there is a folder where the data is automaatically saved.  There is a way you may save this configuraion, and also a way to store your NEON token once so you don't have to put it in every function call (and keep it out of your code that may end up in a git repository).

The github repository has links to vignettes : https://github.com/cboettig/neonstore


### Using the NeonDivData R Package

This is by far the easiest way to use NEON data as it's been pre-packaged for immediate use in R and vetted by NEON and MSB members.  

The package is underdevelopment and the github project is https://github.com/daijiang/neonDivData .  To install (per the package README) in R use (requires that the  `devtools` package is installed)

```R
# install.packages("devtools")
devtools::install_github("daijiang/neonDivData")
```

Once installed and loaded, you can access data is immediately available (and loaded as you used it ) 

```R
library(neonDivData)
names(data_zooplankton)
nrow(data_zooplankton)
# make an alias for less typing, using the (optional) package refrence notation
zoop <- neonDivData::data_zooplankton
zoop_taxa_count <- length(unique(zoop$taxon_id))
# ~ 157
```

Note there is no need for a NEON token as the data has already been downloaded.  Note this package is only data - the transformation of data into a consistent format is via the EcoComDP project 

The package has also neatly pulled in site-lvel information in `neon_sites` and 
see the [project documentation](https://daijiang.github.io/neonDivData/index.html).  The github repository has a draft manuscript (in review) with more backgound 

For example, plot the sites on crude US map (requires spatial libraries to be install)

```R
library(neonDivData)
library(sf)
library(rnaturalearth)
library(ggplot2)
world <- ne_countries(scale = "medium", returnclass = "sf")

xlim = c(min(neon_sites$Longitude)-5, max(neon_sites$Longitude)+5) 
ylim = c(min(neon_sites$Latitude)- 5, max(neon_sites$Latitude)+5)
ggplot(data = world) +
    geom_sf() +
    geom_point(data = neon_sites, aes(x = Longitude, y = Latitude), size = 4, 
        shape = 23, fill = "darkred") +
    coord_sf(xlim = xlim, ylim = ylim, expand = TRUE)
    
```

The package also includes taxonomy data in `neon_taxa` organized by the NEON group codes. For example (requires `dplyr` package):

```R
library(neonDivData)
dplyr::count(neon_taxa, taxon_group)
```
Output (spring 2021): 
```
 A tibble: 12 x 2
   taxon_group            n
   <chr>              <int>
 1 ALGAE               1946
 2 BEETLES              756
 3 BIRDS                541
 4 FISH                 147
 5 HERPTILES            128
 6 MACROINVERTEBRATES  1330
 7 MOSQUITOES           128
 8 PLANTS              6197
 9 SMALL_MAMMALS        145
10 TICK_PATHOGENS        12
11 TICKS                 19
12 ZOOPLANKTON          157
```


## NEON MetaData

NEON data comes with extensive metadata and README files.   neonDivData does not have a link to these or to product codes, but it's essential to read them to appreciate any caveats or updates/fixes.     
