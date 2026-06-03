import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardPage extends StatefulWidget {
  final String email;

  const CardPage({super.key, required this.email});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage>
    with SingleTickerProviderStateMixin {
  final String baseUrl = "https://finanza-app.onrender.com";

  Map card = {};
  bool loading = true;

  final TextEditingController limitController = TextEditingController();
  final TextEditingController debtController = TextEditingController();
  final TextEditingController closingDayController = TextEditingController();
  final TextEditingController paymentDayController = TextEditingController();
  final TextEditingController lateMonthsController = TextEditingController();

  String selectedPaymentFrequency = "Mensual";
  final List<String> paymentFrequencies = ["Semanal", "Quincenal", "Mensual"];

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descController = TextEditingController();

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

    getCard();
  }

  @override
  void dispose() {
    backgroundController.dispose();
    limitController.dispose();
    debtController.dispose();
    closingDayController.dispose();
    paymentDayController.dispose();
    lateMonthsController.dispose();
    amountController.dispose();
    descController.dispose();
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
  // OBTENER TARJETA
  // =========================
  Future<void> getCard() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_card/${widget.email}"),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty && res.body != "null") {
        if (!mounted) return;

        setState(() {
          card = jsonDecode(res.body);
          loading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // =========================
  // CREAR TARJETA
  // =========================
  Future<void> createCard() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/create_card"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "credit_limit": double.tryParse(limitController.text) ?? 0,
          "balance": double.tryParse(debtController.text) ?? 0,
          "closing_day": closingDayController.text,
          "payment_day": paymentDayController.text,
          "payment_frequency": selectedPaymentFrequency,
          "late_months": int.tryParse(lateMonthsController.text) ?? 0,
        }),
      );

      limitController.clear();
      debtController.clear();
      closingDayController.clear();
      paymentDayController.clear();
      lateMonthsController.clear();
      selectedPaymentFrequency = "Mensual";

      getCard();
    } catch (e) {
      debugPrint("Error create card: $e");
    }
  }

  // =========================
  // EDITAR TARJETA
  // =========================
  Future<void> editCard() async {
    try {
      await http.put(
        Uri.parse("$baseUrl/update_card"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "credit_limit": double.tryParse(limitController.text) ?? 0,
          "balance": double.tryParse(debtController.text) ?? 0,
          "closing_day": closingDayController.text,
          "payment_day": paymentDayController.text,
          "payment_frequency": selectedPaymentFrequency,
          "late_months": int.tryParse(lateMonthsController.text) ?? 0,
        }),
      );

      if (!mounted) return;

      Navigator.pop(context);

      getCard();
    } catch (e) {
      debugPrint("Error edit card: $e");
    }
  }

  // =========================
  // AGREGAR GASTO
  // =========================
  Future<void> addTransaction() async {
    await http.post(
      Uri.parse("$baseUrl/card_transaction"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "amount": double.tryParse(amountController.text) ?? 0,
        "description": descController.text,
      }),
    );

    amountController.clear();
    descController.clear();

    getCard();
  }

  Future<void> deleteCard() async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/delete_card/${widget.email}"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          card = {};
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Tarjeta eliminada")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      debugPrint("Error delete card: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  int? intFromCard(String key) {
    return int.tryParse(card[key]?.toString() ?? "");
  }

  int daysUntilPayment() {
    final paymentDay = intFromCard("payment_day");

    if (paymentDay == null || paymentDay < 1 || paymentDay > 31) {
      return -1;
    }

    final now = DateTime.now();
    var dueDate = safeDate(now.year, now.month, paymentDay);

    if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      dueDate = safeDate(nextMonth.year, nextMonth.month, paymentDay);
    }

    return dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  DateTime safeDate(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, lastDay));
  }

  String paymentAlertText() {
    final days = daysUntilPayment();

    if (days < 0) {
      return "Configura tu fecha límite de pago para recibir alertas.";
    }

    if (days == 0) {
      return "Tu pago vence hoy.";
    }

    if (days <= 3) {
      return "Tu pago vence en $days días.";
    }

    return "Faltan $days días para tu próximo pago.";
  }

  @override
  Widget build(BuildContext context) {
    double limit =
        double.tryParse(card["credit_limit"]?.toString() ?? "0") ?? 0;
    double balance = double.tryParse(card["balance"]?.toString() ?? "0") ?? 0;
    double available = limit - balance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          "Tarjeta de Crédito",
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),
          loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: card.isEmpty
                      ? buildCreateCardView()
                      : buildCardView(limit, balance, available),
                ),
        ],
      ),
    );
  }

  Widget buildCreateCardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          glowPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Configurar tarjeta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                labeledField(
                  label: "Límite de crédito",
                  tooltip: "Es el máximo dinero que el banco te presta.",
                  controller: limitController,
                  hint: "Ejemplo: 15000",
                ),
                labeledField(
                  label: "Saldo usado",
                  tooltip: "Dinero que ya utilizaste de tu tarjeta.",
                  controller: debtController,
                  hint: "Ejemplo: 3500",
                ),
                labeledField(
                  label: "Fecha de corte",
                  tooltip: "Día que el banco cierra tu periodo.",
                  controller: closingDayController,
                  hint: "Ejemplo: 20",
                ),
                labeledField(
                  label: "Fecha límite de pago",
                  tooltip: "Último día para pagar.",
                  controller: paymentDayController,
                  hint: "Ejemplo: 5",
                ),
                frequencyDropdown(),
                const SizedBox(height: 20),
                labeledField(
                  label: "Meses de atraso",
                  tooltip: "Cantidad de meses atrasado en pagos.",
                  controller: lateMonthsController,
                  hint: "Ejemplo: 2",
                  bottomSpacing: 30,
                ),
                glowButtonWrapper(
                  color: Colors.cyanAccent,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: createCard,
                      style: glowButtonStyle(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        glowColor: Colors.cyanAccent,
                      ),
                      child: const Text("Guardar tarjeta"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardView(double limit, double balance, double available) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          glowPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Resumen de tarjeta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                cardInfoRow(
                  title: "Límite de crédito",
                  value: "\$${limit.toStringAsFixed(2)}",
                  description:
                      "Monto máximo que el banco te presta en la tarjeta.",
                  color: Colors.cyanAccent,
                ),
                cardInfoRow(
                  title: "Saldo usado",
                  value: "\$${balance.toStringAsFixed(2)}",
                  description: "Dinero que ya gastaste y todavía debes pagar.",
                  color: Colors.orangeAccent,
                ),
                cardInfoRow(
                  title: "Disponible",
                  value: "\$${available.toStringAsFixed(2)}",
                  description:
                      "Crédito que aún puedes usar sin pasar tu límite.",
                  color: available < 0 ? Colors.redAccent : Colors.greenAccent,
                ),
                cardInfoRow(
                  title: "Fecha de corte",
                  value: "Día ${card["closing_day"] ?? "-"}",
                  description: "Día en que cierra tu periodo de compras.",
                  color: Colors.white,
                ),
                cardInfoRow(
                  title: "Fecha límite de pago",
                  value: "Día ${card["payment_day"] ?? "-"}",
                  description: "Último día recomendado para pagar sin atraso.",
                  color: Colors.cyanAccent,
                ),
                cardInfoRow(
                  title: "Frecuencia de pago",
                  value: card["payment_frequency"]?.toString() ?? "Mensual",
                  description:
                      "Cada cuánto planeas revisar o pagar esta tarjeta.",
                  color: Colors.purpleAccent,
                ),
                cardInfoRow(
                  title: "Meses de atraso",
                  value: "${card["late_months"] ?? 0}",
                  description:
                      "Meses acumulados en los que no se pagó a tiempo.",
                  color: Colors.redAccent,
                  bottomSpacing: 0,
                ),
                const SizedBox(height: 18),
                alertPanel(
                  icon: Icons.notifications_active,
                  text: paymentAlertText(),
                  color: daysUntilPayment() >= 0 && daysUntilPayment() <= 3
                      ? Colors.orangeAccent
                      : Colors.cyanAccent,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: glowButtonWrapper(
                        color: Colors.purpleAccent,
                        child: ElevatedButton.icon(
                          onPressed: showEditDialog,
                          icon: const Icon(Icons.edit),
                          label: const Text("Editar"),
                          style: glowButtonStyle(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            glowColor: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: glowButtonWrapper(
                        color: Colors.redAccent,
                        child: ElevatedButton.icon(
                          onPressed: showDeleteDialog,
                          icon: const Icon(Icons.delete),
                          label: const Text("Eliminar"),
                          style: glowButtonStyle(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            glowColor: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text("Nuevo gasto", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration("Monto"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration("Descripción"),
          ),
          const SizedBox(height: 20),
          glowButtonWrapper(
            color: Colors.cyanAccent,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addTransaction,
                style: glowButtonStyle(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  glowColor: Colors.cyanAccent,
                ),
                child: const Text("Guardar gasto"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEditDialog() {
    limitController.text = card["credit_limit"].toString();
    debtController.text = card["balance"].toString();
    closingDayController.text = card["closing_day"].toString();
    paymentDayController.text = card["payment_day"].toString();
    selectedPaymentFrequency =
        card["payment_frequency"]?.toString() ?? "Mensual";
    lateMonthsController.text = card["late_months"].toString();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.cyanAccent.withValues(alpha: 0.35),
                ),
              ),
              title: const Text(
                "Editar tarjeta",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Límite"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: debtController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Saldo usado"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: closingDayController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Fecha corte"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: paymentDayController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Fecha pago"),
                    ),
                    const SizedBox(height: 15),
                    frequencyDropdown(dialogSetState: setDialogState),
                    const SizedBox(height: 15),
                    TextField(
                      controller: lateMonthsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Meses atraso"),
                    ),
                  ],
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
                  onPressed: editCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    elevation: 12,
                    shadowColor: Colors.cyanAccent.withValues(alpha: 0.6),
                  ),
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.35)),
          ),
          title: const Text(
            "Eliminar tarjeta",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Se eliminará la tarjeta y sus movimientos registrados. Puedes crear otra después.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deleteCard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  Widget cardInfoRow({
    required String title,
    required String value,
    required String description,
    required Color color,
    double bottomSpacing = 14,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget alertPanel({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget frequencyDropdown({StateSetter? dialogSetState}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.28)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPaymentFrequency,
          dropdownColor: const Color(0xFF1C1C2E),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items: paymentFrequencies.map((frequency) {
            return DropdownMenuItem(value: frequency, child: Text(frequency));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            void updateFrequency() {
              selectedPaymentFrequency = value;
            }

            if (dialogSetState != null) {
              dialogSetState(updateFrequency);
            } else {
              setState(updateFrequency);
            }
          },
        ),
      ),
    );
  }

  Widget labeledField({
    required String label,
    required String tooltip,
    required TextEditingController controller,
    required String hint,
    double bottomSpacing = 20,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            Tooltip(
              message: tooltip,
              child: const Icon(
                Icons.help_outline,
                color: Colors.cyanAccent,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: inputDecoration(hint),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }

  Widget glowPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.22),
            blurRadius: 30,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.10),
            blurRadius: 42,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.cyanAccent.withValues(alpha: 0.28),
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
}
