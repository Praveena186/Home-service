import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewBookingsScreen extends StatelessWidget {
  const ViewBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Bookings"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookings')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final title = booking['title'];
              final bhk = booking['bhk'];
              final price = booking['price'];
              final date = booking['date'];
              final imageUrl = booking['imageUrl'];
              final userName = booking['userName'] ?? 'Unknown User';

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(title),
                  subtitle: Text(
                    "Booked by: $userName\nBHK: $bhk\nDate: ${date.split('T')[0]}\n₹ $price",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
