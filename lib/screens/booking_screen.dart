import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homemur/screens/booking_confirmation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String title;
  final String imageUrl;
  final int price;

  const BookingScreen({
    super.key,
    required this.serviceId,
    required this.title,
    required this.imageUrl,
    required this.price,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedBHK = '1 BHK';
  DateTime selectedDate = DateTime.now();
  final TextEditingController addressController = TextEditingController();

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void bookService() async {
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'serviceId': widget.serviceId,
        'serviceTitle': widget.title,
        'title': widget.title,
        'imageUrl': widget.imageUrl,
        'price': widget.price,
        'bhk': selectedBHK,
        'date': selectedDate.toIso8601String(),
        'createdAt': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'No Name',
        'userEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'noemail@example.com',
        'address': addressController.text.trim(),
      });

      Fluttertoast.showToast(msg: "Booking Confirmed!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingConfirmationScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Booking failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Service"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.network(widget.imageUrl, height: 150)),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (user != null)
                Text(
                  "Name: ${user.displayName ?? 'No Name'}",
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),

              TextFormField(
                controller: addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Enter your address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedBHK,
                items:
                    ['1 BHK', '2 BHK', '3 BHK', '4 BHK']
                        .map(
                          (bhk) =>
                              DropdownMenuItem(value: bhk, child: Text(bhk)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedBHK = value);
                },
                decoration: const InputDecoration(
                  labelText: "Select BHK",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _pickDate(context),
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: bookService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Book Now", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
