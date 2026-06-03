import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpensesPage extends StatefulWidget {
  final String email;

  const ExpensesPage({super.key, required this.email});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with SingleTickerProviderStateMixin {
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

  late AnimationController backgroundController;
  late Animation<double> backgroundAnimation;

  @override
  void initState() {
    super.initState();

    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    backgroundAnimation = CurvedAnimation(
      parent: backgroundController,
      curve: Curves.easeInOut,
    );

    getExpenses();
  }

  @override
  void dispose() {
    backgroundController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: backgroundAnimation,
      builder: (context, child) {
        final value = backgroundAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF020611),
                Color.lerp(
                  const Color(0xFF081328),
                  const Color(0xFF190A2E),
                  value,
                )!,
                const Color(0xFF050510),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -0.7 + (value * 0.5),
                        -0.9 + (value * 0.25),
                      ),
                      radius: 1.05,
                      colors: [
                        Colors.cyanAccent.withValues(alpha: 0.16),
                        Colors.blueAccent.withValues(alpha: 0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.75 - (value * 0.35),
                        -0.15 + (value * 0.25),
                      ),
                      radius: 1.2,
                      colors: [
                        Colors.redAccent.withValues(alpha: 0.12),
                        Colors.deepPurple.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              ...List.generate(65, (index) {
                final x = ((index * 37) % 100) / 50 - 1;
                final y = ((index * 61) % 100) / 50 - 1;
                final drift = ((index % 5) - 2) * 0.012 * value;
                final size = 1.2 + (index % 4) * 0.55;
                final opacity = 0.16 + ((index % 6) * 0.07);

                return Align(
                  alignment: Alignment(x + drift, y - drift),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: opacity),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(
                            alpha: opacity * 0.55,
                          ),
                          blurRadius: 6 + (index % 5).toDouble(),
                          spreadRadius: 0.4,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
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
        }); // 🔥 ESTO ES CLAVE
      }
    } catch (e) {
      debugPrint("Error expenses: $e");
    }
  }

  // =========================
  // AGREGAR GASTO
  // =========================
  Future<void> addExpense() async {
    final amountText = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (amountText.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa monto y descripción")),
      );
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingresa un monto válido")));
      return;
    }

    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_expense"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_email": widget.email,
          "amount": amountText,
          "description": description,
          "category": selectedCategory,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        amountController.clear();
        descriptionController.clear();

        await getExpenses();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gasto agregado")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      debugPrint("Error add expense: $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Gastos", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1C1C2E), Color(0xFF2A2A40)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.purpleAccent.withValues(
                                    alpha: 0.10,
                                  ),
                                  blurRadius: 42,
                                  spreadRadius: 4,
                                ),
                              ],
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
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.65,
                                        ),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
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
                              color: const Color(
                                0xFF1C1C2E,
                              ).withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyanAccent.withValues(
                                  alpha: 0.28,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 22,
                                  spreadRadius: 1,
                                ),
                              ],
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
                          glowButtonWrapper(
                            color: Colors.cyanAccent,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : addExpense,
                                style: glowButtonStyle(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  glowColor: Colors.cyanAccent,
                                ),
                                child: Text(
                                  loading ? "Guardando..." : "Agregar gasto",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
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
                                color: const Color(
                                  0xFF1C1C2E,
                                ).withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.28,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 26,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: Colors.purpleAccent.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withValues(
                                            alpha: 0.18,
                                          ),
                                          blurRadius: 16,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense["description"]?.toString() ??
                                              "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${expense["category"] ?? ""} • ${formatDate(expense["created_at"]?.toString() ?? "")}",
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
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          shadows: [
                                            Shadow(
                                              color: Colors.redAccent
                                                  .withValues(alpha: 0.55),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            deleteExpense(expense["id"]),
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
                          }),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.cyanAccent.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    );
  }

  static Widget glowButtonWrapper({
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.48),
            blurRadius: 26,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 44,
            spreadRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }

  static ButtonStyle glowButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color glowColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(vertical: 18),
      elevation: 18,
      shadowColor: glowColor.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
    );
  }
}
