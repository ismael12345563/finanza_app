import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DebtPage extends StatefulWidget {
  final String email;

  const DebtPage({super.key, required this.email});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  final String baseUrl = "https://finanza-app.onrender.com";

  Future<void> addDebt() async {
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
        }),
      );

      if (response.statusCode == 200) {
        amountController.clear();
        descriptionController.clear();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Deuda agregada 🔥")));

        Navigator.pop(context); // regresa al home o lista
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("Agregar deuda"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Monto",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Descripción",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: addDebt,
              child: const Text("Agregar deuda"),
            ),
          ],
        ),
      ),
    );
  }
}
