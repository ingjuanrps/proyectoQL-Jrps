-- 2. Evaluar métricas generales (ROC AUC, Precision, Recall, F1-Score)
SELECT *
FROM ML.EVALUATE(MODEL `paysim_dw.bqml_fraud_xgboost_model`);