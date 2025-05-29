import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homemur/screens/login_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/home_screen.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void registerUser(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': 'user',
      });

      Fluttertoast.showToast(msg: "Account created successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void loginUser(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      String role = userDoc['role'];

      Fluttertoast.showToast(msg: "Login Successful!");

      if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Fluttertoast.showToast(msg: "Logged out successfully!");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
