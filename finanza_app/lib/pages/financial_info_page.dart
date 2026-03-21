import 'package:flutter/material.dart';

class FinancialInfoPage extends StatefulWidget {
  final String accountType;

  const FinancialInfoPage({super.key, required this.accountType});

  @override
  State<FinancialInfoPage> createState() => _FinancialInfoPageState();
}

class _FinancialInfoPageState extends State<FinancialInfoPage> {
  final _formKey = GlobalKey<FormState>();

  /// PERSONAL
  bool works = false;
  bool hasDebt = false;

  final incomeController = TextEditingController();
  String incomeFrequency = "Mensual";

  final debtAmountController = TextEditingController();
  final debtPaymentController = TextEditingController();
  String debtFrequency = "Mensual";

  /// BUSINESS
  final businessNameController = TextEditingController();
  final businessIncomeController = TextEditingController();
  final employeesController = TextEditingController();
  String businessType = "Tienda";

  @override
  void dispose() {
    incomeController.dispose();
    debtAmountController.dispose();
    debtPaymentController.dispose();
    businessNameController.dispose();
    businessIncomeController.dispose();
    employeesController.dispose();
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
                /// PROGRESS
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

                /// PERSONAL
                if (widget.accountType == "personal") ...[
                  /// TRABAJO
                  const Text(
                    "¿Trabajas?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      yesNoButton(true, works, "SI", () {
                        setState(() {
                          works = true;
                        });
                      }),
                      const SizedBox(width: 10),
                      yesNoButton(false, works, "NO", () {
                        setState(() {
                          works = false;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SI TRABAJA
                  if (works) ...[
                    TextFormField(
                      controller: incomeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),

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
                      value: incomeFrequency,
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
                        setState(() {
                          incomeFrequency = value!;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 30),

                  /// DEUDAS
                  const Text(
                    "¿Tienes deudas?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      yesNoButton(true, hasDebt, "SI", () {
                        setState(() {
                          hasDebt = true;
                        });
                      }),
                      const SizedBox(width: 10),
                      yesNoButton(false, hasDebt, "NO", () {
                        setState(() {
                          hasDebt = false;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SI TIENE DEUDA
                  if (hasDebt) ...[
                    TextFormField(
                      controller: debtAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),

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

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: debtFrequency,
                      dropdownColor: const Color(0xFF1C1C2E),
                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: "¿Cada cuánto pagas?",
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
                        setState(() {
                          debtFrequency = value!;
                        });
                      },
                    ),
                  ],
                ],

                const SizedBox(height: 40),

                /// CREAR CUENTA
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),

                    onPressed: () {
                      print("Cuenta creada");
                    },

                    child: const Text(
                      "Crear cuenta",
                      style: TextStyle(fontSize: 16),
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
