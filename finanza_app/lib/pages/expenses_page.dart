import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpensesPage extends StatefulWidget {
  final String email;

  const ExpensesPage({super.key, required this.email});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final String baseUrl = "https://finanza-app.onrender.com";

  List expenses = [];

  bool loading = false;

  String selectedCategory = "Comida";

  final List<String> categories = [
    "Comida",
    "Transporte",
    "Entretenimiento",
    "Salud",
    "Servicios",
    "Otros",
  ];

  @override
  void initState() {
    super.initState();
    getExpenses();
  }

  // =========================
  // OBTENER GASTOS
  // =========================
  Future<void> getExpenses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_expenses/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          expenses = data;
        });
      }
    } catch (e) {
      debugPrint("Error expenses: $e");
    }
  }

  // =========================
  // AGREGAR GASTO
  // =========================
  Future<void> addExpense() async {
    if (amountController.text.isEmpty || descriptionController.text.isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_expense"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_email": widget.email,
          "amount": amountController.text,
          "description": descriptionController.text,
          "category": selectedCategory,
        }),
      );

      if (response.statusCode == 200) {
        amountController.clear();
        descriptionController.clear();

        await getExpenses();
      }
    } catch (e) {
      debugPrint("Error add expense: $e");
    }

    setState(() {
      loading = false;
    });
  }

  // =========================
  // ELIMINAR GASTO
  // =========================
  Future<void> deleteExpense(int id) async {
    try {
      await http.delete(Uri.parse("$baseUrl/delete_expense/$id"));

      getExpenses();
    } catch (e) {
      debugPrint("Error delete expense: $e");
    }
  }

  // =========================
  // FECHA
  // =========================
  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return "${parsed.day}/${parsed.month}/${parsed.year}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = 0;

    for (var expense in expenses) {
      totalExpenses += double.tryParse(expense["amount"].toString()) ?? 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Gastos"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =========================
              // TOTAL
              // =========================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C1C2E), Color(0xFF2A2A40)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Total Gastado",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "\$${totalExpenses.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // FORMULARIO
              // =========================
              const Text(
                "Agregar gasto",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,

                style: const TextStyle(color: Colors.white),

                decoration: inputDecoration("Monto"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),

                decoration: inputDecoration("Descripción"),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C2E),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF1C1C2E),
                    value: selectedCategory,
                    isExpanded: true,

                    style: const TextStyle(color: Colors.white),

                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: loading ? null : addExpense,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(loading ? "Guardando..." : "Agregar gasto"),
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // LISTA
              // =========================
              const Text(
                "Gastos recientes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              if (expenses.isEmpty)
                const Text(
                  "No hay gastos",
                  style: TextStyle(color: Colors.white70),
                ),

              ...expenses.map((expense) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C2E),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.redAccent,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              expense["description"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "${expense["category"]} • ${formatDate(expense["created_at"])}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          Text(
                            "- \$${expense["amount"]}",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          IconButton(
                            onPressed: () => deleteExpense(expense["id"]),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),

      filled: true,
      fillColor: const Color(0xFF1C1C2E),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
