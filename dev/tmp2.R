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


grd <- sf::read_sf(system.file("grd.gpkg", package = "meteo4Vilaine"))
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


##### Calibration pour données mensuelles #####


date_debut<-'2005-03-01'
date_fin<-'2005-03-31'
pluvio<-pluviometrie_entre_2_dates(date_debut=date_debut,
                                   date_fin = date_fin,
                                   con=con,
                                   taux_completude=1)


write.csv2(pluvio, "pluviometrie_mensuelle.csv")

# Extraire l'altitude pour les stations
pluvio$altitude <- terra::extract(mnt, terra::vect(pluvio))[, 2]

# Définir le variogramme et le modèle de krigeage
vgm_model <- gstat::vgm(psill = 33.71, model = "Sph", range = 90593, nugget = 0.79)

vgm_model_mensuel <- gstat::vgm(psill = 43.86, model = "Sph", range = 77267, nugget = 0)



# Créer le modèle de krigeage universel
model <- gstat::gstat(id = "somme_precipitations",
                      formula = somme_precipitations ~ altitude,
                      data = pluvio,
                      model = vgm_model_mensuel)


# Interpolation par krigeage
krige_result <- predict(model, newdata = grd)

pluvio$pluvio_krigee <- round(valeurs_proches_sf (pluvio, krige_result),1)



library(caret)
library(lubridate)
library(gstat)

set.seed(123)
mois_valides <- c()
resultats <- data.frame(mois = as.Date(character()), RMSE = numeric(), MAE = numeric(), Biais = numeric())

while (length(mois_valides) < 120) {
  # Tirage aléatoire d’un mois entre 1980 et 1996
  annee <- sample(1980:2024, 1)
  mois <- sample(1:12, 1)
  date_debut <- as.Date(sprintf("%04d-%02d-01", annee, mois))
  date_fin <- ceiling_date(date_debut, "month") - 1

  pluvio <- tryCatch({
    pluviometrie_entre_2_dates(date_debut = date_debut, date_fin = date_fin, con = con, taux_completude = 1)
  }, error = function(e) return(NULL))

  if (is.null(pluvio) || nrow(pluvio) < 10) {
    message("⛔ Pas assez de données pour ", date_debut)
    next
  }

  if (median(pluvio$somme_precipitations, na.rm = TRUE) < 30) {
    message("⚠️ Médiane < 30 mm pour ", date_debut)
    next
  }

  # Partition train/test
  train_index <- createDataPartition(pluvio$somme_precipitations, p = 2/3, list = FALSE)
  pluvio_train <- pluvio[train_index, ]
  pluvio_test <- pluvio[-train_index, ]

  # Conversion en objets spatiaux si nécessaire
  pluvio_train_sp <- sf::st_as_sf(pluvio_train)
  pluvio_test_sp <- sf::st_as_sf(pluvio_test)

  # Modèle de krigeage
  model <- gstat(id = "somme_precipitations", formula = somme_precipitations ~ altitude,
                 data = pluvio_train_sp, model = vgm_model_mensuel)

  krige_test <- tryCatch({
    predict(model, newdata = pluvio_test_sp)
  }, error = function(e) return(NULL))

  if (is.null(krige_test)) {
    message("❌ Échec du krigeage pour ", date_debut)
    next
  }

  obs <- pluvio_test_sp$somme_precipitations
  pred <- krige_test$somme_precipitations.pred

  rmse <- sqrt(mean((obs - pred)^2))
  mae <- mean(abs(obs - pred))
  bias <- mean(pred - obs)

  resultats <- rbind(resultats, data.frame(mois = date_debut, RMSE = rmse, MAE = mae, Biais = bias))
  mois_valides <- c(mois_valides, date_debut)

  message("✅ Mois retenu : ", format(date_debut, "%Y-%m"), " | RMSE = ", round(rmse, 2))
}

# Résumé final
print(resultats)
summary(resultats)
