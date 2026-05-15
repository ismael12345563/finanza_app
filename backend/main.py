from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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
        host="localhost",
        database="astrofi_db",
        user="postgres",
        password="1234"
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
    debt_id: int
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
                email,
                password,
                account_type,
                works,
                income,
                income_frequency,
                has_debt,
                debt_amount,
                debt_payment,
                debt_frequency,
                has_credit_card
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

        if user.hasDebt:
            amount = float(user.debtAmount or "0")

            if amount > 0:
                cur.execute("""
                    INSERT INTO debts (
                        user_email,
                        amount,
                        description,
                        frequency,
                        remaining_amount,
                        paid_amount
                    )
                    VALUES (%s,%s,%s,%s,%s,%s)
                """, (
                    user.email.strip(),
                    amount,
                    "Deuda inicial",
                    user.debtFrequency,
                    amount,
                    0
                ))

        conn.commit()
        return {"mensaje": "Usuario creado"}

    except HTTPException as e:
        raise e

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
# LOGIN
# =========================
@app.post("/login")
def login(data: LoginRequest):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "SELECT password FROM users WHERE email=%s",
        (data.email.strip(),)
    )

    row = cur.fetchone()

    cur.close()
    conn.close()

    if not row:
        raise HTTPException(status_code=404, detail="Usuario no existe")

    if verify_password(data.password, row[0]):
        return {"mensaje": "Login ok"}

    raise HTTPException(status_code=401, detail="Password incorrecta")

# =========================
# GET USER
# =========================
@app.get("/get_user/{email}")
def get_user(email: str):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT email, has_credit_card
        FROM users
        WHERE email=%s
    """, (email,))

    row = cur.fetchone()

    cur.close()
    conn.close()

    if not row:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return {
        "email": row[0],
        "has_credit_card": row[1] or False
    }

# =========================
# INCOMES
# =========================
@app.get("/get_incomes/{email}")
def get_incomes(email: str):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT id, amount, description, frequency, created_at
        FROM incomes
        WHERE user_email=%s
        ORDER BY id DESC
    """, (email,))

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return [
        {
            "id": r[0],
            "amount": float(r[1] or 0),
            "description": r[2] or "",
            "frequency": r[3] or "",
            "created_at": str(r[4])
        }
        for r in rows
    ]


@app.post("/add_income")
def add_income(data: Income):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO incomes (
            user_email,
            amount,
            description,
            frequency
        )
        VALUES (%s,%s,%s,%s)
    """, (
        data.user_email,
        data.amount,
        data.description,
        data.frequency
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Ingreso agregado"}

# =========================
# DELETE INCOME
# =========================
@app.delete("/delete_income/{income_id}")
def delete_income(income_id: int):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "DELETE FROM incomes WHERE id=%s",
        (income_id,)
    )

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Ingreso eliminado"}

# =========================
# DEBTS
# =========================
@app.get("/get_debts/{email}")
def get_debts(email: str):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            amount,
            description,
            frequency,
            created_at,
            remaining_amount,
            paid_amount
        FROM debts
        WHERE user_email=%s
        ORDER BY id DESC
    """, (email,))

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return [
        {
            "id": r[0],
            "amount": float(r[1] or 0),
            "description": r[2] or "",
            "frequency": r[3] or "",
            "created_at": str(r[4]),
            "remaining_amount": float(r[5] or r[1] or 0),
            "paid_amount": float(r[6] or 0),
        }
        for r in rows
    ]


@app.post("/add_debt")
def add_debt(data: Debt):

    conn = get_connection()
    cur = conn.cursor()

    amount = float(data.amount)

    cur.execute("""
        INSERT INTO debts (
            user_email,
            amount,
            description,
            frequency,
            remaining_amount,
            paid_amount
        )
        VALUES (%s,%s,%s,%s,%s,%s)
    """, (
        data.user_email,
        amount,
        data.description,
        data.frequency,
        amount,
        0
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Deuda agregada"}



# =========================
# ABONAR DEUDA
# =========================
@app.put("/pay_debt/{debt_id}")
def pay_debt(debt_id: int, data: dict):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT amount, remaining_amount, paid_amount
        FROM debts
        WHERE id=%s
    """, (debt_id,))

    debt = cur.fetchone()

    if not debt:
        cur.close()
        conn.close()

        raise HTTPException(
            status_code=404,
            detail="Deuda no encontrada"
        )

    total_amount = float(debt[0] or 0)
    remaining = float(debt[1] or total_amount)
    paid = float(debt[2] or 0)

    payment = float(data["payment_amount"])

    if payment <= 0:
        raise HTTPException(
            status_code=400,
            detail="Abono inválido"
        )

    new_remaining = remaining - payment

    if new_remaining < 0:
        new_remaining = 0

    new_paid = paid + payment

    # Si ya pagó toda la deuda
    if new_remaining <= 0:

        cur.execute(
            "DELETE FROM debts WHERE id=%s",
            (debt_id,)
        )

        conn.commit()

        cur.close()
        conn.close()

        return {
            "mensaje": "Deuda pagada completamente"
        }

    # Actualizar deuda
    cur.execute("""
        UPDATE debts
        SET remaining_amount=%s,
            paid_amount=%s
        WHERE id=%s
    """, (
        new_remaining,
        new_paid,
        debt_id
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {
        "mensaje": "Abono realizado",
        "remaining_amount": new_remaining,
        "paid_amount": new_paid
    }
# =========================
# DELETE DEBT
# =========================
@app.delete("/delete_debt/{debt_id}")
def delete_debt(debt_id: int):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "DELETE FROM debts WHERE id=%s",
        (debt_id,)
    )

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Deuda eliminada"}

# =========================
# ROOT
# =========================
@app.get("/")
def root():
    return {"mensaje": "AstroFi OK 🚀"}