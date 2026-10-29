import streamlit as st
from PIL import Image

# 1. Page Configuration
st.set_page_config(page_title="Time Series Forecasting", layout="wide", page_icon="📈")

# 2. Header and Introduction
st.title("📈 Time Series Forecasting: Monthly Revenue")
st.markdown("""
Welcome to the interactive dashboard for **Project A**. 
This application presents a comprehensive econometric analysis and forecasting pipeline for a 10-year monthly revenue time series (2016-2025).
""")

# 3. Tab Navigation matching the Academic Steps
tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "1. Descriptive Analysis",
    "2. Decomposition",
    "3. Stationarity",
    "4. Modeling & Validation",
    "5. Forecasting & Conclusion"
])

with tab1:
    st.header("1. Context & Visual Diagnostics")
    st.markdown("Initial visual diagnostics of the 120-month dataset reveal a clear deterministic upward linear trend and a strict annual seasonal cycle (12-month period).")
    st.image("Ca & Profil saisonnier plot.png", caption="Monthly Revenue (2016-2025) and Annual Seasonal Profile")

with tab2:
    st.header("2. Time Series Decomposition")
    st.markdown("Because the amplitude of the seasonal fluctuations remains strictly constant despite the rising global trend, a **classical additive decomposition** was chosen over a multiplicative one.")
    col1, col2 = st.columns(2)
    with col1:
        st.image("decomposition of additive time series.png", caption="Classical Additive Decomposition (Observed, Trend, Seasonal, Random)")
    with col2:
        st.image("effet saisonnier mensuel en K.png", caption="Isolated Monthly Seasonal Effect (in k€)")

with tab3:
    st.header("3. Stationarity & Box-Jenkins Identification")
    st.markdown("To satisfy stationarity conditions, a first-order difference (lag=1) was applied to remove the trend, followed by a seasonal difference (lag=12) to remove the annual cycle. The Augmented Dickey-Fuller test confirms stationarity (p-value = 0.01).")
    st.image("ACF & PACF.png", caption="ACF and PACF of the Doubly Differenced Series")

with tab4:
    st.header("4. Model Validation: SARIMA")
    st.markdown("Based on the information criteria and correlograms, a **SARIMA(1,0,0)(0,1,1)[12] with drift** was optimized. The Ljung-Box diagnostic test confirms that the model's residuals constitute strict White Noise, validating the mathematical robustness of the model.")
    st.image("Resume ARIMA.png", caption="Residual Diagnostics for the SARIMA Model")

with tab5:
    st.header("5. Forecasting & Model Comparison")
    st.markdown("We compared the predictive performance of the SARIMA stochastic process against an Additive Holt-Winters exponential smoothing model over a 20-month out-of-sample test set (May 2024 - Dec 2025).")
    
    st.image("Prevision Arima et HW.png", caption="Forecasts vs Actuals: SARIMA (Top) and Holt-Winters (Bottom)")
    
    st.subheader("Performance Metrics")
    st.markdown("The SARIMA model structurally outperforms Holt-Winters, capturing the error inertia effectively and yielding a lower MAPE.")
    st.image("resume ARIMA et HW.PNG", caption="Out-of-sample Error Metrics & Residual Validation")