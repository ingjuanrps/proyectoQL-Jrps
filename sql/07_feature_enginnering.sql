-- ----------------------------------------------------------------------------
-- Crear la Tabla Matriz de Variables para Machine Learning
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `paysim_dw.ml_features_prepared` PARTITION BY RANGE_BUCKET(step_id, GENERATE_ARRAY(1, 744, 24)) CLUSTER BY transaction_type,
    is_fraud AS WITH base_features AS (
        SELECT step_id,
            transaction_type,
            amount,
            origin_customer_id,
            dest_customer_id,
            old_balance_orig,
            new_balance_orig,
            old_balance_dest,
            new_balance_dest,
            -- Feature Engineering 1: Errores absolutos en saldos
            ROUND(
                ABS((old_balance_orig - amount) - new_balance_orig),
                2
            ) AS error_balance_orig,
            ROUND(
                ABS((old_balance_dest + amount) - new_balance_dest),
                2
            ) AS error_balance_dest,
            -- Feature Engineering 2: Indicadores binarios de saldo cero pre/post
            IF(
                old_balance_orig = 0
                AND amount > 0,
                1,
                0
            ) AS is_zero_old_balance_orig,
            IF(
                new_balance_orig = 0
                AND amount > 0,
                1,
                0
            ) AS is_zero_new_balance_orig,
            IF(
                old_balance_dest = 0
                AND amount > 0,
                1,
                0
            ) AS is_zero_old_balance_dest,
            -- Target
            is_fraud
        FROM `paysim_dw.fact_transactions`
    )
SELECT *
FROM base_features;
-- bq query --use_legacy_sql=false < sql/07_feature_enginnering.sql