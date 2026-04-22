import pandas as pd

# ==============================
# CARGAR DATASET (EXCEL)
# ==============================
df = pd.read_excel("bank.xlsx")

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
# TIPOS DE DATOS
# ==============================
print("\n--- TIPOS DE DATOS ---")
print(df.dtypes)

# ==============================
# ESTADÍSTICAS (numéricas)
# ==============================
print("\n--- ESTADÍSTICAS ---")
print(df.describe())

# ==============================
# COLUMNAS
# ==============================
print("\n--- COLUMNAS ---")
print(df.columns)
# ==============================
# LIMPIEZA
# ==============================

# eliminar columnas inútiles
df = df.drop(columns=['.', 'CHQ.NO.'])

# rellenar montos
df['WITHDRAWAL AMT'] = df['WITHDRAWAL AMT'].fillna(0)
df['DEPOSIT AMT'] = df['DEPOSIT AMT'].fillna(0)

# crear columna neta (MUY IMPORTANTE)
df['amount'] = df['DEPOSIT AMT'] - df['WITHDRAWAL AMT']

print("\n--- DATA LIMPIA ---")
print(df.head())