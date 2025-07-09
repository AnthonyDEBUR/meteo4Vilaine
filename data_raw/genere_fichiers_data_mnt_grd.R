library(sf)
library(elevatr)
library(terra)
library(DBI)
library(RPostgres)

# Connexion à la base PostgreSQL
#config <- yaml::read_yaml("//etc//Vilaine_explorer//config.yml")
config <- yaml::read_yaml("C://workspace//gwilenalim//yaml//config.yml")

# Connexion à la base PostgreSQL
con <- DBI::dbConnect(
  Postgres(),
  host = config$host,
  port = config$port,
  user = config$user,
  password = config$password,
  dbname = config$dbname
)

# Code pour générer le MNT autour des stations météo de la Vilaine
stations <- sf::st_read(con, query = "SELECT * FROM meteo.stations_meteo_france_quotidienne")
stations <- sf::st_transform(stations, 2154)

buffer <- sf::st_bbox(stations) %>%
  sf::st_as_sfc() %>%
  sf::st_buffer(10000) %>%
  sf::st_as_sf(crs = sf::st_crs(2154))

mnt <- elevatr::get_elev_raster(locations = buffer, z = 8, prj = 2154, clip = "bbox")
mnt <-terra::rast(mnt)
emprise<-sf::st_bbox(buffer)

# grille de 1 km²
grd <- expand.grid(
  x = seq(emprise["xmin"], emprise["xmax"], by = 1000),
  y = seq(emprise["ymin"], emprise["ymax"], by = 1000)
)
grd <- sf::st_as_sf(grd, coords = c("x", "y"), crs = 2154)
grd$altitude <- terra::extract(mnt, terra::vect(grd))[, 2]

terra::writeRaster(mnt, filename = "inst/mnt.tif", overwrite = TRUE)
sf::write_sf(grd, dsn = "inst/grd.gpkg", overwrite = TRUE)
