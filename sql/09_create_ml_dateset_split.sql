# Sentencia para tomar todos los registros filtrados de mlfeatures_prepared
# Se le asigna una etiqueta fija 'TRAIN' (80%) o 'TEST'(20%)
CREATE OR REPLACE TABLE `paysim_dw.ml_dataset_split` AS
SELECT *,
    IF (
        MOD(
            ABS(
                FARM_FINGERPRINT(
                    # Función Hashing, por si se consulta la tabla despues, 
                    # y estas transacciones seguiran perteneciendo al mismo grupo de entrenamiento
                    CAST(amount AS STRING) || CAST(old_balance_orig AS STRING)
                )
            ),
            100
        ) < 80,
        'TRAIN',
        'TEST'
    ) AS dataset_split
FROM `paysim_dw.ml_features_prepared`
WHERE transaction_type IN ('TRANSFER', 'CASH_OUT');