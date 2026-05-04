import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "Bienvenido 🚀",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
