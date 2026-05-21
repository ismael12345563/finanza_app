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

  final TextEditingController limitController = TextEditingController();
  final TextEditingController debtController = TextEditingController();
  final TextEditingController closingDayController = TextEditingController();
  final TextEditingController paymentDayController = TextEditingController();
  final TextEditingController lateMonthsController = TextEditingController();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCard();
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
          "late_months": int.tryParse(lateMonthsController.text) ?? 0,
        }),
      );

      limitController.clear();
      debtController.clear();
      closingDayController.clear();
      paymentDayController.clear();
      lateMonthsController.clear();

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
          "late_months": int.tryParse(lateMonthsController.text) ?? 0,
        }),
      );

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

  @override
  Widget build(BuildContext context) {
    double limit = double.tryParse(card["credit_limit"].toString()) ?? 0;

    double balance = double.tryParse(card["balance"].toString()) ?? 0;

    double available = limit - balance;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        title: const Text("Tarjeta de Crédito"),
        backgroundColor: Colors.transparent,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : card.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),

              child: SingleChildScrollView(
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

                    const SizedBox(height: 25),

                    // LIMITE
                    Row(
                      children: [
                        const Text(
                          "Límite de crédito",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Tooltip(
                          message:
                              "Es el máximo dinero que el banco te presta.",

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
                      controller: limitController,
                      keyboardType: TextInputType.number,

                      style: const TextStyle(color: Colors.white),

                      decoration: const InputDecoration(
                        hintText: "Ejemplo: 15000",
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SALDO USADO
                    Row(
                      children: [
                        const Text(
                          "Saldo usado",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Tooltip(
                          message: "Dinero que ya utilizaste de tu tarjeta.",

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
                      controller: debtController,
                      keyboardType: TextInputType.number,

                      style: const TextStyle(color: Colors.white),

                      decoration: const InputDecoration(
                        hintText: "Ejemplo: 3500",
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FECHA CORTE
                    Row(
                      children: [
                        const Text(
                          "Fecha de corte",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Tooltip(
                          message: "Día que el banco cierra tu periodo.",

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
                      controller: closingDayController,
                      keyboardType: TextInputType.number,

                      style: const TextStyle(color: Colors.white),

                      decoration: const InputDecoration(
                        hintText: "Ejemplo: 20",
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FECHA LIMITE
                    Row(
                      children: [
                        const Text(
                          "Fecha límite de pago",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Tooltip(
                          message: "Último día para pagar.",

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
                      controller: paymentDayController,
                      keyboardType: TextInputType.number,

                      style: const TextStyle(color: Colors.white),

                      decoration: const InputDecoration(
                        hintText: "Ejemplo: 5",
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MESES ATRASO
                    Row(
                      children: [
                        const Text(
                          "Meses de atraso",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Tooltip(
                          message: "Cantidad de meses atrasado en pagos.",

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
                      controller: lateMonthsController,
                      keyboardType: TextInputType.number,

                      style: const TextStyle(color: Colors.white),

                      decoration: const InputDecoration(
                        hintText: "Ejemplo: 2",
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: createCard,
                        child: const Text("Guardar tarjeta"),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
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
                          "Saldo usado: \$${balance.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        Text(
                          "Disponible: \$${available.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.cyanAccent),
                        ),

                        Text(
                          "Meses atraso: ${card["late_months"] ?? 0}",
                          style: const TextStyle(color: Colors.orange),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: () {
                              limitController.text = card["credit_limit"]
                                  .toString();

                              debtController.text = card["balance"].toString();

                              closingDayController.text = card["closing_day"]
                                  .toString();

                              paymentDayController.text = card["payment_day"]
                                  .toString();

                              lateMonthsController.text = card["late_months"]
                                  .toString();

                              showDialog(
                                context: context,

                                builder: (_) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFF1C1C2E),

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

                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),

                                            decoration: const InputDecoration(
                                              hintText: "Límite",
                                            ),
                                          ),

                                          const SizedBox(height: 15),

                                          TextField(
                                            controller: debtController,
                                            keyboardType: TextInputType.number,

                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),

                                            decoration: const InputDecoration(
                                              hintText: "Saldo usado",
                                            ),
                                          ),

                                          const SizedBox(height: 15),

                                          TextField(
                                            controller: closingDayController,
                                            keyboardType: TextInputType.number,

                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),

                                            decoration: const InputDecoration(
                                              hintText: "Fecha corte",
                                            ),
                                          ),

                                          const SizedBox(height: 15),

                                          TextField(
                                            controller: paymentDayController,
                                            keyboardType: TextInputType.number,

                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),

                                            decoration: const InputDecoration(
                                              hintText: "Fecha pago",
                                            ),
                                          ),

                                          const SizedBox(height: 15),

                                          TextField(
                                            controller: lateMonthsController,
                                            keyboardType: TextInputType.number,

                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),

                                            decoration: const InputDecoration(
                                              hintText: "Meses atraso",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },

                                        child: const Text("Cancelar"),
                                      ),

                                      ElevatedButton(
                                        onPressed: editCard,
                                        child: const Text("Guardar"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            child: const Text("Editar tarjeta"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

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

                  const SizedBox(height: 15),

                  TextField(
                    controller: descController,

                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      hintText: "Descripción",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: addTransaction,
                      child: const Text("Guardar gasto"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
