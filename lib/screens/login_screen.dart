import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    AuthService().loginUser(email, password, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: royalBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Royal Home Service", style: royalTitle),
              const SizedBox(height: 30),
              CustomTextField(controller: emailController, label: "Email"),
              const SizedBox(height: 10),
              CustomTextField(controller: passwordController, label: "Password", obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: royalButton,
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                },
                child: const Text("Don't have an account? Sign Up"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
