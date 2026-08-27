# 🛡️ Financial Fraud Detection Platform (End-to-End GCP & Machine Learning).

Sistema integral de ingeniería de datos, análisis forense estadístico y aprendizaje automático para la detección, clasificación y prevención de fraudes financieros en transacciones electrónicas masivas sobre **Google Cloud Platform (GCP)**.

---

## 📐 Arquitectura y Flujo Técnico.

1. **Ingesta y Almacenamiento:** Carga de datos crudos (`data/raw/`) hacia Google Cloud Storage (GCS) y estructuración en Google BigQuery como Data Warehouse.
2. **Calidad de Datos & Reglas GIGO:** Filtrado de inconsistencias operativas (`amount > 0`) y limpieza transaccional.
3. **Análisis Estadístico de Anomalías:** Validación mediante la **Ley de Benford** implementada en SQL y Python para detectar manipulaciones en los primeros dígitos.
4. **Feature Engineering & Modelado SQL:** Creación de variables sintéticas de discrepancia (`error_balance_orig`, `error_balance_dest`) y modelado dimensional (Staging $\rightarrow$ Data Marts).
5. **Machine Learning Distribuido:** Entrenamiento de modelos clasificadores (**XGBoost Classifier** local y **BigQuery ML / Vertex AI**), optimizados para la detección de clases desbalanceadas.
6. **Visualización Ejecutiva:** Dashboards interactivos en Looker Studio conectados a vistas optimizadas de BigQuery para monitoreo de riesgo financiero.

---

## 📊 Métricas Clave del Modelo (XGBoost).

- **Recall (Fraude):** **99.7%** (Identificación de 1,638 de 1,643 casos de fraude).
- **Precision (Fraude):** **91.0%** (Alta certeza en alertas operativas).
- **Falsos Positivos:** Solo 98 transacciones legítimas marcadas preventivamente sobre un total de +550,000 operaciones.
- **Variable de Mayor Impacto (Gain):** `error_balance_orig` representa más del 70% del peso en las decisiones del modelo.

---

## 📸 Fotográfias y Flujo por Componentes.

### 1. Ingesta de Datos y Scripts de Automatización (`src/`).

Pipeline desarrollado en Python dentro de VS Code para ingestar datos crudos hacia BigQuery y ejecutar las primeras pruebas de calidad.

- **Script de Ingesta (`src/ingestion.py`):**

  ![Pipeline de Ingesta en Python](assets/01_src_ingestion.png)

---

### 2. Transformaciones SQL y BigQuery ML (`sql/`).

Procesamiento analítico en BigQuery SQL estructurado por scripts ordenados:

- **Staging y Modelo Dimensional (`01_staging_tables.sql`, `02_dimensional_model.sql`):**

  ![Creación de Tablas Staging](assets/03_sql_staging_dimensional.png)

  ![Vista de la Tabla Staging](assets/04_sql_staging_dimensional.png)

  ![Creación de Tabla dim_transaction y dim_customers](assets/05_sql_staging_dimensional.png)

  ![Vista de Tabla dim_transaction](assets/06_sql_staging_dimensional.png)

  ![Vista de Tabla dim_customers](assets/07_sql_staging_dimensional0.png)

- **Análisis de Ley de Benford (`03_benford_analysis.sql`, `04_view_analisis_Benford.sql`):**

  ![Consulta SQL de Ley de Benford](assets/08_sql_benford_view.png)

  ![Vista de la vista Ley de Benford](assets/09_sql_benford_view.png)

- **Reglas GIGO e Ingeniería de Características (`05_data_quality_gigo.sql` a `08_audit_fraud_distribution.sql`):**

  ![Validaciones GIGO y Feature Engineering de Balances VISTA balance_errors_summary](assets/10_sql_gigo_feature_engineering.png)

  ![Vista de vista balance_errors_summary](assets/11_sql_gigo_feature_engineering.png)

  ![Creación de la Tabla ml_features_prepared](assets/12_sql_gigo_feature_engineering.png)

  ![Vista de la Tabla ml_features_prepared](assets/13_sql_gigo_feature_engineering.png)

  ![Auditoría / Conteo ml_features_prepared](assets/14_sql_gigo_feature_engineering.png)

  ![Creación de la Tabla ml_dataset_split](assets/15_sql_gigo_feature_engineering.png)

  ![Creación de la vista vw_looker_fraud_dashboard](assets/16_sql_gigo_feature_engineering.png)

  ![Vista de la vista vw_looker_fraud_dashboard](assets/17_sql_gigo_feature_engineering.png)

- **Entrenamiento y Evaluación en Vertex AI / BigQuery ML (`11_bigquery_ml_fraud_model.sql` a `14_bigquery_ml_inferencia_datos_nuevos.sql`):**
  Modelo XGBoost (`BOOSTED_TREE_CLASSIFIER`) entrenado y evaluado nativamente en BigQuery:

  ![Entrenamiento y Evaluación en BigQuery ML](assets/18_entrenando_evaluando.png)

  ![Metricas del entrenamiento y evaluación en BigQuery ML, SQL](assets/23_entrenando_evaluando.png)

  ![Metricas del entrenamiento y evaluación en BigQuery ML Graficos](assets/19_entrenando_evaluando.png)

  ![Metricas del entrenamiento y evaluación en BigQuery ML Tabla](assets/20_entrenando_evaluando.png)

  ![Evalución del entrenamiento y evaluación en BigQuery ML](assets/21_entrenando_evaluando.png)

  ![Evalución del entrenamiento y evaluación en BigQuery ML, Matriz de Confucsión SQL](assets/24_entrenando_evaluando.png)

  ![Evalución del entrenamiento y evaluación en BigQuery ML, Matriz de Confucsión](assets/22_entrenando_evaluando.png)

---

### 3. Exploración en Jupyter Notebooks (`notebook/`).

Pruebas estadísticas de Benford y entrenamiento del clasificador XGBoost serializado en formato JSON (`xgb_fraud_model.json`).

- **Entrenamiento Local del Modelo (`01_model_training.ipynb`):**

  ![Jupyter Notebook - Matriz de Confusión.](assets/25_notebook_model_training.png)

  ![Jupyter Notebook - Interpretación de la Matriz de Confunsión.](assets/26_notebook_model_training.png)

---

### 4. 💻 Vertex AI / BigQuery ML.

- **Vertex AI / BigQuery ML:** Modelo XGBoost (`BOOSTED_TREE_CLASSIFIER`) entrenado y evaluado nativamente dentro de BigQuery con SQL.

![BigQuery](assets/entrenando_evaluando.png)

---

### 5. 🖥️ Dashboard Ejecutivo en Looker Studio (`10_dashboard_Looker_Studio.sql`).

El tablero monitorea métricas operativas y financieras en tiempo real:

- **Filtros dinámicos:** Por canal (`TRANSFER`, `CASH_OUT`) y estado de operación.
- **Métricas clave (KPIs):** Volumen total ($317.5B+ USD) y saldo total preservado en riesgo.

![Dashboard Ejecutivo Looker Studio](assets/dashboard.png)

---

## 🛠️ Tecnologías Utilizadas.

- **Lenguajes:** Python (Pandas, Scikit-Learn, XGBoost, Matplotlib, Seaborn), SQL (BigQuery Dialect).
- **Cloud Infrastructure (GCP):** Google Cloud Storage (GCS), BigQuery, BigQuery ML / Vertex AI.
- **Herramientas de Desarrollo & BI:** Visual Studio Code, Jupyter Notebooks, Git / GitHub, Looker Studio.

---

## 📁 Estructura del Repositorio (`proyectoQL_Jrps`).

```text
proyectoQL_Jrps/
├── .vscode/                 # Configuración del entorno en VS Code
├── assets/                  # Capturas de pantalla y evidencia (.png)
├── data/
│   ├── processed/           # Datos procesados
│   └── raw/                 # Datos crudos (PaySim)
├── notebook/
│   ├── 01_eda_and_benford.ipynb
│   ├── 01_model_training.ipynb
│   └── xgb_fraud_model.json # Modelo XGBoost exportado
├── sql/                     # Scripts de SQL en BigQuery
│   ├── 01_staging_tables.sql
│   ├── 02_dimensional_model.sql
│   ├── 03_benford_analysis.sql
│   ├── 04_bqml_models.sql
│   ├── 04_view_analisis_Benford.sql
│   ├── 05_data_quality_gigo.sql
│   ├── 06_view_balance_errors_summary.sql
│   ├── 07_feature_enginnering.sql
│   ├── 08_audit_fraud_distribution.sql
│   ├── 09_create_ml_dateset_split.sql
│   ├── 10_dashboard_Looker_Studio.sql
│   ├── 11_bigquery_ml_fraud_model.sql
│   ├── 12_bigquery_ml_evaluar_metricas.sql
│   ├── 13_bigquery_ml_matriz_confusion.sql
│   └── 14_bigquery_ml_inferencia_datos_nuevos.sql
├── src/
│   ├── ingestion.py         # Pipeline de ingesta a GCP
│   └── quality_checks.py    # Reglas de validación
├── venv/                    # Entorno virtual de Python (Ignorado en Git)
├── .env                     # Variables de entorno locales
├── .env.example             # Plantilla de configuración
├── .gitignore
├── README.md
└── requirements.txt
```

![Estructura Repositorio VSC](assets/estructuraVSC.png)
