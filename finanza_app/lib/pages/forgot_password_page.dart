import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  final String baseUrl = "https://finanza-app.onrender.com";

  bool isLoading = false;
  bool codeSent = false;
  bool obscurePassword = true;
  String? debugToken;

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

  Future<void> sendReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingresa tu correo")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final debugToken = body["token"]?.toString();

        setState(() {
          codeSent = true;
          this.debugToken = debugToken;
          if (debugToken != null && debugToken.isNotEmpty) {
            tokenController.text = debugToken;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              debugToken == null || debugToken.isEmpty
                  ? "Código enviado a tu correo"
                  : "Código de prueba: $debugToken",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final token = tokenController.text.trim();
    final password = passwordController.text.trim();

    if (token.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa código y nueva contraseña")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener al menos 6 caracteres"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "token": token,
          "new_password": password,
        }),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Contraseña actualizada")));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    emailController.dispose();
    tokenController.dispose();
    passwordController.dispose();
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
              "Recuperar contraseña",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.6 + value * 1.2, -0.8 + value * 0.5),
                      radius: 1.2,
                      colors: [
                        Colors.cyanAccent.withValues(alpha: 0.18),
                        Colors.purpleAccent.withValues(alpha: 0.10),
                        const Color(0xFF0F0F1A),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: glowPanel(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_reset,
                            size: 72,
                            color: Colors.cyanAccent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            codeSent
                                ? "Ingresa el código"
                                : "Recupera tu contraseña",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            codeSent
                                ? "Revisa tu correo y escribe el código recibido"
                                : "Ingresa tu correo y te enviaremos un código",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: emailController,
                            enabled: !codeSent && !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: inputDecoration("Correo"),
                          ),
                          if (debugToken != null && debugToken!.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Código de prueba",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    debugToken!,
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (codeSent) ...[
                            const SizedBox(height: 15),
                            TextField(
                              controller: tokenController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputDecoration("Código"),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputDecoration("Nueva contraseña")
                                  .copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                            ),
                          ],
                          const SizedBox(height: 30),
                          glowButtonWrapper(
                            color: Colors.cyanAccent,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : codeSent
                                    ? resetPassword
                                    : sendReset,
                                style: glowButtonStyle(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  glowColor: Colors.cyanAccent,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        codeSent
                                            ? "Cambiar contraseña"
                                            : "Enviar código",
                                      ),
                              ),
                            ),
                          ),
                          if (codeSent) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        codeSent = false;
                                        tokenController.clear();
                                        passwordController.clear();
                                        debugToken = null;
                                      });
                                    },
                              child: const Text(
                                "Usar otro correo",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF11112A).withValues(alpha: 0.92),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.cyanAccent.withValues(alpha: 0.28),
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    );
  }

  Widget glowPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.22),
            blurRadius: 30,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.10),
            blurRadius: 42,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget glowButtonWrapper({
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 52,
            spreadRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }

  static ButtonStyle glowButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color glowColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(vertical: 17),
      elevation: 18,
      shadowColor: glowColor.withValues(alpha: 0.90),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
      ),
    );
  }
}
