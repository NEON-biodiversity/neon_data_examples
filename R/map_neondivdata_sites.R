# map_neondivdata_sites.R
# use the sites that come with the neonDivData package to put sites as points on the map.

library(neonDivData)
library(sf)
library(rnaturalearth)
library(ggplot2)
library(leaflet)

neon_map_standard<- function(){
    world <- ne_countries(scale = "medium", returnclass = "sf")

    xlim = c(min(neon_sites$Longitude)-5, max(neon_sites$Longitude)+5)
    ylim = c(min(neon_sites$Latitude)- 5, max(neon_sites$Latitude)+5)
    ggplot(data = world) +
        geom_sf() +
        geom_point(data = neon_sites, aes(x = Longitude, y = Latitude), size = 4,
               shape = 13, fill = "darkred") +
        coord_sf(xlim = xlim, ylim = ylim, expand = TRUE)
}

# ggplot() +
#    geom_sf(data = us_sf, size = 0.125)

neondivdata_map_leaflet <- function(site_data = neonDivData::neon_sites ) {

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


neon_map_albers <- function(site_data = neon_sites) {
    # this currrently does not work, but the goal is single page map with AK and HI
    # displaced
    # https://github.com/hrbrmstr/albersusa
    library(albersusa)
    # make sf object from points
    # use the function to move them to AL and HI in this maap
    ggplot() +
        geom_sf(data = usa_sf("laea"), size = 0.125) +
        geom_point(data = site_data, aes(x = Longitude, y = Latitude), size = 4)

}
