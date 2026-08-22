-- 1. Crear el modelo de Boosted Trees (XGBoost) en BigQuery ML
CREATE OR REPLACE MODEL `paysim_dw.bqml_fraud_xgboost_model` OPTIONS(
        model_type = 'BOOSTED_TREE_CLASSIFIER',
        input_label_cols = ['is_fraud'],
        auto_class_weights = TRUE,
        --Manejo automático de desbalanceo de clases.
        max_iterations = 20,
        data_split_method = 'AUTO_SPLIT'
    ) AS
SELECT transaction_type,
    amount,
    old_balance_orig,
    new_balance_orig,
    old_balance_dest,
    new_balance_dest,
    error_balance_orig,
    error_balance_dest,
    is_fraud
FROM `project-ql-jrps-60324.paysim_dw.ml_features_prepared`;