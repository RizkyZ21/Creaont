import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isHidden = true;
  String selectedRole = "customer";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.dark1, AppColors.dark2, AppColors.dark3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Creaont",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Register",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),

                  const SizedBox(height: 30),

                  // NAME
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Nama", Icons.person),
                  ),

                  const SizedBox(height: 16),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Email", Icons.email),
                  ),

                  const SizedBox(height: 16),

                  // ROLE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedRole,
                      dropdownColor: Colors.black,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: "customer",
                          child: Text("Customer"),
                        ),
                        DropdownMenuItem(
                          value: "designer",
                          child: Text("Designer"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!.trim().toLowerCase(); // 🔥 FIX
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: isHidden,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          isHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isHidden = !isHidden;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BUTTON
                  auth.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // 🔥 VALIDASI
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Semua field wajib diisi"),
                                  ),
                                );
                                return;
                              }

                              print("ROLE DIKIRIM: $selectedRole"); // DEBUG

                              auth.register(
                                nameController.text.trim(),
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                selectedRole.trim().toLowerCase(), // 🔥 FIX
                                context,
                              );
                            },
                            child: const Text("Register"),
                          ),
                        ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Kembali ke Login",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 BIAR CLEAN
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
