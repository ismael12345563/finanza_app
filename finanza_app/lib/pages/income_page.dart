import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IncomePage extends StatefulWidget {
  final String email;

  const IncomePage({super.key, required this.email});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  List incomes = [];

  // 🔥 URL DEL BACKEND
  final String baseUrl = "https://finanza-app.onrender.com";

  @override
  void initState() {
    super.initState();
    getIncomes();
  }

  // =========================
  // AGREGAR INGRESO
  // =========================
  Future<void> addIncome() async {
    final amount = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (amount.isEmpty || description.isEmpty) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_income"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_email": widget.email,
          "amount": amount,
          "description": description,
        }),
      );

      if (response.statusCode == 200) {
        amountController.clear();
        descriptionController.clear();

        getIncomes();

        print("Ingreso agregado 🔥");
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  // =========================
  // OBTENER INGRESOS
  // =========================
  Future<void> getIncomes() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_incomes/${widget.email}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          incomes = jsonDecode(response.body);
        });
      } else {
        print(response.body);
      }
    } catch (e) {
      print("Error incomes: $e");
    }
  }

  // =========================
  // ELIMINAR INGRESO
  // =========================
  Future<void> deleteIncome(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/delete_income/$id"),
      );

      if (response.statusCode == 200) {
        getIncomes();

        print("Ingreso eliminado 🔥");
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  // =========================
  // FORMATEAR FECHA
  // =========================
  String formatDate(String date) {
    try {
      DateTime parsed = DateTime.parse(date);

      return "${parsed.day}/${parsed.month}/${parsed.year}  ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Ingresos", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =========================
            // MONTO
            // =========================
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                labelText: "Monto",
                labelStyle: const TextStyle(color: Colors.white70),

                filled: true,
                fillColor: const Color(0xFF1C1C2E),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // DESCRIPCION
            // =========================
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                labelText: "Descripción",
                labelStyle: const TextStyle(color: Colors.white70),

                filled: true,
                fillColor: const Color(0xFF1C1C2E),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // BOTON
            // =========================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: addIncome,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),

                child: const Text("Agregar ingreso"),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // LISTA
            // =========================
            Expanded(
              child: incomes.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay ingresos registrados",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: incomes.length,

                      itemBuilder: (context, index) {
                        final income = incomes[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C2E),
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      income["description"] ?? "",

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "\$${income["amount"]}",

                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      formatDate(income["created_at"] ?? ""),

                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  deleteIncome(income["id"]);
                                },

                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
