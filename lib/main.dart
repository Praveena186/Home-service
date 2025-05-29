import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homemur/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RoyalHomeApp());
}

class RoyalHomeApp extends StatelessWidget {
  const RoyalHomeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Home Service',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
