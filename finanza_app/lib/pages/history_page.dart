import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final String email;

  const HistoryPage({super.key, required this.email});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String baseUrl = "https://finanza-app.onrender.com";

  List allData = [];

  String selectedFilter = "Todos";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final incomesResponse = await http.get(
        Uri.parse("$baseUrl/get_incomes/${widget.email}"),
      );

      final debtsResponse = await http.get(
        Uri.parse("$baseUrl/get_debts/${widget.email}"),
      );

      final expensesResponse = await http.get(
        Uri.parse("$baseUrl/get_expenses/${widget.email}"),
      );

      List temp = [];

      if (incomesResponse.statusCode == 200) {
        final incomes = jsonDecode(incomesResponse.body);

        for (var item in incomes) {
          temp.add({...item, "type": "Ingreso"});
        }
      }

      if (debtsResponse.statusCode == 200) {
        final debts = jsonDecode(debtsResponse.body);

        for (var item in debts) {
          temp.add({...item, "type": "Deuda"});
        }
      }

      if (expensesResponse.statusCode == 200) {
        final expenses = jsonDecode(expensesResponse.body);

        for (var item in expenses) {
          temp.add({...item, "type": "Gasto"});
        }
      }

      temp.sort((a, b) {
        return DateTime.parse(
          b["created_at"],
        ).compareTo(DateTime.parse(a["created_at"]));
      });

      setState(() {
        allData = temp;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return "${parsed.day}/${parsed.month}/${parsed.year}";
    } catch (e) {
      return "";
    }
  }

  List get filteredData {
    if (selectedFilter == "Todos") {
      return allData;
    }

    return allData.where((item) {
      return item["type"] == selectedFilter;
    }).toList();
  }

  Color getColor(String type) {
    switch (type) {
      case "Ingreso":
        return Colors.greenAccent;

      case "Deuda":
        return Colors.redAccent;

      case "Gasto":
        return Colors.orangeAccent;

      default:
        return Colors.white;
    }
  }

  IconData getIcon(String type) {
    switch (type) {
      case "Ingreso":
        return Icons.attach_money;

      case "Deuda":
        return Icons.money_off;

      case "Gasto":
        return Icons.shopping_cart;

      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Historial financiero"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  // =========================
                  // FILTRO
                  // =========================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),

                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C2E),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: DropdownButton<String>(
                      value: selectedFilter,
                      dropdownColor: const Color(0xFF1C1C2E),
                      isExpanded: true,
                      underline: const SizedBox(),

                      style: const TextStyle(color: Colors.white),

                      items: const [
                        DropdownMenuItem(value: "Todos", child: Text("Todos")),
                        DropdownMenuItem(
                          value: "Ingreso",
                          child: Text("Ingresos"),
                        ),
                        DropdownMenuItem(value: "Deuda", child: Text("Deudas")),
                        DropdownMenuItem(value: "Gasto", child: Text("Gastos")),
                      ],

                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // LISTA
                  // =========================
                  Expanded(
                    child: filteredData.isEmpty
                        ? const Center(
                            child: Text(
                              "Sin registros",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredData.length,

                            itemBuilder: (context, index) {
                              final item = filteredData[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),

                                padding: const EdgeInsets.all(18),

                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C1C2E),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),

                                      decoration: BoxDecoration(
                                        color: getColor(
                                          item["type"],
                                        ).withOpacity(0.15),

                                        borderRadius: BorderRadius.circular(16),
                                      ),

                                      child: Icon(
                                        getIcon(item["type"]),
                                        color: getColor(item["type"]),
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            item["description"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            item["type"],
                                            style: TextStyle(
                                              color: getColor(item["type"]),
                                              fontSize: 13,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            formatDate(
                                              item["created_at"] ?? "",
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      "\$${item["amount"]}",
                                      style: TextStyle(
                                        color: getColor(item["type"]),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
}
