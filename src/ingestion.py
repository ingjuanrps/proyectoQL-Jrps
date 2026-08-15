from google.api_core.retry import Retry
import os  # OS- Permite interactuar con el sistema operativo
import time  # time - Ayuda a medir el rendimiento y tiempo exacto de ejecucion del proceso en segudos
import pandas as pd  # Pandas - Herramienta para manipular estructura de datos
import numpy as np  # Numpy - Operaciones numéricas usadas internamente por Pandas
# Storage - SDK de GCP que da acceso a interactuar con buckets y objetos en GCS con código Python.
from google.cloud import storage

# --- CONFIGURACIÓN ---
RAW_DATA_PATH = "data/raw/paysim.csv"  # Ruta local del CVS de KAGGLE
# Ruta local donde se guardara la versión Parquet
PROCESSED_DATA_PATH = "data/processed/paysim.parquet"
GCS_BUCKET_NAME = "jrps-proyecto-ql-2"  # Bucket del proyecto.
# Ruta del contenedor en GCS, donde se guardara el Bucket.
# Si se ejecuta de nuevo este archivo esta ruta sobre escribe el archivo
GCS_BLOB_NAME = "raw/paysim.parquet"

# Función que recibe un DataFrame y Devuelve otro DataFrame


def inspect_and_clean_data(df: pd.DataFrame) -> pd.DataFrame:
    """Realiza tipado de datos estricto para optimizar memoria antes de convertir a Parquet."""
    print("--- 1. Optimizando tipos de datos ---")

    # Mapeo de tipos de datos eficientes
    type_mappings = {
        "step": "int32",
        "type": "category",
        "amount": "float64",
        "nameOrig": "string",
        "oldbalanceOrg": "float64",
        "newbalanceOrig": "float64",
        "nameDest": "string",
        "oldbalanceDest": "float64",
        "newbalanceDest": "float64",
        "isFraud": "int8",
        "isFlaggedFraud": "int8",
    }

    # Aplica el nuevo mapa de tipos de datos a todo el DF
    df = df.astype(type_mappings)
    print(f"Filas procesadas: {len(df):,}")
    print(
        f"Uso de memoria optimizado: {df.memory_usage().sum() / (1024**2):.2f} MB"
    )  # df.memory_usage....... calcula los bytes utilizados en memoria por el DF y los convierte en MB dividiendolos entre 1024
    return df


def convert_csv_to_parquet(csv_path: str, parquet_path: str):
    """Convierte archivo CSV a formato Parquet comprimido con Snappy."""
    print(f"\n--- 2. Convirtiendo {csv_path} -> {parquet_path} ---")
    start_time = time.time()  # inicia la medición del tiempo guardando el instante inicial

    # Lectura del archivo csv
    df = pd.read_csv(csv_path)

    # Optimización
    df = inspect_and_clean_data(df)

    # Exportar a Parquet
    # crea la carpeta processed si aun no existe
    os.makedirs(os.path.dirname(parquet_path), exist_ok=True)
    # Exporta los 6 millones de filas a Parquet  utilizando el motor de procesamiento PyArrow y el algoritmo de comprensión Snappy
    df.to_parquet(parquet_path, engine="pyarrow", compression="snappy")

    # Resta el tiempo fianl y el inicial para dar el total de segundos transcurridos y meide el peso del archivo Parquet
    duration = time.time() - start_time
    size_mb = os.path.getsize(parquet_path) / (1024**2)
    print(
        f"✅ Conversión completada en {duration:.2f} segundos. Tamaño Parquet: {size_mb:.2f} MB"
    )


"""def upload_to_gcs(bucket_name: str, source_file_path: str, destination_blob_name: str):
    # Sube el archivo Parquet procesado a Google Cloud Storage.
    print(
        f"\n--- 3. Subiendo {source_file_path} a gs://{bucket_name}/{destination_blob_name} ---")
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_filename(source_file_path)
    print("✅ Carga a Google Cloud Storage finalizada exitosamente.")"""

"""def upload_to_gcs(bucket_name: str, source_file_path: str, destination_blob_name: str):
    #Sube el archivo Parquet procesado a Google Cloud Storage aumentando el timeout.
    print(f"\n--- 3. Subiendo {source_file_path} a gs://{bucket_name}/{destination_blob_name} ---")
    
    # 1. Ajustar el timeout del cliente global a 600 segundos (10 minutos)
    storage_client = storage.Client()
    
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    # 2. Configurar el tamaño de chunk (bloque) para transferencias grandes
    blob.chunk_size = 5 * 1024 * 1024  # 5 MB por bloque

    # 3. Asignar timeout explícito de 600s a la subida
    blob.upload_from_filename(source_file_path, timeout=600)
    
    print("✅ Carga a Google Cloud Storage finalizada exitosamente.")"""


def upload_to_gcs(bucket_name: str, source_file_path: str, destination_blob_name: str):
    """Sube el archivo Parquet a GCS con manejo de reintentos para errores de red/SSL."""
    print(
        f"\n--- 3. Subiendo {source_file_path} a gs://{bucket_name}/{destination_blob_name} ---")

    # Inicializar cliente
    storage_client = storage.Client()  # inicializa las credenciales de GCP
    # Crea la referencia hacia el bucket
    bucket = storage_client.bucket(bucket_name)
    # Define la ruta del archivo destino dentro del bucket
    blob = bucket.blob(destination_blob_name)

    # Definir política de reintentos para soportar caídas o fluctuaciones SSL
    custom_retry = Retry(
        initial=1.0,
        maximum=60.0,
        multiplier=2.0,
        deadline=900.0  # 15 minutos en total
    )

    # Asignar un chunk size óptimo (8 MB) que no meature las conexiones SSL locales
    blob.chunk_size = 8 * 1024 * 1024  # 8 MB

    # Subir con reintentos y timeout extendido
    blob.upload_from_filename(
        source_file_path,
        timeout=900,
        retry=custom_retry
    )

    print("✅ Carga a Google Cloud Storage finalizada exitosamente.")


"""Este IF garantiza que este código solo se ejecute cuando el script se ejecute directamente
    y no si se importa como módulo desde otro archivo """
if __name__ == "__main__":
    if not os.path.exists(RAW_DATA_PATH):  # Revisa que el CSV exista
        raise FileNotFoundError(
            f"No se encontró el archivo en {RAW_DATA_PATH}")

    convert_csv_to_parquet(RAW_DATA_PATH, PROCESSED_DATA_PATH)
    upload_to_gcs(GCS_BUCKET_NAME, PROCESSED_DATA_PATH, GCS_BLOB_NAME)
