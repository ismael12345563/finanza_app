import 'package:flutter/material.dart';
import 'financial_info_page.dart';

class RegisterStep2Page extends StatefulWidget {
  final String accountType;

  const RegisterStep2Page({super.key, required this.accountType});

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hasCard = false;
  String cardType = "Debito";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget cardOption(bool value, String text) {
    bool selected = hasCard == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            hasCard = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.cyanAccent : const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          "Datos de acceso",
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

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// BARRA DE PROGRESO
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

                /// EMAIL
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa tu correo";
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.cyanAccent,
                    ),

                    labelText: "Correo electrónico",
                    labelStyle: const TextStyle(color: Colors.white70),

                    filled: true,
                    fillColor: const Color(0xFF1C1C2E),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa una contraseña";
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.purpleAccent,
                    ),

                    labelText: "Crear contraseña",
                    labelStyle: const TextStyle(color: Colors.white70),

                    filled: true,
                    fillColor: const Color(0xFF1C1C2E),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// TARJETA
                const Text(
                  "¿Cuentas con tarjeta?",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    cardOption(false, "NO"),
                    const SizedBox(width: 10),
                    cardOption(true, "SI"),
                  ],
                ),

                const SizedBox(height: 20),

                /// DESPLEGAR TIPO TARJETA
                if (hasCard)
                  DropdownButtonFormField<String>(
                    initialValue: cardType,
                    dropdownColor: const Color(0xFF1C1C2E),
                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      labelText: "Tipo de tarjeta",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: const [
                      DropdownMenuItem(value: "Debito", child: Text("Débito")),
                      DropdownMenuItem(
                        value: "Credito",
                        child: Text("Crédito"),
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        cardType = value!;
                      });
                    },
                  ),

                const SizedBox(height: 40),

                /// BOTÓN SIGUIENTE
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),

                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FinancialInfoPage(
                              accountType: widget.accountType,
                            ),
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
      ),
    );
  }
}
