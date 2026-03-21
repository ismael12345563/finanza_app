import 'package:flutter/material.dart';
import 'account_type_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final birthController = TextEditingController();

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
    nameController.dispose();
    ageController.dispose();
    birthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        title: const Text("Registro", style: TextStyle(color: Colors.white)),

        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.purpleAccent,
            size: 28,
          ),

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

                /// NOMBRE
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa tu nombre";
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.cyanAccent,
                    ),

                    labelText: "Nombre completo",
                    labelStyle: const TextStyle(color: Colors.white70),

                    filled: true,
                    fillColor: const Color(0xFF1C1C2E),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// EDAD
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa tu edad";
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.cake,
                      color: Colors.purpleAccent,
                    ),

                    labelText: "Edad",
                    labelStyle: const TextStyle(color: Colors.white70),

                    filled: true,
                    fillColor: const Color(0xFF1C1C2E),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// FECHA DE NACIMIENTO
                TextFormField(
                  controller: birthController,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Selecciona tu fecha";
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.cyanAccent,
                    ),

                    labelText: "Fecha de nacimiento",
                    labelStyle: const TextStyle(color: Colors.white70),

                    filled: true,
                    fillColor: const Color(0xFF1C1C2E),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onTap: () {
                    selectDate(context);
                  },
                ),

                const SizedBox(height: 30),

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
                            builder: (context) => const AccountTypePage(),
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
