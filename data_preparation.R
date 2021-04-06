################################################################################
#### Soil property data will be downloaded for all WASCAL countries ############
#### data details: https://zenodo.org/search?page=1&size=20&q=iSDAsoil #########
#### workflow: https://gitlab.com/openlandmap/africa-soil-and-agronomy-data-cube
################################################################################

library(rgdal)
library(terra)
library(raster)

# get vector files of the WASCAL countries
countries <- readOGR("C:/Users/jmaie/Documents/WASCAL-DE_Coop/african_soil_properties/data/naturalearthdata", "ne_10m_admin_0_countries")

coi <- c("Benin", "Burkina Faso", "Cabo Verde", "Ivory Coast", "Gambia", 
         "Ghana", "Mali", "Niger", "Nigeria", "Senegal", "Togo")

# test <- countries[countries$SOVEREIGNT != countries$ADMIN,]
# head(test)
# unique(test$ADMIN)
# unique(test$SOVEREIGNT)

aoi <- countries[countries$ADMIN %in% coi, ]
benin <- countries[countries$ADMIN == "Benin", ]
burkinafaso <- countries[countries$ADMIN == "Burkina Faso", ]
caboverde <- countries[countries$ADMIN == "Cabo Verde", ]
ivorycoast <- countries[countries$ADMIN == "Ivory Coast", ]
gambia <- countries[countries$ADMIN == "Gambia", ]
ghana <- countries[countries$ADMIN == "Ghana", ]
mali <- countries[countries$ADMIN == "Mali", ]
niger <- countries[countries$ADMIN == "Niger", ]
nigeria <- countries[countries$ADMIN == "Nigeria", ]
senegal <- countries[countries$ADMIN == "Senegal", ]
togo <- countries[countries$ADMIN == "Togo", ]



############################
# get the soil bulk density
# access and crop 
tif.bd <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                 c("sol_db_od_m_30m_0..20cm_2001..2017_africa_epsg4326_v0.1.tif",
                   "sol_db_od_m_30m_20..50cm_2001..2017_africa_epsg4326_v0.1.tif"))

tif.bd
# md data is the associated prediction error

# load the values
#bd30m_all <- rast(tif.bd) # get the different rasters from online
bd30m_all <- lapply(tif.bd, function(i){rast(i)})

# using the terra package to create a new SpatVector
aoi <- caboverde # could be replaced by for loop
coi <- c("Niger", "Nigeria", "Senegal", "Togo")
aoi.v <- vect(aoi) # create SpatVector

# crop the data
#bd30m_ctr <- crop(bd30m_all, aoi.v)

for (k in coi) {
  print(k)
  aoi <- countries[countries$ADMIN == k, ]
  aoi.v <- vect(aoi) # create SpatVector
  print("vector created")
  bd30m_ctr <- do.call(cbind, lapply(bd30m_all, function(i){crop(i, aoi.v)}))
  print("cropped")
  mask_ctr <- rasterize(aoi.v, bd30m_ctr[[1]])
  bd30m_ctr_msk <- lapply(bd30m_ctr, function(i){mask(i, mask_ctr)})
  print("masked")

  plot(bd30m_ctr[[1]])
  plot(bd30m_ctr_msk[[1]])

# save the new cropped raster
  print("writing files")
  writeRaster(bd30m_ctr[[1]], paste0("output/", k, "/bulk_density_0m_20m_", k, ".tif"))
  writeRaster(bd30m_ctr[[2]], paste0("output/", k, "/bulk_density_20m_50m_", k, ".tif"))
  writeRaster(bd30m_ctr_msk[[1]], paste0("output/", k, "/bulk_density_0m_20m_", k, "_masked.tif"))
  writeRaster(bd30m_ctr_msk[[2]], paste0("output/", k, "/bulk_density_20m_50m_", k, "_masked.tif"))
  print("country done")
}


# bld30m.sp = as.data.frame(bld30m)

# values are in 10*kg/m3
# bld30m.sp$bld_l1 = bld30m.sp$sol_db_od_m_30m_0..20cm_2001..2017_africa_epsg4326_v0.1 * 10

class(bld30m)
plot(bld30m)


bd20 <- rast("C:/Users/jmaie/Documents/WASCAL-DE_Coop/african_soil_properties/data/bulk_density/sol_db_od_m_30m_0..20cm_2001..2017_v0.13_wgs84.tif")
class(bd20)
bd20.aoi <- crop(bd20, aoi.v)
bd20.df <- as.data.frame(bd20.aoi)
class(bd20.df)
str(bd20.df)


bd20.ghana <- crop(bd20, ghana.v)
head(bd20.ghana)
bd20.df <- as.data.frame(bd20.ghana)
class(bd20.df)
str(bd20.df)

# transform values from log to ppms
bd20.df$l1 = expm1(bd20.df$sol_db_od_m_30m_0..20cm_2001..2017_v0.13_wgs84 / 10)
head(bd20.df)

# crop area of interest using the polygon map 
ghana.r = rasterize(ghana.v, bd20.ghana[[1]])
bd20.m = as(as(raster(ghana.r), "SpatialGridDataFrame"), "SpatialPixelsDataFrame")
bd20.m$l1 = bd20.df$l1[bd20.m@grid.index]


# plot the extractabel bulk density for the aoi
plot(bd20.ghana)
spplot(bd20.m$l1)
