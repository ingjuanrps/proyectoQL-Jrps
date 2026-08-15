SELECT IF(is_fraud = 1, 'Fraude', 'Legítima') AS tipo_transaccion,
    total_transactions,
    avg_orig_error,
    avg_dest_error,
    count_orig_errors,
    orig_error_rate_pct
FROM `paysim_dw.vw_balance_errors_summary`;
-- bq query --use_legacy_sql=false < sql/06_view_balance_error_summary.sql