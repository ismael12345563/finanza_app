from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2

# 🔐 BCRYPT
from passlib.context import CryptContext

# 🌐 CORS
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# 🔐 Config bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 🌐 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # desarrollo
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# 🔌 CONEXIÓN A POSTGRES (DOCKER)
# =========================
def get_connection():
    return psycopg2.connect(
        host="db",
        database="astrofi_db",
        user="astrofi",
        password="1234"
    )

# =========================
# 🔐 FUNCIONES DE SEGURIDAD
# =========================
def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)

# =========================
# MODELO USUARIO
# =========================
class User(BaseModel):
    email: str
    password: str
    accountType: str
    works: bool
    income: str
    incomeFrequency: str
    hasDebt: bool
    debtAmount: str
    debtPayment: str
    debtFrequency: str

# =========================
# REGISTRO (CON HASH 🔥)
# =========================
@app.post("/register")
def register(user: User):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        hashed_password = hash_password(user.password.strip())

        cursor.execute("""
            INSERT INTO users (
                email,
                password,
                account_type,
                works,
                income,
                income_frequency,
                has_debt,
                debt_amount,
                debt_payment,
                debt_frequency
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            user.email.strip(),
            hashed_password,  # 🔥 AQUÍ YA VA HASH
            user.accountType,
            user.works,
            user.income.strip(),
            user.incomeFrequency,
            user.hasDebt,
            user.debtAmount.strip(),
            user.debtPayment.strip(),
            user.debtFrequency
        ))

        conn.commit()
        cursor.close()
        conn.close()

        return {"mensaje": "Usuario registrado correctamente 🔥"}

    except Exception as e:
        return {"error": str(e)}

# =========================
# LOGIN SEGURO 🔐
# =========================
@app.post("/login")
def login(data: dict):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT password FROM users WHERE email = %s
        """, (data["email"].strip(),))

        result = cursor.fetchone()

        cursor.close()
        conn.close()

        if result:
            hashed_password = result[0]

            if verify_password(data["password"].strip(), hashed_password):
                return {"mensaje": "Login exitoso 🔥"}
            else:
                raise HTTPException(status_code=401, detail="Credenciales incorrectas")
        else:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")

    except Exception as e:
        return {"error": str(e)}

# =========================
# VER USUARIOS (DEBUG)
# =========================
@app.get("/usuarios")
def obtener_usuarios():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users")
    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    return rows

# =========================
# ROOT
# =========================
@app.get("/")
def read_root():
    return {"mensaje": "Backend funcionando correctamente 🚀"}