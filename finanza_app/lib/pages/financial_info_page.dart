import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinancialInfoPage extends StatefulWidget {
  final String accountType;
  final String email;
  final String password;

  const FinancialInfoPage({
    super.key,
    required this.accountType,
    required this.email,
    required this.password,
  });

  @override
  State<FinancialInfoPage> createState() => _FinancialInfoPageState();
}

class _FinancialInfoPageState extends State<FinancialInfoPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool works = false;
  bool hasDebt = false;

  final incomeController = TextEditingController();
  final debtAmountController = TextEditingController();
  final debtPaymentController = TextEditingController();

  String incomeFrequency = "Mensual";
  String debtFrequency = "Mensual";
  String cardType = "none";

  final String baseUrl = "https://finanza-app.onrender.com";

  late final AnimationController backgroundController;
  late final AnimationController fadeController;

  late final Animation<double> backgroundAnimation;
  late final Animation<double> fadeAnimation;

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
    )..forward();

    backgroundAnimation = CurvedAnimation(
      parent: backgroundController,
      curve: Curves.easeInOut,
    );

    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    backgroundController.dispose();
    fadeController.dispose();

    incomeController.dispose();
    debtAmountController.dispose();
    debtPaymentController.dispose();

    super.dispose();
  }

  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        final v = backgroundAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF132B3A),
                Color.lerp(
                  const Color(0xFF251A3A),
                  const Color(0xFF4A1454),
                  v,
                )!,
                const Color(0xFF0F0F1A),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.35 + (v * 0.7), -0.65 + (v * 0.25)),
                radius: 1.3,
                colors: [
                  Colors.cyanAccent.withOpacity(0.18),
                  Colors.purpleAccent.withOpacity(0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget yesNoButton(bool selected, String text, Function() onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.cyanAccent : const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 14,
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    final url = Uri.parse("$baseUrl/register");

    final data = {
      "email": widget.email,
      "password": widget.password,
      "accountType": widget.accountType,
      "works": works,
      "income": incomeController.text.trim(),
      "incomeFrequency": incomeFrequency,
      "hasDebt": hasDebt,
      "debtAmount": debtAmountController.text.trim(),
      "debtPayment": debtPaymentController.text.trim(),
      "debtFrequency": debtFrequency,
      "cardType": cardType,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta creada correctamente")),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purpleAccent),
        title: const Text(
          "Información financiera",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),

          FadeTransition(
            opacity: fadeAnimation,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Paso 4 de 4",
                              style: TextStyle(color: Colors.white54),
                            ),

                            const SizedBox(height: 8),

                            const LinearProgressIndicator(
                              value: 1,
                              backgroundColor: Colors.white12,
                              color: Colors.cyanAccent,
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Cuéntanos sobre tus finanzas",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ================= TRABAJO =================
                            sectionCard(
                              icon: Icons.work_outline,
                              title: "Trabajo",
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      yesNoButton(
                                        works,
                                        "SI",
                                        () => setState(() => works = true),
                                      ),
                                      const SizedBox(width: 10),
                                      yesNoButton(
                                        !works,
                                        "NO",
                                        () => setState(() => works = false),
                                      ),
                                    ],
                                  ),

                                  if (works) ...[
                                    const SizedBox(height: 20),

                                    TextField(
                                      controller: incomeController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Ingreso mensual",
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    DropdownButtonFormField<String>(
                                      value: incomeFrequency,
                                      dropdownColor: const Color(0xFF1C1C2E),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Semanal",
                                          child: Text("Semanal"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Quincenal",
                                          child: Text("Quincenal"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Mensual",
                                          child: Text("Mensual"),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => incomeFrequency = v!),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ================= TARJETAS =================
                            sectionCard(
                              icon: Icons.credit_card,
                              title: "Tarjetas",
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      yesNoButton(
                                        cardType != "none",
                                        "SI",
                                        () =>
                                            setState(() => cardType = "debit"),
                                      ),
                                      const SizedBox(width: 10),
                                      yesNoButton(
                                        cardType == "none",
                                        "NO",
                                        () => setState(() => cardType = "none"),
                                      ),
                                    ],
                                  ),

                                  if (cardType != "none") ...[
                                    const SizedBox(height: 20),

                                    DropdownButtonFormField<String>(
                                      value: cardType,
                                      dropdownColor: const Color(0xFF1C1C2E),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "debit",
                                          child: Text("Débito"),
                                        ),
                                        DropdownMenuItem(
                                          value: "credit",
                                          child: Text("Crédito"),
                                        ),
                                        DropdownMenuItem(
                                          value: "both",
                                          child: Text("Ambas"),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => cardType = v!),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ================= DEUDAS =================
                            sectionCard(
                              icon: Icons.account_balance_wallet_outlined,
                              title: "Deudas",
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      yesNoButton(
                                        hasDebt,
                                        "SI",
                                        () => setState(() => hasDebt = true),
                                      ),
                                      const SizedBox(width: 10),
                                      yesNoButton(
                                        !hasDebt,
                                        "NO",
                                        () => setState(() => hasDebt = false),
                                      ),
                                    ],
                                  ),

                                  if (hasDebt) ...[
                                    const SizedBox(height: 20),

                                    TextField(
                                      controller: debtAmountController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: "Monto de deuda",
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    TextField(
                                      controller: debtPaymentController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: "Pago de deuda",
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    DropdownButtonFormField<String>(
                                      value: debtFrequency,
                                      dropdownColor: const Color(0xFF1C1C2E),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Semanal",
                                          child: Text("Semanal"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Quincenal",
                                          child: Text("Quincenal"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Mensual",
                                          child: Text("Mensual"),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => debtFrequency = v!),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: registerUser,
                                child: const Text("Crear cuenta"),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
