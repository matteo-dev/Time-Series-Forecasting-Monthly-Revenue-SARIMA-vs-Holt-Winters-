#Étape 1 – Compréhension et analyse descriptive

# 1. Préparation de l'environnement et génération des données

library(forecast) # Indispensable pour les graphiques et outils de séries temporelles

# Fixation de la graine pour garantir la reproductibilité absolue des résultats
set.seed(42) 

# Paramètres de base de la série
n <- 120 # 10 ans de données mensuelles (12 * 10)
t <- 1:n # Index temporel

# Construction des composantes (Spécifications du Projet A)
tendance <- 100 + 0.8 * t # Tendance linéaire haussière déterministe
saison <- 15 * sin(2 * pi * t / 12) + 5 * cos(2 * pi * t / 12) # Cycle annuel périodique (12 mois)
erreur <- arima.sim(model = list(ar = 0.45), n = n, sd = 4) # Bruit autocorrélé (Processus AR(1))

# Création de l'objet ts (Time Series) 
# Démarre en janvier 2016 avec une fréquence mensuelle 
CA <- ts(tendance + saison + erreur, start = c(2016, 1), frequency = 12) 

# 2. Statistiques descriptives de base

cat("Résumé statistique du Chiffre d'Affaires\n")
print(summary(CA)) # Visualisation du minimum, moyenne, maximum, et quartiles
sd_CA <- sd(CA) # Mesure de la dispersion globale
cat(sprintf("Écart-type de la série : %.2f\n", sd_CA))

# 3. Diagnostics visuels (Tracés)

# Division de la fenêtre graphique en deux panneaux (1 ligne, 2 colonnes)
par(mfrow = c(1, 2)) 

# Graphique 1 : Tracé chronologique global
plot(CA, 
     main = "CA mensuel (2016-2025)", 
     ylab = "Milliers d'euros", 
     xlab = "Temps", 
     col = "darkblue", 
     lwd = 1.5)

# Graphique 2 : Tracé saisonnier pour analyser le cycle
# Permet de superposer les années pour repérer les mois forts et faibles
seasonplot(CA, 
           year.labels = TRUE, 
           col = 1:10, 
           pch = 19,
           main = "Profil saisonnier annuel", 
           ylab = "CA", 
           xlab = "Mois")

# Réinitialisation de la fenêtre graphique
par(mfrow = c(1, 1))





# Étape 2 – Décomposition et transformations

# 1. Choix du schéma de décomposition
# Graphiquement à l'Étape 1, l'amplitude des variations saisonnières reste constante 
# au fil des 10 années, indépendamment de la croissance de la tendance. 
# Le modèle approprié est donc additif.

# 2. Décomposition classique par moyennes mobiles
# La fonction decompose() isole la tendance (par moyenne mobile), 
# le cycle saisonnier, et le résidu (bruit).
dec_CA <- decompose(CA, type = "additive")

# 3. Visualisation graphique de la décomposition
# Affiche 4 panneaux : Série observée, Tendance, Saisonnalité, Bruit
plot(dec_CA, col = "darkblue", lwd = 1.5)

# 4. Extraction et analyse préliminaire des composantes
tendance_estimee <- dec_CA$trend
saisonnalite_estimee <- dec_CA$seasonal
bruit_estime <- dec_CA$random

# Visualisation ciblée de la composante saisonnière sur une seule année (12 mois)
# Permet de quantifier l'impact exact de chaque mois sur le CA global
mois <- 1:12
impact_saisonnier <- saisonnalite_estimee[1:12]
barplot(impact_saisonnier, 
        names.arg = month.abb, 
        col = ifelse(impact_saisonnier > 0, "forestgreen", "firebrick"),
        main = "Effet saisonnier mensuel (en K€)",
        ylab = "Écart à la tendance")

# 5. Statistiques du résidu (bruit)
# On retire les valeurs NA générées par la moyenne mobile aux extrémités
bruit_propre <- na.omit(bruit_estime)
cat("Analyse préliminaire du Bruit\n")
cat(sprintf("Moyenne des résidus : %.2f\n", mean(bruit_propre)))
cat(sprintf("Écart-type des résidus : %.2f\n", sd(bruit_propre)))





# Étape 3 – Stationnarité et modélisation

library(tseries) # Requis pour le test ADF
library(forecast) # Requis pour auto.arima et HoltWinters

# 1. Séparation rigoureuse de l'échantillon (Apprentissage / Test)

# Les 100 premiers mois pour l'entraînement (Janvier 2016 à Avril 2024)
train_CA <- window(CA, end = c(2024, 4))

# Les 20 derniers mois pour l'évaluation (Mai 2024 à Décembre 2025)
test_CA <- window(CA, start = c(2024, 5))

# 2. Étude de la stationnarité sur le jeu d'apprentissage

cat("Test ADF sur la série brute (Apprentissage)\n")

# p-valeur attendue >= 0.05, confirmant la non-stationnarité
print(adf.test(train_CA, alternative = "stationary")) 

# 3. Stationnarisation par différenciations successives

# Application de la différence première (lag=1) pour éliminer la tendance linéaire
train_diff1 <- diff(train_CA, lag = 1)

# Application de la différence saisonnière (lag=12) pour éliminer le cycle annuel
train_diff_final <- diff(train_diff1, lag = 12)

cat("Test ADF sur la série différenciée\n")

# p-valeur attendue < 0.05, confirmant l'obtention d'une série stationnaire
print(adf.test(train_diff_final, alternative = "stationary"))

# 4. Identification visuelle théorique (Outils de Box-Jenkins)

par(mfrow = c(1, 2))

# L'ACF et la PACF de la série stationnarisée permettent d'identifier p, q, P, Q

acf(train_diff_final, main = "ACF (Série stationnarisée)", lag.max = 36)
pacf(train_diff_final, main = "PACF (Série stationnarisée)", lag.max = 36)
par(mfrow = c(1, 1))

# 5. Modélisation - Approche 1 : Lissage Exponentiel (Holt-Winters)

# Modèle avec tendance et saisonnalité additives justifié à l'Étape 2
modele_hw <- HoltWinters(train_CA, seasonal = "additive")

# 6. Modélisation - Approche 2 : SARIMA

# L'algorithme cherche la meilleure combinaison (p,d,q)(P,D,Q) minimisant l'AIC/BIC

# On désactive les approximations pour forcer une exploration exhaustive de l'espace des modèles
modele_sarima <- auto.arima(train_CA, 
                            seasonal = TRUE, 
                            stepwise = FALSE, 
                            approximation = FALSE)

cat("Résumé du modèle SARIMA optimisé\n")
print(summary(modele_sarima))





# Étape 4 – Validation et prévision

# 1. Analyse diagnostique des résidus

cat("Test de Ljung-Box : Résidus SARIMA\n")

# Vérification globale de l'absence d'autocorrélation (Bruit Blanc)
# Le test de Ljung-Box teste si les résidus sont un bruit blanc.
# On attend une p-valeur > 0.05 pour ne pas rejeter H0.
print(Box.test(residuals(modele_sarima), lag = 24, type = "Ljung-Box"))

cat("Test de Ljung-Box : Résidus Holt-Winters\n")
print(Box.test(residuals(modele_hw), lag = 24, type = "Ljung-Box"))

# Affichage graphique complet pour les résidus du SARIMA
checkresiduals(modele_sarima)

# 2. Prévision à horizon h = 20 (sur la période de l'échantillon Test)
# forecast génère la prévision point par point ainsi que 
# les intervalles de confiance (généralement 80% et 95%)
prev_sarima <- forecast(modele_sarima, h = 20)
prev_hw <- forecast(modele_hw, h = 20)

# 3. Évaluation et comparaison des performances (Métriques d'erreur)
# La fonction accuracy() calcule le RMSE, MAE, et MAPE
cat("Performances hors-échantillon (Test) : SARIMA\n")
print(accuracy(prev_sarima, test_CA))

cat("Performances hors-échantillon (Test) : Holt-Winters\n")
print(accuracy(prev_hw, test_CA))

# 4. Tracé graphique des prévisions vs Réalité
par(mfrow = c(2, 1))

# Graphique SARIMA
plot(prev_sarima, 
     main = "Prévisions SARIMA vs Réalités (Mai 2024 - Déc 2025)", 
     ylab = "Chiffre d'Affaires", 
     xlab = "Temps")

# Superposition des vraies données de test en rouge
lines(test_CA, col = "red", lwd = 2) 
legend("topleft", legend = c("Prévision SARIMA", "Réalisations (Test)"), 
       col = c("blue", "red"), lty = 1, lwd = 2, cex = 0.8)

# Graphique Holt-Winters
plot(prev_hw, 
     main = "Prévisions Holt-Winters vs Réalités", 
     ylab = "Chiffre d'Affaires", 
     xlab = "Temps")
lines(test_CA, col = "red", lwd = 2)
legend("topleft", legend = c("Prévision HW", "Réalisations (Test)"), 
       col = c("blue", "red"), lty = 1, lwd = 2, cex = 0.8)

par(mfrow = c(1, 1))





# Étape 5 – Discussion critique et conclusion

# Création d'un data.frame récapitulant les métriques clés de l'Étape 4
# Idéal pour l'exportation vers LaTeX
comparatif_modeles <- data.frame(
  Modele = c("Holt-Winters Additif", "SARIMA(1,0,0)(0,1,1)[12] avec dérive"),
  RMSE_Test = c(9.17, 6.55), # Erreur quadratique pénalisant les grands écarts
  MAPE_Test_pct = c(4.46, 3.05), # Erreur moyenne en pourcentage (métrique métier)
  Ljung_Box_pval = c(0.046, 0.364), # Test de blancheur des résidus
  Validation_Residus = c("Échec (Autocorrélation)", "Succès (Bruit Blanc)")
)

cat("Tableau de Décision Final\n")
print(comparatif_modeles)