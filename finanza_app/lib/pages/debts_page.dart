import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DebtsPage extends StatefulWidget {
  final String email;

  const DebtsPage({super.key, required this.email});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  List debts = [];

  final String baseUrl = "https://finanza-app.onrender.com";

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final paymentController = TextEditingController();

  String selectedFrequency = "Mensual";

  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    getDebts();
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

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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

    amountController.dispose();
    descriptionController.dispose();
    paymentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        title: const Text("Deudas", style: TextStyle(color: Colors.white)),

        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
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
              value: selectedFrequency,

              dropdownColor: const Color(0xFF1C1C2E),

              style: const TextStyle(color: Colors.white),

              decoration: inputDecoration("Frecuencia de pago"),

              items: ["Diario", "Semanal", "Quincenal", "Mensual", "Anual"].map(
                (frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(
                      frequency,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ).toList(),

              onChanged: (value) {
                if (!mounted || isDisposed) return;

                setState(() {
                  selectedFrequency = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: addDebt,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                child: const Text("Agregar deuda"),
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C2E),
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                debt["description"] ?? "",

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "\$${remaining.toStringAsFixed(2)}",

                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 15),

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showPaymentDialog(debt["id"]);
                                      },

                                      icon: const Icon(Icons.payments),
                                      label: const Text("Abonar"),

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.greenAccent,
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  IconButton(
                                    onPressed: () {
                                      deleteDebt(debt["id"]);
                                    },

                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
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
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(color: Colors.white70),

      filled: true,
      fillColor: const Color(0xFF1C1C2E),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
