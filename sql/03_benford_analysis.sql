-- ============================================================================
-- ARCHIVO: 03_benford_analysis.sql
-- DESCRIPCIÓN: Evaluación de Ley de Benford sobre montos de transacciones
-- ============================================================================
CREATE OR REPLACE VIEW `paysim_dw.vw_benford_analysis` AS WITH extracted_digits AS (
        -- CTE 1: Extraer el primer dígito significativo del monto (> 0)
        SELECT transaction_type,
            is_fraud,
            CAST(SUBSTR(CAST(amount AS STRING), 1, 1) AS INT64) AS first_digit
        FROM `paysim_dw.fact_transactions`
        WHERE amount >= 1.0
    ),
    digit_counts AS (
        -- CTE 2: Contar ocurrencias por primer dígito y tipo de transacción
        SELECT transaction_type,
            first_digit,
            COUNT(*) AS observed_count,
            -- Window Function para obtener el total de transacciones por grupo
            SUM(COUNT(*)) OVER(PARTITION BY transaction_type) AS total_group_transactions
        FROM extracted_digits
        WHERE first_digit BETWEEN 1 AND 9
        GROUP BY transaction_type,
            first_digit
    ) -- Selección Final: Comparar % Observado vs % Teórico de Benford
SELECT transaction_type,
    first_digit,
    observed_count,
    total_group_transactions,
    ROUND(
        (observed_count / total_group_transactions) * 100,
        2
    ) AS observed_pct,
    -- Formula teórica de Benford: log10(1 + 1/d) * 100
    ROUND(LOG10(1 + 1 / first_digit) * 100, 2) AS benford_theoretical_pct,
    -- Desviación absoluta respecto a Benford
    ROUND(
        ABS(
            (observed_count / total_group_transactions) * 100 - (LOG10(1 + 1 / first_digit) * 100)
        ),
        2
    ) AS abs_deviation_pct
FROM digit_counts
ORDER BY transaction_type,
    first_digit;
-- bq query --use_legacy_sql=false < sql/03_benford_analysis.sql