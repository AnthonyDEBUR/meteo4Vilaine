library(meteo4Vilaine)

# Charger les bibliothèques nécessaires
library(sf)
library(dplyr)
library(DBI)
library(RPostgres)
library(yaml)


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

# Coordonnées approximatives du centroïde de Rennes (en WGS84)
rennes_coords <- data.frame(
  lon = -1.6794,
  lat = 48.1147
)

# Créer un objet sf de type point en WGS84 (EPSG:4326)
rennes_sf <- st_as_sf(rennes_coords, coords = c("lon", "lat"), crs = 4326)

# Reprojeter en Lambert 93 (EPSG:2154)
rennes_l93 <- st_transform(rennes_sf, crs = 2154)


krige_pluie_journaliere(rennes_l93,
                        date_debut="2006-01-01",
                        date_fin="2006-12-31",
                        con=con)

library(tools4Vilaine)


shp_STATIONS_DE_MESURE$pluvio2006test<-krige_pluie_journaliere(shp_STATIONS_DE_MESURE,
                        date_debut="2023-01-01",
                        date_fin="2023-12-31",
                        con=con)


# Coordonnées approximatives du centroïde de Rennes (en WGS84)
blain_coords <- data.frame(
  lon = -1.77,
  lat = 47.47
)

# Créer un objet sf de type point en WGS84 (EPSG:4326)
blain_sf <- st_as_sf(blain_coords, coords = c("lon", "lat"), crs = 4326)

# Reprojeter en Lambert 93 (EPSG:2154)
blain_sf <- st_transform(blain_sf, crs = 2154)


krige_pluie_journaliere(blain_sf,
                        date_debut="2020-01-01",
                        date_fin="2020-01-31",
                        con=con)

tmp<-pluviometrie_entre_2_dates(date_debut="2020-01-01", date_fin = "2020-01-31",con=con)%>%subset(id=="44015001")

library(mapview)
mapview(blain_sf) + mapview(tmp, col.regions="red")

annee<-"2020"
mois<-"01"
nb_jours<-"31"

date_debut<-paste0(annee,"-",mois,"-01")
date_fin<-paste0(annee,"-",mois,"-",nb_jours)
# Requête SQL
query <- paste0("
  SELECT *
  FROM meteo.donnees_journalieres
  WHERE id_station = '44015001'
    AND date >= '",date_debut,"'
    AND date <= '",date_fin,"';
")

# Exécuter la requête et stocker le résultat dans data_brutes
data_brutes <- dbGetQuery(con, query)


sum(data_brutes$RR)

tmp<-pluviometrie_entre_2_dates(date_debut=date_debut,
                                date_fin = date_fin,
                                con=con)
tmp<-tmp%>%subset(id=="44015001")%>%select(somme_precipitations)
mapview(tmp)

shp_STATIONS_DE_MESURE$pluie<-krige_pluie_journaliere(st_transform(shp_STATIONS_DE_MESURE, 2154),
                        date_debut=date_debut,
                        date_fin=date_fin,
                        con=con)


grd$grd0<-krige_pluie_journaliere(grd,
                                                      date_debut=date_debut,
                                                      date_fin=date_fin,
                                                      con=con)
mapview(grd, zcol="grd0") + mapview(blain_sf)




# Coordonnées approximatives du centroïde de Saffré (en WGS84)
ville_coords <- data.frame(
  lon = -1.578,
  lat = 47.50143
)

# Créer un objet sf de type point en WGS84 (EPSG:4326)
ville_sf <- st_as_sf(ville_coords, coords = c("lon", "lat"), crs = 4326)

# Reprojeter en Lambert 93 (EPSG:2154)
ville_sf <- st_transform(ville_sf, crs = 2154)



resultat<-data.frame(date=c(), pluie=c())

for(i in 1:30)
{date<-paste0("2020-04-", ifelse(i<10,"0",""),i)

  pluie<- krige_pluie_journaliere(ville_sf,
                        date_debut=date,
                        date_fin=date,
                        con=con)

  resultat<-rbind(resultat, c(date, pluie))
  }
sum(as.numeric(resultat[,2]))

tmp<-pluviometrie_entre_2_dates(date_debut="2020-01-01", date_fin = "2020-01-31",con=con)%>%subset(id=="44015001")



