import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilPage extends StatefulWidget {
  final String email;

  const PerfilPage({super.key, required this.email});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // 🔥 URL DEL BACKEND
  final String baseUrl = "https://finanza-app.onrender.com";

  String selectedStatus = "trabajando";
  bool isWorking = true;

  double totalIncome = 0;
  double totalDebt = 0;

  final TextEditingController notesController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadFinancialData();
  }

  // =========================
  // CARGAR DATOS
  // =========================
  Future<void> loadFinancialData() async {
    try {
      final incomesResponse = await http.get(
        Uri.parse("$baseUrl/get_incomes/${widget.email}"),
      );

      final debtsResponse = await http.get(
        Uri.parse("$baseUrl/get_debts/${widget.email}"),
      );

      if (incomesResponse.statusCode == 200 &&
          debtsResponse.statusCode == 200) {
        final incomes = jsonDecode(incomesResponse.body);
        final debts = jsonDecode(debtsResponse.body);

        double incomeTotal = 0;
        double debtTotal = 0;

        for (var income in incomes) {
          incomeTotal += double.tryParse(income["amount"].toString()) ?? 0;
        }

        for (var debt in debts) {
          debtTotal += double.tryParse(debt["amount"].toString()) ?? 0;
        }

        setState(() {
          totalIncome = incomeTotal;
          totalDebt = debtTotal;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // =========================
  // NIVEL FINANCIERO
  // =========================
  String getFinancialLevel() {
    if (totalIncome <= 0) {
      return "Inicio";
    }

    if (totalDebt > totalIncome) {
      return "Precaución";
    }

    if (totalIncome >= 50000) {
      return "Avanzado";
    }

    if (totalIncome >= 15000) {
      return "Estable";
    }

    return "En crecimiento";
  }

  // =========================
  // TIPS IA
  // =========================
  String getFinancialTip() {
    if (totalDebt > totalIncome) {
      return "Tu deuda supera tus ingresos. Intenta reducir gastos innecesarios.";
    }

    if (totalIncome > 20000) {
      return "Buen trabajo 🔥 considera empezar un fondo de inversión.";
    }

    return "Mantén un control constante de tus gastos e ingresos.";
  }

  // =========================
  // GUARDAR PERFIL
  // =========================
  Future<void> saveProfile() async {
    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "works": isWorking,
          "income_status": selectedStatus,
          "notes": notesController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Perfil actualizado 🔥")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => loading = false);
  }

  // =========================
  // FORMATEAR DINERO
  // =========================
  String money(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalDebt;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Perfil", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =========================
            // TARJETA PERFIL
            // =========================
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF23233A), Color(0xFF1C1C2E)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.cyanAccent,
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),

                      SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Usuario Astro Fi",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    widget.email,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: miniCard(
                          "Ingresos",
                          "\$${money(totalIncome)}",
                          Icons.attach_money,
                          Colors.greenAccent,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: miniCard(
                          "Deudas",
                          "\$${money(totalDebt)}",
                          Icons.money_off,
                          Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // RESUMEN
            // =========================
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
                    "Resumen financiero",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  infoRow("Balance actual", "\$${money(balance)}"),

                  infoRow("Nivel financiero", getFinancialLevel()),

                  infoRow("Estado laboral", selectedStatus),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // IA TIP
            // =========================
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Icon(Icons.auto_awesome, color: Colors.cyanAccent),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      getFinancialTip(),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // SWITCH
            // =========================
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Actualmente trabajando",
                    style: TextStyle(color: Colors.white),
                  ),

                  Switch(
                    value: isWorking,
                    activeColor: Colors.cyanAccent,
                    onChanged: (value) {
                      setState(() {
                        isWorking = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // DROPDOWN
            // =========================
            const Text(
              "Situación laboral",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),

              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(16),
              ),

              child: DropdownButton<String>(
                value: selectedStatus,
                dropdownColor: const Color(0xFF1C1C2E),
                isExpanded: true,
                underline: const SizedBox(),

                style: const TextStyle(color: Colors.white),

                items: const [
                  DropdownMenuItem(
                    value: "trabajando",
                    child: Text("Trabajando"),
                  ),
                  DropdownMenuItem(
                    value: "desempleado",
                    child: Text("Desempleado"),
                  ),
                  DropdownMenuItem(
                    value: "estudiante",
                    child: Text("Estudiante"),
                  ),
                  DropdownMenuItem(
                    value: "sin_ingresos",
                    child: Text("Sin ingresos"),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // NOTAS
            // =========================
            TextField(
              controller: notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                labelText: "Metas o notas financieras",
                labelStyle: const TextStyle(color: Colors.white70),

                filled: true,
                fillColor: const Color(0xFF1C1C2E),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // BOTON GUARDAR
            // =========================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: loading ? null : saveProfile,

                icon: const Icon(Icons.save),

                label: loading
                    ? const CircularProgressIndicator()
                    : const Text("Guardar cambios"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // CERRAR SESION
            // =========================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },

                icon: const Icon(Icons.logout),

                label: const Text("Cerrar sesión"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =========================
  // MINI CARD
  // =========================
  static Widget miniCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(color: Colors.white70)),

          const SizedBox(height: 5),

          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INFO ROW
  // =========================
  static Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
