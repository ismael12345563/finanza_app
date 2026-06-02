import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final String email;

  const HistoryPage({super.key, required this.email});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  final String baseUrl = "https://finanza-app.onrender.com";

  List allData = [];

  String selectedFilter = "Todos";

  bool loading = true;

  late AnimationController backgroundController;
  late Animation<double> backgroundAnimation;

  @override
  void initState() {
    super.initState();

    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    backgroundAnimation = CurvedAnimation(
      parent: backgroundController,
      curve: Curves.easeInOut,
    );

    loadHistory();
  }

  @override
  void dispose() {
    backgroundController.dispose();
    super.dispose();
  }

  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: backgroundAnimation,
      builder: (context, child) {
        final value = backgroundAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF020611),
                Color.lerp(
                  const Color(0xFF081328),
                  const Color(0xFF190A2E),
                  value,
                )!,
                const Color(0xFF050510),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -0.7 + (value * 0.5),
                        -0.9 + (value * 0.25),
                      ),
                      radius: 1.05,
                      colors: [
                        Colors.cyanAccent.withValues(alpha: 0.16),
                        Colors.blueAccent.withValues(alpha: 0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.75 - (value * 0.35),
                        -0.15 + (value * 0.25),
                      ),
                      radius: 1.2,
                      colors: [
                        Colors.purpleAccent.withValues(alpha: 0.12),
                        Colors.deepPurple.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              ...List.generate(65, (index) {
                final x = ((index * 37) % 100) / 50 - 1;
                final y = ((index * 61) % 100) / 50 - 1;
                final drift = ((index % 5) - 2) * 0.012 * value;
                final size = 1.2 + (index % 4) * 0.55;
                final opacity = 0.16 + ((index % 6) * 0.07);

                return Align(
                  alignment: Alignment(x + drift, y - drift),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: opacity),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(
                            alpha: opacity * 0.55,
                          ),
                          blurRadius: 6 + (index % 5).toDouble(),
                          spreadRadius: 0.4,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
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

      if (!mounted) return;

      setState(() {
        allData = temp;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

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
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Historial financiero",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: animatedBackground()),
          loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1C1C2E,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 22,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            dropdownColor: const Color(0xFF1C1C2E),
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(
                                value: "Todos",
                                child: Text("Todos"),
                              ),
                              DropdownMenuItem(
                                value: "Ingreso",
                                child: Text("Ingresos"),
                              ),
                              DropdownMenuItem(
                                value: "Deuda",
                                child: Text("Deudas"),
                              ),
                              DropdownMenuItem(
                                value: "Gasto",
                                child: Text("Gastos"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedFilter = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                        color: const Color(
                                          0xFF1C1C2E,
                                        ).withValues(alpha: 0.92),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: getColor(
                                            item["type"],
                                          ).withValues(alpha: 0.28),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: getColor(
                                              item["type"],
                                            ).withValues(alpha: 0.18),
                                            blurRadius: 26,
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: Colors.purpleAccent
                                                .withValues(alpha: 0.08),
                                            blurRadius: 36,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: getColor(
                                                item["type"],
                                              ).withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: getColor(
                                                    item["type"],
                                                  ).withValues(alpha: 0.18),
                                                  blurRadius: 16,
                                                  spreadRadius: 1,
                                                ),
                                              ],
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
                                                    color: getColor(
                                                      item["type"],
                                                    ),
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
                                              shadows: [
                                                Shadow(
                                                  color: getColor(
                                                    item["type"],
                                                  ).withValues(alpha: 0.55),
                                                  blurRadius: 10,
                                                ),
                                              ],
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
                ),
        ],
      ),
    );
  }
}
