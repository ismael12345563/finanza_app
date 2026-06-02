import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final birthController = TextEditingController();

  late AnimationController animationController;
  late Animation<double> backgroundAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    nameController.dispose();
    birthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        final value = backgroundAnimation.value;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFF0F0F1A),

          appBar: AppBar(
            title: const Text(
              "Registro",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.purpleAccent),
          ),

          body: Stack(
            fit: StackFit.expand,
            children: [
              // 🌌 fondo base
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

              // ✨ glow animado
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.4 + value * 0.8, -0.5 + value * 0.5),
                    radius: 1.6,
                    colors: [
                      Colors.cyanAccent.withOpacity(0.20),
                      Colors.purpleAccent.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 📄 contenido normal (SIN fade)
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          const Text(
                            "Paso 1 de 4",
                            style: TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 8),

                          LinearProgressIndicator(
                            value: 0.25,
                            backgroundColor: Colors.white12,
                            color: Colors.cyanAccent,
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Crear cuenta en Astro Fi 🚀",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 30),

                          TextFormField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.cyanAccent,
                              ),
                              labelText: "Nombre completo",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1C1C2E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: birthController,
                            readOnly: true,
                            onTap: () => selectDate(context),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                color: Colors.cyanAccent,
                              ),
                              labelText: "Fecha de nacimiento",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1C1C2E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushNamed(context, '/account_type');
                                }
                              },
                              child: const Text("Siguiente"),
                            ),
                          ),
                        ],
                      ),
                    ),
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
