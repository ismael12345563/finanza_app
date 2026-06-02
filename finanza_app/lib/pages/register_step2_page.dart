import 'package:flutter/material.dart';

class RegisterStep2Page extends StatefulWidget {
  final String accountType;

  const RegisterStep2Page({super.key, required this.accountType});

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AnimationController animationController;
  late final Animation<double> backgroundAnimation;

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

  @override
  void dispose() {
    animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFF0F0F1A),

          appBar: AppBar(
            title: const Text(
              "Datos de acceso",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          body: SizedBox.expand(
            child: Stack(
              children: [
                // 🌌 BACKGROUND BASE
                Positioned.fill(
                  child: Container(
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
                ),

                // 🌈 ANIMATED GLOW
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          -0.6 + (backgroundAnimation.value * 1.2),
                          -0.8 + (backgroundAnimation.value * 0.4),
                        ),
                        radius: 1.7,
                        colors: [
                          Colors.cyanAccent.withOpacity(0.18),
                          Colors.purpleAccent.withOpacity(0.14),
                          const Color(0xFF0F0F1A),
                        ],
                      ),
                    ),
                  ),
                ),

                // 📄 CONTENT (SIN FADE, YA ESTABLE)
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Paso 3 de 4",
                              style: TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(height: 8),

                            LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: Colors.white12,
                              color: Colors.cyanAccent,
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Datos de acceso",
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 30),

                            TextFormField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.white),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? "Ingresa tu correo"
                                  : null,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.cyanAccent,
                                ),
                                labelText: "Correo electrónico",
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
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? "Ingresa una contraseña"
                                  : null,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.purpleAccent,
                                ),
                                labelText: "Crear contraseña",
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

                            const SizedBox(height: 40),

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
                                    Navigator.pushNamed(
                                      context,
                                      '/financial_info',
                                      arguments: {
                                        "accountType": widget.accountType,
                                        "email": emailController.text.trim(),
                                        "password": passwordController.text
                                            .trim(),
                                      },
                                    );
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
          ),
        );
      },
    );
  }
}
