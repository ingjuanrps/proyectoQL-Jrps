-- 4. Inferencia sobre datos nuevos
SELECT predicted_is_fraud,
    predicted_is_fraud_probs,
    amount,
    transaction_type,
    error_balance_orig
FROM ML.PREDICT(
        MODEL `paysim_dw.bqml_fraud_xgboost_model`,
        (
            SELECT *
            FROM `paysim_dw.ml_features_prepared`
            LIMIT 100
        )
    );