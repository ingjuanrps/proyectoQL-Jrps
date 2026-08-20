# Primera auditoría / conteo.
SELECT COUNT(*) AS total_registros,
    SUM(is_fraud) AS total_fraudes,
    ROUND(AVG(is_fraud) * 100, 4) AS porcentaje_fraude
FROM `project-ql-jrps-60324.paysim_dw.ml_features_prepared`
WHERE transaction_type IN ('TRANSFER', 'CASH_OUT');