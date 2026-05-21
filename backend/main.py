from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware
import os


from dotenv import load_dotenv
load_dotenv()

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
        cursor_factory=RealDictCursor,
        sslmode="require"
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

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

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
            raise HTTPException(
                status_code=404,
                detail="Usuario no existe"
            )

        if verify_password(data.password, row["password"]):
            return {"mensaje": "Login ok"}

        raise HTTPException(
            status_code=401,
            detail="Password incorrecta"
        )

    finally:

        if cur:
            cur.close()

        if conn:
            conn.close()

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
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado"
        )

    return {
        "email": row["email"],
        "has_credit_card": row["has_credit_card"] or False
    }

@app.get("/get_card/{email}")
def get_card(email: str):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT *
        FROM credit_cards
        WHERE user_email=%s
    """, (email,))

    card = cur.fetchone()

    cur.close()
    conn.close()

    if not card:
        return None

    return card


@app.post("/create_card")
def create_card(data: dict):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO credit_cards (
            user_email,
            credit_limit,
            balance,
            closing_day,
            payment_day,
            late_months
        )
        VALUES (%s,%s,%s,%s,%s,%s)
    """, (
        data["email"],
        data["credit_limit"],
        data["balance"],
        data["closing_day"],
        data["payment_day"],
        data.get("late_months", 0)
    ))

    conn.commit()
    cur.close()
    conn.close()

    return {"mensaje": "Tarjeta creada"}

# =========================
# UPDATE CARD
# =========================
@app.put("/update_card")
def update_card(data: dict):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        UPDATE credit_cards
        SET
            credit_limit=%s,
            balance=%s,
            closing_day=%s,
            payment_day=%s,
            late_months=%s
        WHERE user_email=%s
    """, (
        data["credit_limit"],
        data["balance"],
        data["closing_day"],
        data["payment_day"],
        data.get("late_months", 0),
        data["email"]
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Tarjeta actualizada"}


@app.post("/card_transaction")
def card_transaction(data: dict):

    conn = get_connection()
    cur = conn.cursor()

    # guardar gasto
    cur.execute("""
        INSERT INTO card_transactions (
            user_email,
            amount,
            description
        )
        VALUES (%s,%s,%s)
    """, (
        data["email"],
        data["amount"],
        data.get("description", "Compra")
    ))

    # actualizar deuda
    cur.execute("""
        UPDATE credit_cards
        SET balance = balance + %s
        WHERE user_email = %s
    """, (
        data["amount"],
        data["email"]
    ))

    conn.commit()
    cur.close()
    conn.close()

    return {"mensaje": "Compra registrada"}

# =========================
# GET CARD TRANSACTIONS
# =========================
@app.get("/get_card_transactions/{email}")
def get_card_transactions(email: str):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT *
        FROM card_transactions
        WHERE user_email=%s
        ORDER BY id DESC
    """, (email,))

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return rows


# =========================
# PAY CARD
# =========================
@app.post("/pay_card")
def pay_card(data: dict):

    conn = get_connection()
    cur = conn.cursor()

    payment = float(data["amount"])

    cur.execute("""
        SELECT balance
        FROM credit_cards
        WHERE user_email=%s
    """, (data["email"],))

    card = cur.fetchone()

    if not card:

        cur.close()
        conn.close()

        raise HTTPException(
            status_code=404,
            detail="Tarjeta no encontrada"
        )

    current_balance = float(card["balance"] or 0)

    new_balance = current_balance - payment

    if new_balance < 0:
        new_balance = 0

    cur.execute("""
        UPDATE credit_cards
        SET balance=%s
        WHERE user_email=%s
    """, (
        new_balance,
        data["email"]
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {
        "mensaje": "Pago realizado",
        "nuevo_balance": new_balance
    }

# =========================
# GET INCOMES
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

    return rows

# =========================
# ADD INCOME
# =========================
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
# GET DEBTS
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

    return rows

# =========================
# ADD DEBT
# =========================
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
# PAY DEBT
# =========================
@app.put("/pay_debt/{debt_id}")
def pay_debt(debt_id: int, data: DebtPayment):

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

    total_amount = float(debt["amount"] or 0)
    remaining = float(debt["remaining_amount"] or total_amount)
    paid = float(debt["paid_amount"] or 0)

    payment = float(data.payment_amount)

    if payment <= 0:
        raise HTTPException(
            status_code=400,
            detail="Abono inválido"
        )

    new_remaining = remaining - payment

    if new_remaining < 0:
        new_remaining = 0

    new_paid = paid + payment

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
# MODELO EXPENSE
# =========================
class Expense(BaseModel):
    user_email: str
    amount: str
    description: str
    category: str


# =========================
# GET EXPENSES
# =========================
@app.get("/get_expenses/{email}")
def get_expenses(email: str):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            amount,
            description,
            category,
            created_at
        FROM expenses
        WHERE user_email=%s
        ORDER BY id DESC
    """, (email,))

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return rows


# =========================
# ADD EXPENSE
# =========================
@app.post("/add_expense")
def add_expense(data: Expense):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO expenses (
            user_email,
            amount,
            description,
            category
        )
        VALUES (%s,%s,%s,%s)
    """, (
        data.user_email,
        data.amount,
        data.description,
        data.category
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Gasto agregado"}


# =========================
# DELETE EXPENSE
# =========================
@app.delete("/delete_expense/{expense_id}")
def delete_expense(expense_id: int):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "DELETE FROM expenses WHERE id=%s",
        (expense_id,)
    )

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Gasto eliminado"}

# =========================
# UPDATE PROFILE
# =========================
@app.post("/update_profile")
def update_profile(data: dict):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        UPDATE users
        SET works=%s
        WHERE email=%s
    """, (
        data["works"],
        data["email"]
    ))

    conn.commit()

    cur.close()
    conn.close()

    return {"mensaje": "Perfil actualizado"}
# =========================
# ROOT
# =========================
@app.get("/")
def root():
    return {"mensaje": "AstroFi API OK 🚀"}

# =========================
# IA MODEL
# =========================
import joblib
import pandas as pd

model = joblib.load("modelo.pkl")


class PredictRequest(BaseModel):
    email: str

@app.post("/predict")
def predict(data: PredictRequest):

    conn = get_connection()
    cur = conn.cursor()

    # =========================
    # USER
    # =========================
    cur.execute(
        "SELECT * FROM users WHERE email=%s",
        (data.email,)
    )

    user = cur.fetchone()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado"
        )

    # =========================
    # INGRESOS
    # =========================
    cur.execute("""
        SELECT COALESCE(SUM(CAST(amount AS NUMERIC)), 0)
        FROM incomes
        WHERE user_email=%s
    """, (data.email,))

    income_db = float(cur.fetchone()["coalesce"] or 0)

    # =========================
    # GASTOS
    # =========================
    cur.execute("""
        SELECT COALESCE(SUM(CAST(amount AS NUMERIC)), 0)
        FROM expenses
        WHERE user_email=%s
    """, (data.email,))

    expenses = float(cur.fetchone()["coalesce"] or 0)

    # =========================
    # DEUDA
    # =========================
    cur.execute("""
        SELECT COALESCE(SUM(CAST(remaining_amount AS NUMERIC)), 0)
        FROM debts
        WHERE user_email=%s
    """, (data.email,))

    debt = float(cur.fetchone()["coalesce"] or 0)

    # =========================
    # TARJETA DE CRÉDITO
    # =========================
    cur.execute("""
        SELECT credit_limit, balance, late_months
        FROM credit_cards
        WHERE user_email=%s
    """, (data.email,))

    card = cur.fetchone()

    card_limit = 0
    card_balance = 0
    late_months = 0
    credit_usage = 0

    if card:
        card_limit = float(card["credit_limit"] or 0)
        card_balance = float(card["balance"] or 0)
        late_months = int(card["late_months"] or 0)

        if card_limit > 0:
            credit_usage = card_balance / card_limit

    cur.close()
    conn.close()

    # =========================
    # INGRESO FINAL
    # =========================
    income = income_db if income_db > 0 else float(user["income"] or 0)

    # =========================
    # RATIOS
    # =========================
    expense_ratio = expenses / (income + 1)
    debt_ratio = debt / (income + 1)
    card_ratio = credit_usage

    # =========================
    # SCORE
    # =========================
    score = 100

    # gastos
    if expense_ratio > 1:
        score -= 40
    elif expense_ratio > 0.8:
        score -= 25
    elif expense_ratio > 0.6:
        score -= 10

    # deuda
    if debt_ratio > 0.5:
        score -= 30
    elif debt_ratio > 0.3:
        score -= 15

    # tarjeta
    if card_ratio > 0.9:
        score -= 30
    elif card_ratio > 0.7:
        score -= 20
    elif card_ratio > 0.5:
        score -= 10

    # atrasos
    if late_months >= 6:
        score -= 35
    elif late_months >= 3:
        score -= 20
    elif late_months >= 1:
        score -= 10

    # sin ingresos
    if income <= 0:
        score -= 20

    score = max(0, min(100, score))

    # =========================
    # ESTADO
    # =========================
    if score >= 75:
        status = "good"
        message = "🟢 Finanzas saludables. Buen control de ingresos y gastos."

    elif score >= 45:
        status = "warning"
        message = "🟡 Precaución financiera. Ajusta gastos o reduce deudas."

    else:
        status = "danger"
        message = "🔴 Alto riesgo financiero. Tu nivel de deuda o gasto es elevado."

    # =========================
    # ALERTA EXTRA
    # =========================
    if card_ratio > 0.7:
        extra = "⚠️ Alto uso de tarjeta de crédito"

    elif debt_ratio > 0.5:
        extra = "⚠️ Deuda alta respecto a ingresos"

    elif expense_ratio > 0.8:
        extra = "⚠️ Gastos elevados"

    else:
        extra = "📊 Sin alertas críticas"

    # =========================
    # RESPONSE
    # =========================
    return {
        "status": status,
        "message": message,
        "score": score,
        "income": income,
        "expenses": expenses,
        "debt": debt,
        "card_usage": round(credit_usage * 100, 2),
        "late_months": late_months,
        "extra": extra
    }