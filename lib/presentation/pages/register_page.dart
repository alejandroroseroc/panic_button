import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final authCtrl = Get.find<AuthController>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1_rounded,
                      size: 80, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  const Text(
                    'Crea tu cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_nameCtrl, 'Nombre', Icons.person),
                  const SizedBox(height: 15),
                  _buildTextField(_emailCtrl, 'Email', Icons.email),
                  const SizedBox(height: 15),
                  _buildTextField(_passCtrl, 'Password', Icons.lock,
                      obscure: true),
                  const SizedBox(height: 30),
                  Obx(() {
                    return authCtrl.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                authCtrl.register(
                                  _emailCtrl.text.trim(),
                                  _passCtrl.text.trim(),
                                  _nameCtrl.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6D00),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Registrarse'),
                          );
                  }),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                  Obx(() {
                    if (authCtrl.error.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(authCtrl.error.value,
                            style: const TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (v) {
        if (label == 'Email' && !GetUtils.isEmail(v ?? '')) {
          return 'Email inválido';
        } else if (v == null || v.isEmpty) {
          return 'Requerido';
        } else if (label == 'Password' && v.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}