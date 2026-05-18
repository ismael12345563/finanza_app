import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardPage extends StatefulWidget {
  final String email;

  const CardPage({super.key, required this.email});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final String baseUrl = "https://finanza-app.onrender.com";

  Map card = {};
  bool loading = true;

  TextEditingController amountController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCard();
  }

  Future<void> getCard() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_card/${widget.email}"),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty) {
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
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addTransaction() async {
    await http.post(
      Uri.parse("$baseUrl/card_transaction"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "amount": double.parse(amountController.text),
        "description": descController.text,
      }),
    );

    amountController.clear();
    descController.clear();

    getCard();
  }

  @override
  Widget build(BuildContext context) {
    double limit = (card["credit_limit"] ?? 0).toDouble();
    double balance = (card["balance"] ?? 0).toDouble();
    double available = limit - balance;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("Tarjeta de Crédito"),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💳 RESUMEN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Resumen de tarjeta",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 15),

                        Text(
                          "Límite: \$${limit.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        Text(
                          "Deuda: \$${balance.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        Text(
                          "Disponible: \$${available.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.cyanAccent),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 💸 NUEVO GASTO
                  const Text(
                    "Nuevo gasto",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Monto",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),

                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Descripción",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: addTransaction,
                    child: const Text("Guardar gasto"),
                  ),
                ],
              ),
            ),
    );
  }
}
