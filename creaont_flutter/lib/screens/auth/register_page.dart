import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 🔥 LOGO
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Creaont",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Where Design Meets Talent",
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 30),

                // 🔥 CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create an Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Sign up to get started",
                        style: TextStyle(color: Colors.white54),
                      ),

                      const SizedBox(height: 20),

                      // FULL NAME
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input("Full Name", Icons.person),
                      ),

                      const SizedBox(height: 16),

                      // EMAIL
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input("Email", Icons.email),
                      ),

                      const SizedBox(height: 16),

                      // 🔥 DROPDOWN ROLE (CLEAN STYLE)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E1B3A),
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
                              selectedRole = value!;
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
                        decoration:
                            _input(
                              "Password (min. 8 karakter)",
                              Icons.lock,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isHidden = !isHidden;
                                  });
                                },
                              ),
                            ),
                      ),

                      const SizedBox(height: 20),

                      // BUTTON
                      auth.isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (nameController.text.isEmpty ||
                                      emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Semua field wajib diisi",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (passwordController.text.trim().length <
                                      8) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Password minimal 8 karakter",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  auth.register(
                                    nameController.text.trim(),
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    selectedRole,
                                    context,
                                  );
                                },
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                      const SizedBox(height: 16),

                      // LOGIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white54),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(color: Colors.purpleAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
