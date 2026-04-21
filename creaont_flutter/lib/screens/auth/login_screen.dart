import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController =
      TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

Future<void> loginUser() async {
  setState(() {
    isLoading = true;
  });

  final result = await AuthService.login(
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  if (result['message'] == 'Login success') {
    final role = result['user']['role'];

    if (role == 'customer') {
      Navigator.pushReplacementNamed(
        context,
        '/customer-dashboard',
      );
    } else if (role == 'designer') {
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
      );
    } else if (role == 'admin') {
      Navigator.pushReplacementNamed(
        context,
        '/admin-dashboard',
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ?? 'Login failed',
        ),
      ),
    );
  }
}

  Widget customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText:
          isPassword ? isPasswordHidden : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF99A1AF),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF99A1AF),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordHidden
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color:
                      const Color(0xFF99A1AF),
                ),
                onPressed: () {
                  setState(() {
                    isPasswordHidden =
                        !isPasswordHidden;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1E1B3A),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 420,
              margin:
                  const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFF9D71FD),
                      borderRadius:
                          BorderRadius.circular(
                              28),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.design_services,
                          size: 72,
                          color: Colors.white,
                        ),
                        SizedBox(height: 18),
                        Text(
                          "Creaont",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Where Design Meets Talent",
                          style: TextStyle(
                            color: Color(
                                0xFFE0E0E0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding:
                        const EdgeInsets.all(
                            24),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFF141127),
                      borderRadius:
                          BorderRadius.circular(
                              24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height: 24),
                        customTextField(
                          controller:
                              emailController,
                          label: 'Email',
                          icon: Icons
                              .email_outlined,
                        ),
                        const SizedBox(
                            height: 18),
                        customTextField(
                          controller:
                              passwordController,
                          label: 'Password',
                          icon: Icons
                              .lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(
                            height: 24),
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : loginUser,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xFF9D71FD),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 16,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height:
                                        20,
                                    width: 20,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors
                                          .white,
                                    ),
                                  )
                                : const Text(
                                    "Sign In"),
                          ),
                        ),
                        const SizedBox(
                            height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/register',
                            );
                          },
                          child: const Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(
                              color: Color(
                                  0xFF9D71FD),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}