import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IncomePage extends StatefulWidget {
  final String email;

  const IncomePage({super.key, required this.email});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage>
    with SingleTickerProviderStateMixin {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  List incomes = [];

  final String baseUrl = "https://finanza-app.onrender.com";

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

    getIncomes();
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
                        Colors.greenAccent.withValues(alpha: 0.12),
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
                          color: Colors.greenAccent.withValues(
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
  // AGREGAR INGRESO
  // =========================
  Future<void> addIncome() async {
    final amount = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (amount.isEmpty || description.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_income"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_email": widget.email,
          "amount": amount,
          "description": description,
          "frequency": "Unico",
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        amountController.clear();
        descriptionController.clear();
        getIncomes();
        print("Ingreso agregado 🔥");
      } else {
        print("Error addIncome: ${response.body}");
      }
    } catch (e) {
      print("Error addIncome: $e");
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
      print("Error deleteIncome: $e");
    }
  }

  // =========================
  // FORMATEAR FECHA
  // =========================
  String formatDate(String date) {
    try {
      DateTime parsed = DateTime.parse(date);
      return "${parsed.day}/${parsed.month}/${parsed.year} "
          "${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    backgroundController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Ingresos", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                  const SizedBox(height: 20),
                  glowButtonWrapper(
                    color: Colors.cyanAccent,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addIncome,
                        style: glowButtonStyle(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          glowColor: Colors.cyanAccent,
                        ),
                        child: const Text("Agregar ingreso"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                                  color: const Color(
                                    0xFF1C1C2E,
                                  ).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.greenAccent.withValues(
                                      alpha: 0.28,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 26,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.cyanAccent.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 36,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.greenAccent
                                                      .withValues(alpha: 0.65),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            formatDate(
                                              income["created_at"] ?? "",
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.redAccent.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          deleteIncome(income["id"]);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
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
          ),
        ],
      ),
    );
  }

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.cyanAccent.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 18,
      shadowColor: glowColor.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
    );
  }
}
