import pandas as pd

# ==============================
# CARGAR DATASET
# ==============================
df = pd.read_csv("synthetic_personal_finance_dataset.csv")

# ==============================
# INFO GENERAL
# ==============================
print("\n--- INFO GENERAL ---")
print(df.info())

print("\n--- PRIMERAS FILAS ---")
print(df.head())

# ==============================
# VALORES NULOS
# ==============================
print("\n--- VALORES NULOS ---")
print(df.isnull().sum())

# ==============================
# TOTAL DE REGISTROS
# ==============================
print("\n--- TOTAL DE REGISTROS ---")
print(len(df))

# ==============================
# PROCESAMIENTO DE FECHA
# ==============================
if 'Date' in df.columns:
    df['Date'] = pd.to_datetime(df['Date'])

    print("\n--- RANGO DE FECHAS ---")
    print("Inicio:", df['Date'].min())
    print("Fin:", df['Date'].max())

    print("\n--- DÍAS ÚNICOS ---")
    print(df['Date'].nunique())

    frecuencia = df.groupby('Date').size()
    print("\n--- PROMEDIO REGISTROS POR DÍA ---")
    print(frecuencia.mean())

# ==============================
# ESTADÍSTICAS
# ==============================
if 'Amount' in df.columns:
    print("\n--- ESTADÍSTICAS DE AMOUNT ---")
    print(df['Amount'].describe())

# ==============================
# TIPOS DE TRANSACCIÓN
# ==============================
if 'Type' in df.columns:
    print("\n--- TIPOS DE TRANSACCIÓN ---")
    print(df['Type'].value_counts())

# ==============================
# CATEGORÍAS
# ==============================
if 'Category' in df.columns:
    print("\n--- CATEGORÍAS ---")
    print(df['Category'].value_counts().head())

# ==============================
# LIMPIEZA BÁSICA (opcional)
# ==============================
# Eliminar columna si existe
if 'Transaction Description' in df.columns:
    df = df.drop(columns=['Transaction Description'])
    print("\nColumna 'Transaction Description' eliminada")

# ==============================
# DATASET LIMPIO (CHEQUEO FINAL)
# ==============================
print("\n--- DATASET LIMPIO INFO ---")
print(df.info())