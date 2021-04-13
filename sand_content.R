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

coi <- c("Benin", "Burkina Faso", "Cabo Verde", "Gambia", 
         "Ghana","Ivory Coast", "Mali", "Niger", "Nigeria", "Senegal", "Togo")



#### sand content ########################
# get the soil bulk density
# access and crop 
tif20 <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                c("sol_sand_tot_psa_m_30m_0..20cm_2001..2017_africa_epsg4326_v0.1.tif"))

tif50 <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                c("sol_sand_tot_psa_m_30m_20..50cm_2001..2017_africa_epsg4326_v0.1.tif"))



#### automatic loop ###################
all_20 <- rast(tif20) # get the different rasters from online
all_50 <- rast(tif50) # get the different rasters from online

coi <- c("Niger", "Nigeria", "Senegal", "Togo")

for (k in coi) {
  print(k)
  aoi <- countries[countries$ADMIN == k, ]
  aoi.v <- vect(aoi) # create SpatVector
  
  data_20 <- all_20
  data_50 <- all_50
  
  print("vector created")
  print("20m")
  data_ctr <- crop(data_20, aoi.v)
  print("cropped")
  print(paste0("Extent:", ext(data_ctr)))
  mask_ctr <- rasterize(aoi.v, data_ctr)
  data_ctr_msk <- mask(data_ctr, mask_ctr) 
  print("masked")
  
  # plot(bd30m_ctr[[1]])
  plot(data_ctr_msk)
  
  # save the new cropped raster
  print("writing file")
  writeRaster(data_ctr_msk, paste0("output/", k, "/sand_content_0m_20m_", k, ".tif"))
  
  print("50m")
  data_ctr <- crop(data_50, aoi.v)
  print("cropped")
  print(paste0("Extent:", ext(data_ctr)))
  mask_ctr <- rasterize(aoi.v, data_ctr)
  data_ctr_msk <- mask(data_ctr, mask_ctr) 
  print("masked")
  
  # plot(bd30m_ctr[[1]])
  plot(data_ctr_msk)
  
  # save the new cropped raster
  print("writing file")  
  
  writeRaster(data_ctr_msk, paste0("output/", k, "/sand_content_20m_50m_", k, ".tif"))
  print(paste0(k, " done"))
}




#### sand content error ########################
# access and crop 
tif20 <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                c("sol_sand_tot_psa_md_30m_0..20cm_2001..2017_africa_epsg4326_v0.1.tif"))

tif50 <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/", 
                c("sol_sand_tot_psa_md_30m_20..50cm_2001..2017_africa_epsg4326_v0.1.tif"))

# md data is the associated prediction error
#### automatic loop ###################
data_all_20 <- rast(tif20) # get the different rasters from online
data_all_50 <- rast(tif50) # get the different rasters from online

coi <- c("Benin", "Burkina Faso", "Gambia", 
         "Ghana","Ivory Coast", "Mali", "Niger", "Nigeria", "Senegal", "Togo")

for (k in coi) {
  print(k)
  aoi <- countries[countries$ADMIN == k, ]
  aoi.v <- vect(aoi) # create SpatVector
  
  data_20 <- data_all_20
  data_50 <- data_all_50
  
  print("vector created")
  print("20m")
  data_ctr <- crop(data_20, aoi.v)
  print("cropped")
  print(paste0("Extent:", ext(data_ctr)))
  mask_ctr <- rasterize(aoi.v, data_ctr)
  data_ctr_msk <- mask(data_ctr, mask_ctr) 
  print("masked")
  
  # plot(bd30m_ctr[[1]])
  # plot(data_ctr_msk)
  
  # save the new cropped raster
  print("writing file")
  writeRaster(data_ctr_msk, paste0("output/", k, "/sand_content_0m_20m_errors_", k, ".tif"))
  
  print("50m")
  data_ctr <- crop(data_50, aoi.v)
  print("cropped")
  print(paste0("Extent:", ext(data_ctr)))
  mask_ctr <- rasterize(aoi.v, data_ctr)
  data_ctr_msk <- mask(data_ctr, mask_ctr) 
  print("masked")
  
  # plot(bd30m_ctr[[1]])
  # plot(data_ctr_msk)
  
  # save the new cropped raster
  print("writing file")  
  
  writeRaster(data_ctr_msk, paste0("output/", k, "/sand_content_20m_50m_errors_", k, ".tif"))
  print(paste0(k, " done"))
}



