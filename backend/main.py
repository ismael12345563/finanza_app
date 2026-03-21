from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI()

class Gasto(BaseModel):
    descripcion: str
    monto: float
    categoria: str

gastos: List[Gasto] = []

@app.get("/")
def read_root():
    return {"mensaje": "Backend funcionando correctamente 🚀"}

@app.post("/gastos")
def agregar_gasto(gasto: Gasto):
    gastos.append(gasto)
    return {"mensaje": "Gasto agregado correctamente"}

@app.get("/gastos")
def obtener_gastos():
    return gastos