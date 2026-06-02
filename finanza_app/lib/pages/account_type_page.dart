import 'package:flutter/material.dart';

class AccountTypePage extends StatefulWidget {
  const AccountTypePage({super.key});

  @override
  State<AccountTypePage> createState() => _AccountTypePageState();
}

class _AccountTypePageState extends State<AccountTypePage>
    with SingleTickerProviderStateMixin {
  String? selectedType;
  bool isPressed = false;

  AnimationController? animationController;
  Animation<double>? backgroundAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController!, curve: Curves.easeInOut),
    );
  }

  Widget buildOption(String type, String text, IconData icon) {
    final selected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.cyanAccent : Colors.white12,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : [],
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
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController ?? const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        final bg = backgroundAnimation?.value ?? 0.0;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFF0F0F1A),

          appBar: AppBar(
            title: const Text(
              "Tipo de cuenta",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.purpleAccent),
          ),

          body: Stack(
            children: [
              // 🌌 BACKGROUND
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF241038),
                      Color(0xFF142A36),
                      Color(0xFF1B1230),
                      Color(0xFF0F0F1A),
                    ],
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.6 + bg * 1.2, -0.8 + bg * 0.4),
                    radius: 1.7,
                    colors: [
                      Colors.cyanAccent.withOpacity(0.18),
                      Colors.purpleAccent.withOpacity(0.14),
                      const Color(0xFF0F0F1A),
                    ],
                  ),
                ),
              ),

              // 📄 CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        "¿Cómo usarás Astro Fine?",
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
                        "Para probar la app",
                        Icons.business,
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (selectedType == null) return;

                            Navigator.pushNamed(
                              context,
                              '/register_step2',
                              arguments: selectedType,
                            );
                          },
                          child: const Text("Siguiente"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
