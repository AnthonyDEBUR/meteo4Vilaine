library(DBI)
library(RPostgres)
library(yaml)
library(sf)
library(meteo4Vilaine)

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

# create_sql_requete_calcule_somme(con)

# library(mapview)


date<-'2005-03-01'
pluvio<-pluviometrie_entre_2_dates(date_debut=date,
                           date_fin = date,
                           con=con,
                           taux_completude=1)


data("grd", package="meteo4Vilaine")
mnt <- terra::rast(system.file("mnt.tif", package = "meteo4Vilaine"))

# Extraire l'altitude pour les stations
pluvio$altitude <- terra::extract(mnt, terra::vect(pluvio))[, 2]

# Définir le variogramme et le modèle de krigeage
vgm_model <- gstat::vgm(psill = 33.71, model = "Sph", range = 90593, nugget = 0.79)

# Créer le modèle de krigeage universel
model <- gstat::gstat(id = "somme_precipitations", formula = somme_precipitations ~ altitude, data = pluvio, model = vgm_model)


# Interpolation par krigeage
krige_result <- predict(model, newdata = grd)

pluvio$pluvio_krigee <- round(valeurs_proches_sf (pluvio, krige_result),1)



