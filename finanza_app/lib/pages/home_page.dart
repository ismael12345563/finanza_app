import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List incomes = [];
  List debts = [];
  List expenses = [];

  Map<String, double> categoryTotals = {};

  double totalIncome = 0;
  double totalDebt = 0;

  bool hasCreditCard = false;

  // =========================
  // IA
  // =========================
  List<String> aiTips = [];
  double predictedExpense = 0;
  bool loadingAI = true;
  List<String> aiAlerts = [];
  String riskLevel = "low";

  // 🔥 URL DEL BACKEND
  final String baseUrl = "https://finanza-app.onrender.com";

  late AnimationController backgroundController;
  late AnimationController fadeController;
  late Animation<double> backgroundAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    backgroundAnimation = CurvedAnimation(
      parent: backgroundController,
      curve: Curves.easeInOut,
    );

    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    );

    fadeController.forward();

    getIncomes();
    getDebts();
    getExpenses();
    getUserProfile();
    getPrediction();
  }

  @override
  void dispose() {
    backgroundController.dispose();
    fadeController.dispose();
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
                        Colors.cyanAccent.withValues(alpha: 0.20),
                        Colors.blueAccent.withValues(alpha: 0.08),
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
                        Colors.purpleAccent.withValues(alpha: 0.18),
                        Colors.deepPurple.withValues(alpha: 0.10),
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
                        -0.15 + (value * 0.25),
                        0.85 - (value * 0.2),
                      ),
                      radius: 1.1,
                      colors: [
                        Colors.indigoAccent.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              ...List.generate(70, (index) {
                final x = ((index * 37) % 100) / 50 - 1;
                final y = ((index * 61) % 100) / 50 - 1;
                final drift = ((index % 5) - 2) * 0.012 * value;
                final size = 1.2 + (index % 4) * 0.55;
                final opacity = 0.18 + ((index % 6) * 0.08);

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
                          color: Colors.cyanAccent.withValues(
                            alpha: opacity * 0.7,
                          ),
                          blurRadius: 6 + (index % 5).toDouble(),
                          spreadRadius: 0.4,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.035),
                        Colors.transparent,
                        Colors.cyanAccent.withValues(alpha: 0.025),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void buildCategoryData() {
    categoryTotals.clear();

    for (var expense in expenses) {
      final category = expense["category"] ?? "Otros";
      final amount = double.tryParse(expense["amount"].toString()) ?? 0;

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }
    if (!mounted) return;

    setState(() {});
  }

  String formatDate(String date) {
    try {
      DateTime parsed = DateTime.parse(date);

      return "${parsed.day}/${parsed.month}/${parsed.year} • ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  Future<void> getUserProfile() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_user/${widget.email}"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return;

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

  Future<void> getExpenses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_expenses/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        setState(() {
          expenses = data;
        });

        buildCategoryData();
      }
    } catch (e) {
      debugPrint("Error expenses: $e");
    }
  }

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

  Future<void> getDebts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_debts/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double total = 0;
        for (var debt in data) {
          total += safeDouble(debt["remaining_amount"]);
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
          predictedExpense = double.tryParse(data["expenses"].toString()) ?? 0;

          final message = data["message"]?.toString().trim() ?? "";

          final extra = data["extra"]?.toString().trim() ?? "";

          aiTips = message.isNotEmpty
              ? [message]
              : ["Sin insights disponibles"];

          aiAlerts = extra.isNotEmpty ? [extra] : ["Sin alertas importantes"];

          riskLevel = data["status"]?.toString() ?? "good";

          loadingAI = false;
        });
      }
    } catch (e) {
      debugPrint("Error IA: $e");

      if (!mounted) return;

      setState(() {
        loadingAI = false;
      });
    }
  }

  void goTo(String route) async {
    await Navigator.pushNamed(context, route, arguments: widget.email);

    getIncomes();
    getDebts();
    getExpenses();
    getUserProfile();
    getPrediction();
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome;

    final safeIncome = totalIncome.isNaN ? 0.0 : totalIncome;
    final safeDebt = totalDebt.isNaN ? 0.0 : totalDebt;
    final safeBalance = balance.isNaN ? 0.0 : balance;
    final username = widget.email.split("@").first;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "ASTROFINE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              getIncomes();
              getDebts();
              getExpenses();
              getUserProfile();
              getPrediction();
            },
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),
          FadeTransition(
            opacity: fadeAnimation,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Bienvenido, ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: username,
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: " 🚀",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Resumen financiero",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF11112A,
                          ).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.55),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.30),
                              blurRadius: 34,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.purpleAccent.withValues(
                                alpha: 0.14,
                              ),
                              blurRadius: 48,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "BALANCE TOTAL",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "\$${safeBalance.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.cyanAccent.withValues(
                                      alpha: 0.75,
                                    ),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                infoBox(
                                  "Ingresos",
                                  "\$${safeIncome.toStringAsFixed(2)}",
                                  Icons.trending_down,
                                  Colors.greenAccent,
                                ),
                                infoBox(
                                  "Deudas",
                                  "\$${safeDebt.toStringAsFixed(2)}",
                                  Icons.trending_up,
                                  Colors.redAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF11112A,
                          ).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.22),
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
                              "Gastos por categoría",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 220,
                              child: categoryTotals.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "Sin datos de gastos",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    )
                                  : PieChart(
                                      PieChartData(
                                        sections: categoryTotals.entries.map((
                                          entry,
                                        ) {
                                          return PieChartSectionData(
                                            value: entry.value,
                                            title: entry.key,
                                            radius: 60,
                                            color:
                                                Colors.primaries[entry
                                                        .key
                                                        .hashCode
                                                        .abs() %
                                                    Colors.primaries.length],
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (hasCreditCard)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF11112A,
                            ).withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purpleAccent.withValues(
                                alpha: 0.65,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(
                                  alpha: 0.10,
                                ),
                                blurRadius: 42,
                                spreadRadius: 4,
                              ),
                            ],
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF11112A,
                          ).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.50),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.28),
                              blurRadius: 34,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.purpleAccent.withValues(
                                alpha: 0.12,
                              ),
                              blurRadius: 48,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.cyanAccent,
                                ),
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
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "\$${predictedExpense.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.cyanAccent.withValues(
                                        alpha: 0.55,
                                      ),
                                      blurRadius: 16,
                                    ),
                                  ],
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
                                    color: Colors.greenAccent.withValues(
                                      alpha: 0.11,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.greenAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "🚨 Alertas Inteligentes",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...aiAlerts.map(
                                (alert) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.17,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.60,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.16,
                                        ),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          alert,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
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
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => goTo('/income'),
                              child: actionButton(
                                "Ingresos",
                                Icons.attach_money,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => goTo('/debts'),
                              child: actionButton("Deudas", Icons.money_off),
                            ),
                          ),
                          if (hasCreditCard) const SizedBox(width: 15),
                          if (hasCreditCard)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/card',
                                    arguments: widget.email,
                                  );
                                },
                                child: actionButton(
                                  "Tarjeta",
                                  Icons.credit_card,
                                ),
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
                              child: actionButton(
                                "Gastos",
                                Icons.shopping_cart,
                              ),
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
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.42),
            blurRadius: 26,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 42,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: color.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.8), blurRadius: 12),
              ],
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
        color: const Color(0xFF11112A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.28),
            blurRadius: 26,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.14),
            blurRadius: 38,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 30),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.55),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
