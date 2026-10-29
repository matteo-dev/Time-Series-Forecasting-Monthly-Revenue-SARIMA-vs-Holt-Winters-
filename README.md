# Modélisation et Prévision du Chiffre d'Affaires Mensuel (Projet A)

*Read this in [English](#english-version).*

## Contexte du Projet
Ce projet vise à analyser et prévoir l'évolution du Chiffre d'Affaires (CA) mensuel d'une entreprise sur une période de 10 ans, soit 120 observations allant de 2016 à 2025. L'objectif est d'isoler les composantes structurelles (tendance et saisonnalité) afin d'identifier et de déployer un modèle prédictif mathématiquement robuste.

## Démarche Analytique
La méthodologie employée suit rigoureusement l'approche de Box-Jenkins :
1. **Analyse Descriptive** : Identification visuelle et statistique d'une tendance haussière forte et d'un cycle saisonnier annuel d'amplitude constante, justifiant le choix d'un schéma additif.
2. **Stationnarisation** : Application de filtres de différenciation simple ($\Delta_1$) pour la tendance et saisonnière ($\Delta_{12}$) pour le cycle, validés par le test de Dickey-Fuller Augmenté (ADF = -5.58, p-valeur = 0.01).
3. **Modélisation** : Confrontation d'un modèle de lissage (Holt-Winters Additif) face à un processus stochastique (SARIMA(1,0,0)(0,1,1)[12] avec dérive) identifié via l'optimisation des critères AIC/BIC et l'analyse des corrélogrammes.
4. **Validation et Prévision** : Évaluation hors-échantillon sur les 20 derniers mois (Mai 2024 - Décembre 2025) et analyse diagnostique stricte des résidus.

## Résultats et Conclusion
Le modèle **SARIMA(1,0,0)(0,1,1)[12] avec dérive** surclasse l'approche de Holt-Winters sur tous les critères d'évaluation :
- **Précision** : Erreur moyenne absolue en pourcentage (MAPE) de **3.05%** pour le SARIMA, contre 4.46% pour Holt-Winters.
- **Fiabilité Statistique** : Le test de Ljung-Box confirme que seuls les résidus du modèle SARIMA forment un Bruit Blanc strict (p-valeur = 0.364), tandis que ceux de Holt-Winters souffrent d'autocorrélation (p-valeur = 0.046).
- **Recommandation Managériale** : Déploiement du modèle SARIMA recommandé. En capturant parfaitement l'inertie des erreurs, il est le seul à garantir des intervalles de confiance (à 80% et 95%) fiables pour le pilotage stratégique de l'entreprise.

## Technologies Utilisées
- **Langage** : R
- **Packages Principaux** : `forecast`, `tseries`

---

<a id="english-version"></a>
# Time Series Forecasting: Monthly Revenue (Project A)

## Project Context
This project aims to analyze and forecast the monthly revenue of a company over a 10-year period, utilizing 120 monthly observations from January 2016 to December 2025. The goal is to isolate structural components (trend and seasonality) to build and deploy a mathematically robust predictive model.

## Analytical Approach
The methodology rigorously follows the Box-Jenkins approach:
1. **Descriptive Analysis**: Identified a strong upward trend and an annual seasonality with constant amplitude, justifying the use of an additive scheme.
2. **Stationarization**: Applied simple ($\Delta_1$) and seasonal ($\Delta_{12}$) differencing filters to remove the trend and cycle, successfully validated by the Augmented Dickey-Fuller (ADF) test (p-value = 0.01).
3. **Modeling**: Compared an exponential smoothing model (Additive Holt-Winters) against a stochastic process (SARIMA(1,0,0)(0,1,1)[12] with drift), identified via ACF/PACF analysis and AIC/BIC optimization.
4. **Validation & Forecasting**: Conducted out-of-sample evaluation on a 20-month hold-out dataset (May 2024 - Dec 2025) paired with strict residual diagnostics.

## Results & Conclusion
The **SARIMA(1,0,0)(0,1,1)[12] with drift** model significantly outperforms the Holt-Winters approach across all metrics:
- **Accuracy**: Achieved a Mean Absolute Percentage Error (MAPE) of **3.05%**, compared to 4.46% for Holt-Winters.
- **Statistical Reliability**: The Ljung-Box test confirms that only the SARIMA model's residuals form a strict White Noise (p-value = 0.364). Holt-Winters failed this diagnostic due to persistent residual autocorrelation (p-value = 0.046).
- **Managerial Recommendation**: The SARIMA model is recommended for deployment. By fully capturing error inertia, it guarantees reliable 80% and 95% confidence intervals, which is essential for risk-managed financial decision-making.

## Tech Stack
- **Language**: R
- **Core Packages**: `forecast`, `tseries`
