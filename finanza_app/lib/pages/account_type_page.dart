import 'package:flutter/material.dart';
import 'register_step2_page.dart';

class AccountTypePage extends StatefulWidget {
  const AccountTypePage({super.key});

  @override
  State<AccountTypePage> createState() => _AccountTypePageState();
}

class _AccountTypePageState extends State<AccountTypePage> {
  String? selectedType;

  Widget buildOption(String type, String text, IconData icon) {
    bool selected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: selected ? Colors.cyanAccent : Colors.white12,
            width: 2,
          ),
        ),

        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 30),

            const SizedBox(width: 15),

            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
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
          "Tipo de cuenta",
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

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// BARRA DE PROGRESO
              const Text(
                "Paso 2 de 4",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: 0.50,
                backgroundColor: Colors.white12,
                color: Colors.cyanAccent,
              ),

              const SizedBox(height: 30),

              const Text(
                "¿Cómo usarás Astro Fi?",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              buildOption("personal", "Uso personal", Icons.person),

              buildOption(
                "business",
                "Tengo un negocio (PYME)",
                Icons.business,
              ),

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
                    if (selectedType != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegisterStep2Page(accountType: selectedType!),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Siguiente",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
