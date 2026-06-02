import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> backgroundAnimation;

  bool isLoginPressed = false;
  bool isRegisterPressed = false;

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
    super.dispose();
  }

  Widget animatedButton({
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
    required Widget child,
    required Color shadowColor,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapCancel(),
      child: AnimatedScale(
        scale: isPressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(isPressed ? 0.2 : 0.5),
                blurRadius: isPressed ? 10 : 25,
                offset: Offset(0, isPressed ? 2 : 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: backgroundAnimation,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -0.6 + backgroundAnimation.value,
                        -0.8 + backgroundAnimation.value * 0.5,
                      ),
                      radius: 1.2,
                      colors: [
                        Colors.cyanAccent.withOpacity(0.15),
                        Colors.purpleAccent.withOpacity(0.08),
                        const Color(0xFF0F0F1A),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 🔥 LOGO (aquí luego metemos imagen)
                      Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Astro Fine",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Tu dinero bajo control, como en otra galaxia 💫",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                      // 🔘 BOTONES
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: animatedButton(
                              isPressed: isLoginPressed,
                              shadowColor: Colors.cyanAccent,
                              onTapDown: () =>
                                  setState(() => isLoginPressed = true),
                              onTapUp: () =>
                                  setState(() => isLoginPressed = false),
                              onTapCancel: () =>
                                  setState(() => isLoginPressed = false),
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
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text("Iniciar Sesión"),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: animatedButton(
                              isPressed: isRegisterPressed,
                              shadowColor: Colors.purpleAccent,
                              onTapDown: () =>
                                  setState(() => isRegisterPressed = true),
                              onTapUp: () =>
                                  setState(() => isRegisterPressed = false),
                              onTapCancel: () =>
                                  setState(() => isRegisterPressed = false),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.purpleAccent,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text(
                                  "Registrarse",
                                  style: TextStyle(color: Colors.purpleAccent),
                                ),
                              ),
                            ),
                          ),
                        ],
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
