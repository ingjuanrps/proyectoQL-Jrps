#Transformar datos almacenados y modelados en BigQuery para Looker Studio
CREATE OR REPLACE VIEW `paysim_dw.vw_looker_fraud_dashboard` AS
SELECT transaction_type,
    amount,
    old_balance_orig,
    new_balance_orig,
    old_balance_dest,
    new_balance_dest,
    error_balance_orig,
    error_balance_dest,
    is_fraud,
    -- Clasificación legible para el tablero.
    IF(
        is_fraud = 1,
        'Fraude Confirmado',
        'Operación Legitima'
    ) AS estado_transaccion,
    -- Estimación del impacto finaciero evitado/detectado.
    IF(is_fraud = 1, amount, 0) AS monto_fraude_riesgo
FROM `paysim_dw.ml_features_prepared`;