-- 3. Obtener la Matriz de Confusión directamente en SQL
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL `paysim_dw.bqml_fraud_xgboost_model`);