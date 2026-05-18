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

class _FinancialInfoPageState extends State<FinancialInfoPage> {
  final _formKey = GlobalKey<FormState>();

  bool works = false;
  bool hasDebt = false;

  final incomeController = TextEditingController();
  final debtAmountController = TextEditingController();
  final debtPaymentController = TextEditingController();

  String incomeFrequency = "Mensual";
  String debtFrequency = "Mensual";

  /// CARD TYPE:
  /// none | debit | credit | both
  String cardType = "none";

  final String baseUrl = "https://finanza-app.onrender.com";

  @override
  void dispose() {
    incomeController.dispose();
    debtAmountController.dispose();
    debtPaymentController.dispose();
    super.dispose();
  }

  Widget yesNoButton(bool value, bool current, String text, Function() onTap) {
    bool selected = value == current;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.cyanAccent : const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(14),
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

  InputDecoration customInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF0F0F1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
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
      "income": works ? incomeController.text.trim() : "0",
      "incomeFrequency": incomeFrequency,
      "hasDebt": hasDebt,
      "debtAmount": hasDebt ? debtAmountController.text.trim() : "0",
      "debtPayment": hasDebt ? debtPaymentController.text.trim() : "0",
      "debtFrequency": debtFrequency,
      "cardType": cardType,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cuenta creada correctamente")),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error conexión: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Información financiera"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Paso 4 de 4",
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 8),

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
                          true,
                          works,
                          "SI",
                          () => setState(() => works = true),
                        ),
                        const SizedBox(width: 10),
                        yesNoButton(
                          false,
                          works,
                          "NO",
                          () => setState(() => works = false),
                        ),
                      ],
                    ),

                    if (works) ...[
                      const SizedBox(height: 20),

                      TextField(
                        controller: incomeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: customInput("Ingreso mensual"),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: incomeFrequency,
                        dropdownColor: const Color(0xFF1C1C2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: customInput("Frecuencia de ingreso"),
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
                        onChanged: (value) {
                          setState(() {
                            incomeFrequency = value ?? "Mensual";
                          });
                        },
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
                          true,
                          cardType != "none",
                          "SI",
                          () => setState(() => cardType = "debit"),
                        ),
                        const SizedBox(width: 10),
                        yesNoButton(
                          false,
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
                        style: const TextStyle(color: Colors.white),
                        decoration: customInput("Tipo de tarjeta"),

                        items: const [
                          DropdownMenuItem(
                            value: "debit",
                            child: Text("Débito"),
                          ),
                          DropdownMenuItem(
                            value: "credit",
                            child: Text("Crédito"),
                          ),
                          DropdownMenuItem(value: "both", child: Text("Ambas")),
                        ],

                        onChanged: (value) {
                          setState(() {
                            cardType = value ?? "none";
                          });
                        },
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
                          true,
                          hasDebt,
                          "SI",
                          () => setState(() => hasDebt = true),
                        ),
                        const SizedBox(width: 10),
                        yesNoButton(
                          false,
                          hasDebt,
                          "NO",
                          () => setState(() => hasDebt = false),
                        ),
                      ],
                    ),

                    if (hasDebt) ...[
                      const SizedBox(height: 20),

                      TextField(
                        controller: debtAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: customInput("Monto de deuda"),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: debtPaymentController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: customInput("Pago de deuda"),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: debtFrequency,
                        dropdownColor: const Color(0xFF1C1C2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: customInput("Frecuencia de pago"),
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
                        onChanged: (value) {
                          setState(() {
                            debtFrequency = value ?? "Mensual";
                          });
                        },
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
            ],
          ),
        ),
      ),
    );
  }
}
