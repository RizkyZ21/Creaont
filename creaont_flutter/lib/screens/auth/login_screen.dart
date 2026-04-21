import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final api = ApiService();
    final result = await api.login(
      emailController.text,
      passwordController.text,
    );

    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController),
            TextField(controller: passwordController),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}