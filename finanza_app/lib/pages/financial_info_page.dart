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
  bool hasCard = false;

  final incomeController = TextEditingController();
  final debtAmountController = TextEditingController();
  final debtPaymentController = TextEditingController();

  String cardType = "Débito";
  String incomeFrequency = "Mensual";
  String debtFrequency = "Mensual";

  final String baseUrl = "http://192.168.0.17:8000";

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.cyanAccent : const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.cyanAccent : Colors.white10,
            ),
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
      width: double.infinity,
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
      "hasCreditCard": hasCard,
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Información financiera",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Paso 4 de 4",
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Cuéntanos un poco sobre tus finanzas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                // ==========================
                // TRABAJO
                // ==========================
                sectionCard(
                  icon: Icons.work_outline,
                  title: "Trabajo",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          yesNoButton(true, works, "SI", () {
                            setState(() => works = true);
                          }),
                          const SizedBox(width: 12),
                          yesNoButton(false, works, "NO", () {
                            setState(() => works = false);
                          }),
                        ],
                      ),

                      if (works) ...[
                        const SizedBox(height: 20),

                        TextField(
                          controller: incomeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: customInput("¿Cuánto ganas?"),
                        ),

                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: incomeFrequency,
                          dropdownColor: const Color(0xFF1C1C2E),
                          style: const TextStyle(color: Colors.white),
                          decoration: customInput(
                            "¿Cada cuánto recibes el ingreso?",
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

                          onChanged: (value) {
                            setState(() {
                              incomeFrequency = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                // ==========================
                // TARJETA
                // ==========================
                sectionCard(
                  icon: Icons.credit_card,
                  title: "Tarjetas",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          yesNoButton(true, hasCard, "SI", () {
                            setState(() => hasCard = true);
                          }),
                          const SizedBox(width: 12),
                          yesNoButton(false, hasCard, "NO", () {
                            setState(() => hasCard = false);
                          }),
                        ],
                      ),

                      if (hasCard) ...[
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: cardType,
                          dropdownColor: const Color(0xFF1C1C2E),
                          style: const TextStyle(color: Colors.white),
                          decoration: customInput("Tipo de tarjeta"),

                          items: const [
                            DropdownMenuItem(
                              value: "Débito",
                              child: Text("Débito"),
                            ),
                            DropdownMenuItem(
                              value: "Crédito",
                              child: Text("Crédito"),
                            ),
                          ],

                          onChanged: (value) {
                            setState(() {
                              cardType = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                // ==========================
                // DEUDAS
                // ==========================
                sectionCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Deudas",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          yesNoButton(true, hasDebt, "SI", () {
                            setState(() => hasDebt = true);
                          }),
                          const SizedBox(width: 12),
                          yesNoButton(false, hasDebt, "NO", () {
                            setState(() => hasDebt = false);
                          }),
                        ],
                      ),

                      if (hasDebt) ...[
                        const SizedBox(height: 20),

                        TextField(
                          controller: debtAmountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: customInput("¿Cuánto debes?"),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: debtPaymentController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: customInput("¿Cuánto pagas?"),
                        ),

                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: debtFrequency,
                          dropdownColor: const Color(0xFF1C1C2E),
                          style: const TextStyle(color: Colors.white),
                          decoration: customInput("¿Cada cuánto pagas?"),

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
                              debtFrequency = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    onPressed: registerUser,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: const Text(
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
