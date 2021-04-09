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

# aoi <- countries[countries$ADMIN %in% coi, ]
# benin <- countries[countries$ADMIN == "Benin", ]
# burkinafaso <- countries[countries$ADMIN == "Burkina Faso", ]
# caboverde <- countries[countries$ADMIN == "Cabo Verde", ]
# ivorycoast <- countries[countries$ADMIN == "Ivory Coast", ]
# gambia <- countries[countries$ADMIN == "Gambia", ]
# ghana <- countries[countries$ADMIN == "Ghana", ]
# mali <- countries[countries$ADMIN == "Mali", ]
# niger <- countries[countries$ADMIN == "Niger", ]
# nigeria <- countries[countries$ADMIN == "Nigeria", ]
# senegal <- countries[countries$ADMIN == "Senegal", ]
# togo <- countries[countries$ADMIN == "Togo", ]



############################
 # get the soil bulk density
# access and crop 
tif20.bd <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                 c("sol_db_od_m_30m_0..20cm_2001..2017_africa_epsg4326_v0.1.tif"))

tif50.bd <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                    c("sol_db_od_m_30m_20..50cm_2001..2017_africa_epsg4326_v0.1.tif"))
 

# md data is the associated prediction error

#### manual ##############


coi <- "Nigeria"
aoi.v <- vect(nigeria) # create SpatVector

# load the values
bd30m_all <- rast(tif20.bd) # get the different rasters from online
#bd30m_all_orig <- lapply(tif.bd, function(i){rast(i)})

# using the terra package to create a new SpatVector
#aoi <- caboverde # could be replaced by for loop


# crop the data
 bd30m_ctr <- crop(bd30m_all, aoi.v)
 ext(bd30m_ctr)
 mask_ctr <- rasterize(aoi.v, bd30m_ctr)
 bd30m_ctr_msk <- mask(bd30m_ctr, mask_ctr)

 writeRaster(bd30m_ctr_msk, paste0("output/", coi, "/bulk_density_0m_20m_", coi, "_masked.tif"))

 
#### 20 - 50m
 
 bd30m_all <- rast(tif50.bd) # get the different rasters from online 
 # crop the data
 bd30m_ctr <- crop(bd30m_all, aoi.v)
 ext(bd30m_ctr)
 mask_ctr <- rasterize(aoi.v, bd30m_ctr)
 bd30m_ctr_msk <- mask(bd30m_ctr, mask_ctr) 
 
 writeRaster(bd30m_ctr_msk, paste0("output/", coi, "/bulk_density_20m_50m_", coi, "_masked.tif"))

 
 

 #### automatic loop ###################
bd30m_all_20 <- rast(tif20.bd) # get the different rasters from online
bd30m_all_50 <- rast(tif50.bd) # get the different rasters from online
 
coi <- c("Benin", "Burkina Faso", "Cabo Verde", "Ivory Coast", "Gambia", 
         "Ghana", "Mali", "Niger", "Nigeria", "Senegal", "Togo")

for (k in coi) {
  print(k)
  aoi <- countries[countries$ADMIN == k, ]
  aoi.v <- vect(aoi) # create SpatVector
  
  bd30m_20 <- bd30m_all_20
  bd30m_50 <- bd30m_all_50
  
  print("vector created")
  print("20m")
  bd30m_ctr <- crop(bd30m_20, aoi.v)
  print("cropped")
  print(paste0("Extent:", ext(bd30m_ctr)))
  mask_ctr <- rasterize(aoi.v, bd30m_ctr)
  bd30m_ctr_msk <- mask(bd30m_ctr, mask_ctr) 
  print("masked")

 # plot(bd30m_ctr[[1]])
  plot(bd30m_ctr_msk)

# save the new cropped raster
  print("writing file")
  writeRaster(bd30m_ctr_msk, paste0("output/", k, "/bulk_density_0m_20m_", k, "_masked.tif"))
 
  print("50m")
  bd30m_ctr <- crop(bd30m_50, aoi.v)
  print("cropped")
  print(paste0("Extent:", ext(bd30m_ctr)))
  mask_ctr <- rasterize(aoi.v, bd30m_ctr)
  bd30m_ctr_msk <- mask(bd30m_ctr, mask_ctr) 
  print("masked")
  
  # plot(bd30m_ctr[[1]])
  plot(bd30m_ctr_msk)
  
  # save the new cropped raster
  print("writing file")  
  
  writeRaster(bd30m_ctr_msk, paste0("output/", k, "/bulk_density_20m_50m_", k, "_masked.tif"))
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




################################################################################
#### minimize current files
getwd()
myfile <- raster("C:/Users/jmaie/Documents/WASCAL-DE_Coop/african_soil_properties/output/Benin/bulk_density_0m_20m_Benin_masked.tif")
extent(myfile)
extent(benin)
plot(myfile)
plot(benin)
class(myfile)
