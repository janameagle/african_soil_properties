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

head(countries)
unique(countries$SOVEREIGNT)
unique(countries$ADMIN)
names(countries)
countries2 <- countries[, c("scalerank", "SOVEREIGNT")]

coi <- c("Benin", "Burkina Faso", "Cabo Verde", "Ivory Coast", "Gambia", 
         "Ghana", "Mali", "Niger", "Nigeria", "Senegal", "Togo")

# test <- countries[countries$SOVEREIGNT != countries$ADMIN,]
# head(test)
# unique(test$ADMIN)
# unique(test$SOVEREIGNT)

aoi <- countries[countries$ADMIN %in% coi, ]
ghana <- countries[countries$ADMIN == "Ghana", ]
nrow(ghana)
nrow(aoi)
unique(aoi$ADMIN)

# using the terra package to create a new SpatVector
aoi.v <- vect(aoi)
class(aoi.v)     

ghana.v <- vect(ghana)

############################
# get the soil bulk density
# access and crop 
# tif.bd <- paste0("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/",
#                  c("sol_db_od_m_30m_0..20cm_2001..2017_v0.13_wgs84.tif",
#                    "sol_db_od_m_30m_20..50cm_2001..2017_v0.13_wgs84.tif",
#                    "sol_db_od_md_30m_0..20cm_2001..2017_v0.13_wgs84.tif"))
# tif.bd
# md data is the associated prediction error

# load the values
# bd30m <- lapply(tif.bd, function(i){crop(rast(i), aoi.v)})
# bd30m.sp = do.call(cbin, lapply(bd30m, function(i){as.data.frame(i)}))
# str(sol30m.sp)
# 
# rast("/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/sol_db_od_m_30m_0..20cm_2001..2017_v0.13_wgs84.tif")

bld = "/vsicurl/https://s3.eu-central-1.wasabisys.com/africa-soil/layers30m/sol_db_od_m_30m_0..20cm_2001..2017_africa_epsg4326_v0.1.tif"

bld30m = crop(rast(bld), ghana.v)
bld30m.sp = as.data.frame(bld30m)

# values are in 10*kg/m3
# bld30m.sp$bld_l1 = bld30m.sp$sol_db_od_m_30m_0..20cm_2001..2017_africa_epsg4326_v0.1 * 10

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
