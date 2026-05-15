from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# =========================
# CORS
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# DB CONNECTION
# =========================
def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT", "5432"),
        cursor_factory=RealDictCursor
    )

# =========================
# MODELOS
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
    hasCreditCard: bool = False


class LoginRequest(BaseModel):
    email: str
    password: str


class Income(BaseModel):
    user_email: str
    amount: str
    description: str
    frequency: str = "Unico"


class Debt(BaseModel):
    user_email: str
    amount: str
    description: str
    frequency: str = "Mensual"


class DebtPayment(BaseModel):
    payment_amount: float

# =========================
# PASSWORD
# =========================
def hash_password(password: str):
    password = password.strip()
    if len(password) > 72:
        raise HTTPException(status_code=400, detail="Password muy larga")
    return pwd_context.hash(password)

def verify_password(plain, hashed):
    return pwd_context.verify(plain.strip(), hashed)

# =========================
# REGISTER
# =========================
@app.post("/register")
def register(user: User):

    conn = None
    cur = None

    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute(
            "SELECT email FROM users WHERE email=%s",
            (user.email.strip(),)
        )

        if cur.fetchone():
            raise HTTPException(status_code=400, detail="Usuario ya existe")

        hashed = hash_password(user.password)

        cur.execute("""
            INSERT INTO users (
                email, password, account_type, works,
                income, income_frequency,
                has_debt, debt_amount, debt_payment,
                debt_frequency, has_credit_card
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            user.email.strip(),
            hashed,
            user.accountType,
            user.works,
            user.income,
            user.incomeFrequency,
            user.hasDebt,
            user.debtAmount,
            user.debtPayment,
            user.debtFrequency,
            user.hasCreditCard
        ))

        conn.commit()
        return {"mensaje": "Usuario creado"}

    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

# =========================
# LOGIN (CORREGIDO)
# =========================
@app.post("/login")
def login(data: LoginRequest):

    conn = None
    cur = None

    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute(
            "SELECT password FROM users WHERE email=%s",
            (data.email.strip(),)
        )

        row = cur.fetchone()

        if not row:
            raise HTTPException(status_code=404, detail="Usuario no existe")

        hashed_password = row.get("password")

        if not hashed_password:
            raise HTTPException(status_code=500, detail="Error interno")

        if verify_password(data.password, hashed_password):
            return {"mensaje": "Login ok"}

        raise HTTPException(status_code=401, detail="Password incorrecta")

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

# =========================
# ROOT
# =========================
@app.get("/")
def root():
    return {"mensaje": "AstroFi API OK 🚀"}