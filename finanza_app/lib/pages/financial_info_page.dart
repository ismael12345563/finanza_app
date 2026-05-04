import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinancialInfoPage extends StatefulWidget {
  final String accountType;
  final String email; // 👈 NUEVO
  final String password; // 👈 NUEVO

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
  String incomeFrequency = "Mensual";

  final debtAmountController = TextEditingController();
  final debtPaymentController = TextEditingController();
  String debtFrequency = "Mensual";

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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
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

  String? numberValidator(String? value) {
    if (value == null || value.isEmpty) return "Campo requerido";
    if (double.tryParse(value) == null) return "Solo números";
    return null;
  }

  /// 🔥 REGISTRO COMPLETO (AHORA CON EMAIL Y PASSWORD)
  Future<void> registerUser() async {
    final url = Uri.parse("http://127.0.0.1:8000/register");

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
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Registro exitoso 🔥");
        print(response.body);

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        print("Error backend: ${response.body}");
      }
    } catch (e) {
      print("Error conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        title: const Text(
          "Información financiera",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Paso 4 de 4",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.white12,
                  color: Colors.cyanAccent,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Información financiera",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (widget.accountType == "personal") ...[
                  const Text(
                    "¿Trabajas?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      yesNoButton(true, works, "SI", () {
                        setState(() => works = true);
                      }),
                      const SizedBox(width: 10),
                      yesNoButton(false, works, "NO", () {
                        setState(() => works = false);
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (works) ...[
                    TextFormField(
                      controller: incomeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      validator: numberValidator,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.cyanAccent,
                        ),
                        labelText: "¿Cuánto ganas?",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1C1C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      initialValue: incomeFrequency,
                      dropdownColor: const Color(0xFF1C1C2E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "¿Cada cuánto te pagan?",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1C1C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        setState(() => incomeFrequency = value!);
                      },
                    ),
                  ],

                  const SizedBox(height: 30),

                  const Text(
                    "¿Tienes deudas?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      yesNoButton(true, hasDebt, "SI", () {
                        setState(() => hasDebt = true);
                      }),
                      const SizedBox(width: 10),
                      yesNoButton(false, hasDebt, "NO", () {
                        setState(() => hasDebt = false);
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (hasDebt) ...[
                    TextFormField(
                      controller: debtAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      validator: numberValidator,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.money_off,
                          color: Colors.redAccent,
                        ),
                        labelText: "¿Cuánto debes?",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1C1C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: debtPaymentController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      validator: numberValidator,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.payment,
                          color: Colors.orangeAccent,
                        ),
                        labelText: "¿Cuánto pagas cada vez?",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1C1C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    child: const Text("Crear cuenta"),
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
