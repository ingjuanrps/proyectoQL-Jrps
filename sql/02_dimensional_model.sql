-- Creación de tablas de dimensión a partir de fact_transactions
-- 1. Dimensión de Tipos de Transacción
CREATE OR REPLACE TABLE `paysim_dw.dim_transaction_type` AS
SELECT DISTINCT ROW_NUMBER() OVER(
        ORDER BY transaction_type
    ) AS type_id,
    transaction_type
FROM `paysim_dw.fact_transactions`;
-- 2. Dimensión de Clientes (Origen y Destino combinados)
CREATE OR REPLACE TABLE `paysim_dw.dim_customers` AS WITH all_customers AS (
        SELECT origin_customer_id AS customer_id
        FROM `paysim_dw.fact_transactions`
        UNION
        DISTINCT
        SELECT dest_customer_id AS customer_id
        FROM `paysim_dw.fact_transactions`
    )
SELECT customer_id,
    CASE
        WHEN customer_id LIKE 'C%' THEN 'Customer'
        WHEN customer_id LIKE 'M%' THEN 'Merchant'
        ELSE 'Unknown'
    END AS customer_type
FROM all_customers;
--bq query --use_legacy_sql=false < sql/02_dimensional_model.sql