import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DebtsPage extends StatefulWidget {
  final String email;

  const DebtsPage({super.key, required this.email});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage>
    with SingleTickerProviderStateMixin {
  List debts = [];

  final String baseUrl = "https://finanza-app.onrender.com";

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final paymentController = TextEditingController();

  String selectedFrequency = "Mensual";

  bool isDisposed = false;

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

    getDebts();
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
  // GET DEBTS
  // =========================
  Future<void> getDebts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_debts/${widget.email}"),
      );

      if (!mounted || isDisposed) return;

      if (response.statusCode == 200) {
        setState(() {
          debts = jsonDecode(response.body);
        });
      } else {
        debugPrint("Error get debts: ${response.body}");
      }
    } catch (e) {
      debugPrint("ERROR GET DEBTS: $e");
    }
  }

  // =========================
  // ADD DEBT
  // =========================
  Future<void> addDebt() async {
    if (isDisposed) return;

    final amount = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (amount.isEmpty || description.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_debt"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_email": widget.email,
          "amount": amount,
          "description": description,
          "frequency": selectedFrequency,
        }),
      );

      if (!mounted || isDisposed) return;

      if (response.statusCode == 200) {
        amountController.clear();
        descriptionController.clear();

        await getDebts();

        debugPrint("DEUDA AGREGADA 🔥");
      } else {
        debugPrint("ERROR ADD: ${response.body}");
      }
    } catch (e) {
      debugPrint("ERROR ADD DEBT: $e");
    }
  }

  // =========================
  // PAY DEBT
  // =========================
  Future<void> payDebt(int debtId) async {
    if (isDisposed) return;

    final payment = paymentController.text.trim();

    if (payment.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/pay_debt/$debtId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"payment_amount": payment}),
      );

      if (!mounted || isDisposed) return;

      if (response.statusCode == 200) {
        paymentController.clear();

        Navigator.pop(context);

        await getDebts();

        if (!mounted || isDisposed) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Abono realizado 🔥")));
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("ERROR PAY: $e");
    }
  }

  // =========================
  // DELETE DEBT
  // =========================
  Future<void> deleteDebt(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete_debt/$id"));

      if (!mounted || isDisposed) return;

      if (response.statusCode == 200) {
        await getDebts();

        debugPrint("DEUDA ELIMINADA 🔥");
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("ERROR DELETE: $e");
    }
  }

  // =========================
  // PAYMENT DIALOG
  // =========================
  void showPaymentDialog(int debtId) {
    if (isDisposed) return;

    paymentController.clear();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.35)),
          ),
          title: const Text(
            "Abonar a deuda",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: paymentController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cantidad abonada",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2A40),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.greenAccent.withValues(alpha: 0.28),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.greenAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                payDebt(debtId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                elevation: 12,
                shadowColor: Colors.greenAccent.withValues(alpha: 0.6),
              ),
              child: const Text("Abonar"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // FORMAT DATE
  // =========================
  String formatDate(String date) {
    try {
      DateTime parsed = DateTime.parse(date);

      return "${parsed.day}/${parsed.month}/${parsed.year} ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    isDisposed = true;

    backgroundController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    paymentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("Deudas", style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration("Descripción"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedFrequency,
                    dropdownColor: const Color(0xFF1C1C2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration("Frecuencia de pago"),
                    items:
                        [
                          "Diario",
                          "Semanal",
                          "Quincenal",
                          "Mensual",
                          "Anual",
                        ].map((frequency) {
                          return DropdownMenuItem(
                            value: frequency,
                            child: Text(
                              frequency,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (!mounted || isDisposed) return;

                      setState(() {
                        selectedFrequency = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  glowButtonWrapper(
                    color: Colors.redAccent,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addDebt,
                        style: glowButtonStyle(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          glowColor: Colors.redAccent,
                        ),
                        child: const Text("Agregar deuda"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: debts.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay deudas registradas",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: debts.length,
                            itemBuilder: (context, index) {
                              final debt = debts[index];

                              final remaining =
                                  double.tryParse(
                                    debt["remaining_amount"].toString(),
                                  ) ??
                                  0;

                              final paid =
                                  double.tryParse(
                                    debt["paid_amount"].toString(),
                                  ) ??
                                  0;

                              final original =
                                  double.tryParse(debt["amount"].toString()) ??
                                  0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1C1C2E,
                                  ).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.20,
                                      ),
                                      blurRadius: 28,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.purpleAccent.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 38,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            debt["description"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      "Restante",
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "\$${remaining.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.65,
                                            ),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Abonado: \$${paid.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.greenAccent
                                                .withValues(alpha: 0.45),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: original > 0 ? paid / original : 0,
                                      minHeight: 10,
                                      borderRadius: BorderRadius.circular(20),
                                      backgroundColor: Colors.white12,
                                      valueColor: const AlwaysStoppedAnimation(
                                        Colors.greenAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Pago: ${debt["frequency"] ?? "Mensual"}",
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.white54,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formatDate(debt["created_at"] ?? ""),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: glowButtonWrapper(
                                            color: Colors.greenAccent,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                showPaymentDialog(debt["id"]);
                                              },
                                              icon: const Icon(Icons.payments),
                                              label: const Text("Abonar"),
                                              style: glowButtonStyle(
                                                backgroundColor:
                                                    Colors.greenAccent,
                                                foregroundColor: Colors.black,
                                                glowColor: Colors.greenAccent,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: Colors.redAccent
                                                  .withValues(alpha: 0.35),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent
                                                    .withValues(alpha: 0.20),
                                                blurRadius: 20,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              deleteDebt(debt["id"]);
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 18,
      shadowColor: glowColor.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
    );
  }
}
