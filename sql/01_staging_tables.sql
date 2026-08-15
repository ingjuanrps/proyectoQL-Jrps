-- 1. Crear o reemplazar la tabla Staging cargada directamente desde GCS
--CREATE OR REPLACE TABLE `paysim_dw.stg_transactions` AS
--SELECT CAST(step AS INT64) AS step_id,
--CAST(type AS STRING) AS transaction_type,
--CAST(amount AS NUMERIC) AS amount,
--CAST(nameOrig AS STRING) AS origin_customer_id,
--CAST(oldbalanceOrg AS NUMERIC) AS old_balance_orig,
--CAST(newbalanceOrig AS NUMERIC) AS new_balance_orig,
--CAST(nameDest AS STRING) AS dest_customer_id,
--CAST(oldbalanceDest AS NUMERIC) AS old_balance_dest,
--CAST(newbalanceDest AS NUMERIC) AS new_balance_dest,
--CAST(isFraud AS INT64) AS is_fraud,
--CAST(isFlaggedFraud AS INT64) AS is_flagged_fraud
--FROM EXTERNAL_QUERY_SOURCE ();
-- Crear la tabla optimizada particionada y con clustering
CREATE OR REPLACE TABLE `paysim_dw.fact_transactions` PARTITION BY RANGE_BUCKET(step_id, GENERATE_ARRAY(1, 744, 24)) -- Particionado por días (cada 24 pasos/horas)
    CLUSTER BY transaction_type,
    is_fraud AS
SELECT step AS step_id,
    type AS transaction_type,
    amount,
    nameOrig AS origin_customer_id,
    oldbalanceOrg AS old_balance_orig,
    newbalanceOrig AS new_balance_orig,
    nameDest AS dest_customer_id,
    oldbalanceDest AS old_balance_dest,
    newbalanceDest AS new_balance_dest,
    isFraud AS is_fraud,
    isFlaggedFraud AS is_flagged_fraud
FROM `paysim_dw.stg_transactions`;
--Para ejecutar este archivo
-- bq query --use_legacy_sql=false < sql/01_staging_tables.sql
-- Vereficacion de creación de tablas : bq ls paysim_dw