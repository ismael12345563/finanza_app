import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List incomes = [];
  List debts = [];

  double totalIncome = 0;
  double totalDebt = 0;

  bool hasCreditCard = false;

  // =========================
  // IA
  // =========================
  List<String> aiTips = [];
  double predictedExpense = 0;
  bool loadingAI = true;

  // 🔥 URL DEL BACKEND
  final String baseUrl = "https://finanza-app.onrender.com";

  @override
  void initState() {
    super.initState();
    getIncomes();
    getDebts();
    getUserProfile();
    getPrediction();
  }

  // =========================
  // FORMATEAR FECHA
  // =========================
  String formatDate(String date) {
    try {
      DateTime parsed = DateTime.parse(date);

      return "${parsed.day}/${parsed.month}/${parsed.year} • ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  // =========================
  // USUARIO
  // =========================
  Future<void> getUserProfile() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_user/${widget.email}"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          hasCreditCard = data["has_credit_card"] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error profile: $e");
    }
  }

  double safeDouble(dynamic value) {
    final parsed = double.tryParse(value?.toString() ?? "0");

    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return 0.0;
    }

    return parsed;
  }

  // =========================
  // INGRESOS
  // =========================
  Future<void> getIncomes() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_incomes/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double total = 0;

        for (var income in data) {
          total += safeDouble(income["amount"]);
        }

        if (!mounted) return;

        setState(() {
          incomes = data;
          totalIncome = total;
        });
      }
    } catch (e) {
      debugPrint("Error incomes: $e");
    }
  }

  // =========================
  // DEUDAS
  // =========================
  Future<void> getDebts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_debts/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double total = 0;

        for (var debt in data) {
          total += safeDouble(debt["amount"]);
        }

        if (!mounted) return;

        setState(() {
          debts = data;
          totalDebt = total;
        });
      }
    } catch (e) {
      debugPrint("Error debts: $e");
    }
  }

  // =========================
  // IA PREDICTION
  // =========================
  Future<void> getPrediction() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          predictedExpense =
              double.tryParse(data["prediccion_gasto"].toString()) ?? 0;

          aiTips = List<String>.from(data["consejos"] ?? []);

          loadingAI = false;
        });
      }
    } catch (e) {
      debugPrint("Error IA: $e");

      setState(() {
        loadingAI = false;
      });
    }
  }

  void goTo(String route) async {
    await Navigator.pushNamed(context, route, arguments: widget.email);

    getIncomes();
    getDebts();
    getUserProfile();
    getPrediction();
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome;

    final safeIncome = totalIncome.isNaN ? 0.0 : totalIncome;
    final safeDebt = totalDebt.isNaN ? 0.0 : totalDebt;
    final safeBalance = balance.isNaN ? 0.0 : balance;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Astro Fi"),
        actions: [
          IconButton(
            onPressed: () {
              getIncomes();
              getDebts();
              getUserProfile();
              getPrediction();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                "Bienvenido ${widget.email} 🚀",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Resumen financiero",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              // =========================
              // BALANCE
              // =========================
              Container(
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
                      "Balance total",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "\$${safeBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        infoBox(
                          "Ingresos",
                          "\$${safeIncome.toStringAsFixed(2)}",
                          Icons.arrow_downward,
                          Colors.greenAccent,
                        ),

                        infoBox(
                          "Deudas",
                          "\$${safeDebt.toStringAsFixed(2)}",
                          Icons.arrow_upward,
                          Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // TARJETA DE CRÉDITO
              // =========================
              if (hasCreditCard)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A40),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "💳 Tarjeta de Crédito",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Aquí podrás ver tu gasto acumulado y pago estimado",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 25),

              // =========================
              // IA
              // =========================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C1C2E), Color(0xFF252542)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.cyanAccent),

                        SizedBox(width: 12),

                        Text(
                          "IA Financiera activa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (loadingAI)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      Text(
                        "Predicción de gasto mensual",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "\$${predictedExpense.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Insights IA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ...aiTips.map(
                        (tip) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                                size: 20,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // BOTONES
              // =========================
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => goTo('/income'),
                      child: actionButton("Ingresos", Icons.attach_money),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => goTo('/debts'),
                      child: actionButton("Deudas", Icons.money_off),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => goTo('/expenses'),
                      child: actionButton("Gastos", Icons.shopping_cart),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => goTo('/perfil'),
                      child: actionButton("Perfil", Icons.person),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // =========================
              // INGRESOS RECIENTES
              // =========================
              const Text(
                "Ingresos recientes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              if (incomes.isEmpty)
                const Text(
                  "No hay ingresos",
                  style: TextStyle(color: Colors.white70),
                ),

              ...incomes.take(5).map((income) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.greenAccent,
                        ),
                      ),

                      const SizedBox(width: 15),

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

                            const SizedBox(height: 6),

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

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          Text(
                            "+ \$${income["amount"]}",

                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "Ingreso",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
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

  static Widget infoBox(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(color: Colors.white70)),

          const SizedBox(height: 8),

          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  static Widget actionButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),

      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 30),

          const SizedBox(height: 12),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
