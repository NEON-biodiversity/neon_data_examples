# MSB Data Organization Discussion

## Goals

Internal reproducibility => Public reproducibility

- Discovery: where is the data I'm seeking, or code to acquire it
- Process: where should I put the data as I work on it
- Collaboration: common project structure
- Versioning: Synchronizing data across projects
- Tracking updates
- Linking code to data

## Basics: code vs data

### Code: github

* some data can reside with code
* configuration & parameters 
  * lists used only by this code (e.g. list of taxa to run on)
  * To make projects flexible for collaborators, code shouldn't have folders hard-coded
  * your base data folders should be set as configuration, and should not be hard coded into files (see below)
      * R : use .Renviron file to set base path, in code read environ to retrieve this path
      * The .Renviron file does not go into git, so user sets own .Renviron file when working on project
      * 

## Data : google drive
* growing pains from moving from one the other
* no great way to sync with a Linux system
  * Globus can transfer back and forth on cherry-picked folders

### Example Process for large data
L0 code : download PRISM data 

## Using Google drive data in an R project

  1. Google Drive File Stream, sync only what you need for manageable data sets
  2. Google Drive, manually download/upload data files onto your local computer
  3. R "Google Drive" package to open individual files requires absolute file path and user log-in to work.  


### Notes on Adjusting file paths in R
  * see chapter on configuration in R guide, links to WTF/R book from Jenny Bryan
  * goal : portability (user multiple computers, multiple users, HPC, cloud?)
  * requirements: user action to create this file and set this folder

**.Renviron (file)**:

Does not get put into git, each user must create their own

```bash
DATADIR=/Volumes/GoogleDrive/Shared\ drives/MacrosystemsBiodiversity/data/projectx
# OR if data is on your local computer; something like
DATADIR=D:/MSB/downloaded_data/projectx
```

**README.md**:   

Tell the user this needs to be set"You must create an .Renviron file that contains the line DATADIR=/<your file location>", or set the envirorment vaariable before running this script  DATADIR=/my/working/folder; Rscript write_fd_files.R

Possibly include a file in the project called something like `Renviron-example.txt` to be used as a starting point for personalized .Renviron.     A single user may run in multiple environments and each git clone would need a new `.Renviron` file (e.g. laptop, HPC, cloud (eventually))

**Example R code to load options for file paths:**: 

```R
# global variables using R 'options'
datadir <- sys.getenv("DATADIR")
if(is.na(matador)) { datadir <- "C:/somewhere/reasonable")
                    
options(L0dir = file.path(datadir, "L0")
options(L1dir = file.path(datadir, "L1")
options(L2dir = file.path(datadir, "L2")

#' read tree trait data, calculate tree functional diversity, and writes output to tree_pd.csv
#' overwrites any existing output file in the given output dir
#'
#' @param treefile Optionaal Name of file to read (not the full path, just the name), defaults to trees.csv
#' @param inputdir Optional directory to read from (defaults to L0 option)
#' @param outputdir Optional directory to write to (defaults to L0 option)      
#' @return The full path of the file that was written, or NULL if there was an error

write_tree_fd<-function( treefile = "trees.csv", inputdir = options("L0dir"), outputdir = options("L1dir")){

  # note the calculation is in a different function than one that writes data
  # so that the calculation may be tested without side effects of writing files
  treedata <- read.csv(file.path(inputdir, treefile))
  
	fd <- tree_fd(treedata)
  # validate fd, check for non-zero length, etc
  
  # this over-writes existing data
  outputfile <- file.path(outputdir, "tree_pd.csv")
  write.csv(fd, file=outputfile)
  return(outputfile) 
 
  }


```


​	



### Question for R configuration: 

Option for R configuration recommendation: one main "datadir" folder ( `/Volumes/GoogleDrive/Shared\ drives/MacrosystemsBiodiversity/data/projectx/`)  or separate folders for each L0/1/2 instead on a single  "DATADIR"  ( I have had times when I wanted to write output to different folder), for example

.Renviron:

```bash
L0=/Volumes/GoogleDrive/Shared\ drives/MacrosystemsBiodiversity/data/projectx/L0
L1=/Volumes/GoogleDrive/Shared\ drives/MacrosystemsBiodiversity/data/projectx/L1
L2=/Volumes/GoogleDrive/Shared\ drives/MacrosystemsBiodiversity/data/projectx/L2
```



## Principle: we should all be using the same data as much as possible

### sync L0 across projects
    * update data with coordinated intension
      * quarterly, annually?  based on NEON schedule?
        goal: answer "am I using latest data" with "yes"
    
        L0 == data obtained from another producer (NEON, PRISM, etc)
    
    L1 == and data maninpulation needed for analysis, filter/group/joins
    
    L2 == output, can be another projects L0

  * data inside projects:

   * example MSB/data/projectx/L0 

   * =>data project owners have collected for use in the project

   * project personnel maintain these folders
	
   * Updates for common data must be coordinated: 
		find a week where all projects update their data sources if needed
  * data shared among project:

MSB/data/L0 => data we work together on and share

how to deal with two possible data folders in R?  Two variables.  L0= L0MSB=
		
who maintains data outside of projects?

## L0 Code

Minimally there should be clear instructions for how L0 data are acquired and where possible, there should be R scripts.  It's easy to spend a lot of time perfecting an L0 script when manually instructions would suffice.   

R functions or scripts should be flexible enough to use different L0 paths, set as configuration. 

Functions should be of two classes, if possible

1. Get == L0 functions

   code to get the data and save into the folder where it's to go, using L0dir as the root. 

2. Read, L0 or L1?  

   if the data is at all complex, or has any quirks that need to be remember asside from a simple 

   `read.csv(file.path(L0dir, 'filename.csv'))` 

   then it may be worth creating functions to read and return the data.  These could be called  L0 vs L1 script?  (the EDI framework speaks to data, not code)    A functional approach this protects the down-stream scripts (L1, L2) from small alterations in the data, and is a single point of code for changes.     For example, if data is multiple years (2018xdata.csv, 2019xdata.csv, 2020xdata.csv) and L1 scripts should be able to use all of these files, write a function 

   ```R
   # untested demo code
   read_xdata <- function(datadir){
     # this function knows the file names and folders where x data live
     xdata_folder <- file.path(datadir, "xdata")
     
     read_by_year <- function(year){ 
       xdata_file <- file.path(xdata_folder, paste0(as.character(year), "xdata.csv")
       if(file.exists(xdata_file)){ 
         read.csv(xdata_file) } 
       else { 
         warning(paste(xdata_file, " not found, exiting"))
         return(NA)
   	  }
     # read data for each year, updated as more data is stored
     xdata_list <- lapply(c(2018, 2019, 2020), read_by_year)
     # combine data frames in the list                          
   	xdata <- do.call(rbind, xdata_list)
   
     return(xdata)
   }
   ```

   

3. **Check code**

function(s) to check that the data is present, and potentially print or plot very basic summaries (without manipulation), and possibily return T/F.  This splits the tasks of validati data files, reading data,  and cleaning/summarizing procedures for easier troubleshooting.   See the [Seperation of Concerrns](https://effectivesoftwaredesign.com/2012/02/05/separation-of-concerns/) principle for sofware engineering. 

```R
check_xdata <- function(datadir, years=c(2018, 2019, 2020)){
  # this function knows the file names and folders where x data live
  xdata_folder <- file.path(datadir, "xdata")
  
  check_by_year <- function(year){ 
    xdata_file <- file.path(xdata_folder, paste0(as.character(year), "xdata.csv")
    if(file.exists(xdata_file)){ 
      return(TRUE)
    else { 
      warning(paste(xdata_file, "not found"))
      return(FALSE)
	  }
  # read data for each year, updated as more data is stored
  checks <- sapply(c(2018, 2019, 2020), check_by_year)
  # combine data frames in the list                          
	return(all(checks))  # all returns TRUE if all elements are TRUE
}
```



## NEON Data for L0

There are (at least) 3 packages to get NEON data (that I know of): `neon_utilities`, `neonDivData`and `neonstore`. 

There are detailed notes and example scripts in the repository https://github.com/NEON-biodiversity/neon_data_examples

I believe that MSB should choose one method and recommend all sub-projects use this method. 

`neonDivData` quickly provides data without downloading.  This follows the "data as a package" recommendation we discussed last summer.   

```R
# install.packages("devtools")
devtools::install_github("daijiang/neonDivData")
library(neonDivData)
```

automaticaly makes available `neon_sites`,` neon_taxa`, and data files like ` data_zooplankton`

```R
taxa_count <- function(div_data){ length(unique(div_data$taxon_id))}
zooplanton_count <- function(){ taxa_count(neonDivData::data_zooplanton)}
bird_species_count <- function(){ taxa_count(neonDivData::data_birds)}
```



## Documenting L1 Data

Question to group: How to document the source and state of L1 data?

Example, running computation on HPC

1. cloning his code to HPC from github 
2. transferring input data from Google drive L1 folder to HPCC L1 folder (using Globus)
3. editing code to get it to work, back and forth  using Github in an HPC branch
4. communicating notes on progress using shared Google doc
5. 2 day run-time 
6. transfer results from HPCC L1 folder to Google Drive L1 folder (using Globus)

Now... how to document the provenance of the results?  If the source code is updated in prep for publication, or for use in another analysis, how can we link output data file(s) to this version of code?  How to indicate who/what created this results file?  
1. in alll data folders, or parent folder include documentation of the files present (README.txt?, log?)
2. Use git "tags" to mark the version of code that generated a data file, and indicate that in the data README (can link to github tag)
3. Include a copy of the code used to create all files in data folders?
4. Add versioning to all file names?  (requires using these versioned file names in all of our code)
5. How to indicate the version of the inputs, or parameter values used to create this output

