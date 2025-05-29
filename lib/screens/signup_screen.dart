import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_textfield.dart';
import '../utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

Future<void> signup() async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fill all fields")),
    );
    return;
  }

  try {

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = FirebaseAuth.instance.currentUser;


    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'email': email,
      'address': '',
      'profileImage': '',
       'role': 'user',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup successful")),
    );


    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signup failed: $e")),
    );
  }
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
              Text("Create Account", style: royalTitle),
              const SizedBox(height: 30),
              CustomTextField(controller: nameController, label: "Name"),
              const SizedBox(height: 10),
              CustomTextField(controller: emailController, label: "Email"),
              const SizedBox(height: 10),
              CustomTextField(controller: passwordController, label: "Password", obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signup,
                style: royalButton,
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
