import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilPage extends StatefulWidget {
  final String email;

  const PerfilPage({super.key, required this.email});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>
    with SingleTickerProviderStateMixin {
  // 🔥 URL DEL BACKEND
  final String baseUrl = "https://finanza-app.onrender.com";

  String selectedStatus = "trabajando";
  bool isWorking = true;

  double totalIncome = 0;
  double totalDebt = 0;

  bool loading = false;

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

    loadFinancialData();
  }

  @override
  void dispose() {
    backgroundController.dispose();
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
            ],
          ),
        );
      },
    );
  }

  // =========================
  // CARGAR DATOS
  // =========================
  Future<void> loadFinancialData() async {
    try {
      final incomesResponse = await http.get(
        Uri.parse("$baseUrl/get_incomes/${widget.email}"),
      );

      final debtsResponse = await http.get(
        Uri.parse("$baseUrl/get_debts/${widget.email}"),
      );

      if (incomesResponse.statusCode == 200 &&
          debtsResponse.statusCode == 200) {
        final incomes = jsonDecode(incomesResponse.body);
        final debts = jsonDecode(debtsResponse.body);

        double incomeTotal = 0;
        double debtTotal = 0;

        for (var income in incomes) {
          incomeTotal += double.tryParse(income["amount"].toString()) ?? 0;
        }

        for (var debt in debts) {
          debtTotal +=
              double.tryParse(debt["remaining_amount"].toString()) ?? 0;
        }

        if (!mounted) return;

        setState(() {
          totalIncome = incomeTotal;
          totalDebt = debtTotal;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // =========================
  // NIVEL FINANCIERO
  // =========================
  String getFinancialLevel() {
    if (totalIncome <= 0) {
      return "Inicio";
    }

    if (totalDebt > totalIncome) {
      return "Precaución";
    }

    if (totalIncome >= 50000) {
      return "Avanzado";
    }

    if (totalIncome >= 15000) {
      return "Estable";
    }

    return "En crecimiento";
  }

  // =========================
  // TIPS IA
  // =========================
  String getFinancialTip() {
    if (totalDebt > totalIncome) {
      return "Tu deuda supera tus ingresos. Intenta reducir gastos innecesarios.";
    }

    if (totalIncome > 20000) {
      return "Buen trabajo 🔥 considera empezar un fondo de inversión.";
    }

    return "Mantén un control constante de tus gastos e ingresos.";
  }

  // =========================
  // GUARDAR PERFIL
  // =========================
  Future<void> saveProfile() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "works": isWorking,
          "income_status": selectedStatus,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Perfil actualizado 🔥")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (!mounted) return;

    setState(() => loading = false);
  }

  // =========================
  // FORMATEAR DINERO
  // =========================
  String money(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final balance = (totalIncome - totalDebt).isNaN
        ? 0.0
        : totalIncome - totalDebt;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Perfil", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),
          SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 55),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF23233A), Color(0xFF1C1C2E)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.45),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(
                                  alpha: 0.26,
                                ),
                                blurRadius: 34,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.purpleAccent.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 46,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.cyanAccent,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      "Usuario AstroFine",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                widget.email,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: miniCard(
                                      "Ingresos",
                                      "\$${money(totalIncome)}",
                                      Icons.attach_money,
                                      Colors.greenAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: miniCard(
                                      "Deudas",
                                      "\$${money(totalDebt)}",
                                      Icons.money_off,
                                      Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        glowContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Resumen financiero",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              infoRow("Balance actual", "\$${money(balance)}"),
                              infoRow("Nivel financiero", getFinancialLevel()),
                              infoRow("Estado laboral", selectedStatus),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        glowContainer(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.cyanAccent,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  getFinancialTip(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        glowContainer(
                          padding: const EdgeInsets.all(18),
                          borderRadius: 18,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Actualmente trabajando",
                                style: TextStyle(color: Colors.white),
                              ),
                              Switch(
                                value: isWorking,
                                activeThumbColor: Colors.cyanAccent,
                                onChanged: (value) {
                                  setState(() {
                                    isWorking = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Situación laboral",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1C1C2E,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.28),
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
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            dropdownColor: const Color(0xFF1C1C2E),
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(
                                value: "trabajando",
                                child: Text("Trabajando"),
                              ),
                              DropdownMenuItem(
                                value: "desempleado",
                                child: Text("Desempleado"),
                              ),
                              DropdownMenuItem(
                                value: "estudiante",
                                child: Text("Estudiante"),
                              ),
                              DropdownMenuItem(
                                value: "sin_ingresos",
                                child: Text("Sin ingresos"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        glowButtonWrapper(
                          color: Colors.cyanAccent,
                          child: ElevatedButton.icon(
                            onPressed: loading ? null : saveProfile,
                            icon: const Icon(Icons.save),
                            label: const Text("Guardar cambios"),
                            style: glowButtonStyle(
                              backgroundColor: Colors.cyanAccent,
                              foregroundColor: Colors.black,
                              glowColor: Colors.cyanAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        glowButtonWrapper(
                          color: Colors.purpleAccent,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/history',
                                arguments: widget.email,
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text("Historial financiero"),
                            style: glowButtonStyle(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              glowColor: Colors.purpleAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        glowButtonWrapper(
                          color: Colors.redAccent,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text("Cerrar sesión"),
                            style: glowButtonStyle(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              glowColor: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static Widget glowContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
    double borderRadius = 20,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.09),
            blurRadius: 38,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget glowButtonWrapper({
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 52,
            spreadRadius: 6,
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
      padding: const EdgeInsets.symmetric(vertical: 17),
      elevation: 18,
      shadowColor: glowColor.withValues(alpha: 0.90),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
      ),
    );
  }

  // =========================
  // MINI CARD
  // =========================
  static Widget miniCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.65), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INFO ROW
  // =========================
  static Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
