# 🛡️ Financial Fraud Detection Platform (End-to-End GCP & Machine Learning)

Sistema integral de ingeniería de datos y aprendizaje automático para la detección, clasificación y prevención de fraudes financieros en transacciones electrónicas.

---

## 📐 Arquitectura de la Solución

1. **Ingesta y Almacenamiento:** Google Cloud Storage (GCS) y Google BigQuery (Data Warehouse).
2. **Feature Engineering & SQL Modeling:** Modelado dimensional, manejo de desbalanceo y creación de variables sintéticas (`error_balance_orig`).
3. **Machine Learning:** Modelo XGBoost Classifier optimizado para alto _Recall_ (identificación del 99.7% de fraudes).
4. **Visualización Ejecutiva:** Dashboard interactivo en Looker Studio conectado a vistas optimizadas de BigQuery.

---

## 📊 Métricas Clave del Modelo (XGBoost)

- **Recall (Fraude):** 99.7% (Se detectaron 1,638 de 1,643 casos de fraude).
- **Falsos Positivos:** Solo 98 transacciones legítimas marcadas preventivamente sobre un total de +550,000 operaciones.
- **Variable Principal (Gain):** `error_balance_orig` representó más del 70% de la importancia de decisión del modelo.

---

## 🖥️ Dashboard Ejecutivo (Looker Studio)

El tablero monitorea métricas operativas y financieras en tiempo real:

- **Filtros dinámicos:** Por canal (`TRANSFER`, `CASH_OUT`) y estado de operación.
- **Métricas clave (KPIs):** Volumen total ($317.5B+ USD) y saldo total preservado en riesgo.

![alt text](image.png)

---

## 🛠️ Tecnologías Utilizadas

- **Lenguajes:** Python (Pandas, Scikit-learn, XGBoost, Matplotlib), SQL (BigQuery Dialect).
- **Cloud Platform:** Google Cloud Platform (BigQuery, GCS).
- **Herramientas:** VS Code, Git/GitHub, Looker Studio.
