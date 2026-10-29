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