-- ============================================================================
-- PROYECTO: DETECCIÓN DE FRAUDE (PAYSIM)
-- ARCHIVO: 05_data_quality_gigo.sql
-- DESCRIPCIÓN: Cálculo de deltas de inconsistencia en saldos de origen y destino
-- ============================================================================
CREATE OR REPLACE VIEW `paysim_dw.vw_balance_errors_summary` AS WITH balance_deltas AS (
        SELECT step_id,
            transaction_type,
            amount,
            origin_customer_id,
            old_balance_orig,
            new_balance_orig,
            -- Diferencia esperada vs real en cuenta Origen
            (old_balance_orig - amount) AS expected_new_balance_orig,
            ROUND(
                ABS((old_balance_orig - amount) - new_balance_orig),
                2
            ) AS orig_balance_error,
            dest_customer_id,
            old_balance_dest,
            new_balance_dest,
            -- Diferencia esperada vs real en cuenta Destino
            (old_balance_dest + amount) AS expected_new_balance_dest,
            ROUND(
                ABS((old_balance_dest + amount) - new_balance_dest),
                2
            ) AS dest_balance_error,
            is_fraud
        FROM `paysim_dw.fact_transactions`
        WHERE transaction_type IN ('TRANSFER', 'CASH_OUT') -- Tipos concentradores de fraude
    ) -- Evaluación de tasa de inconsistencia en fraude vs transacciones legítimas
SELECT is_fraud,
    COUNT(*) AS total_transactions,
    ROUND(AVG(orig_balance_error), 2) AS avg_orig_error,
    ROUND(AVG(dest_balance_error), 2) AS avg_dest_error,
    COUNTIF(orig_balance_error > 0.01) AS count_orig_errors,
    ROUND(
        (COUNTIF(orig_balance_error > 0.01) / COUNT(*)) * 100,
        2
    ) AS orig_error_rate_pct
FROM balance_deltas
GROUP BY is_fraud;
-- bq query --use_legacy_sql=false < sql/05_data_quality_gigo.sql