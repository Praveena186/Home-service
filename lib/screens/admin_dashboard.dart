import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homemur/screens/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final titleController = TextEditingController();
  final imageUrlController = TextEditingController();
  final priceController = TextEditingController();

  String _formatDate(dynamic dateField) {
    if (dateField is Timestamp) {
      return dateField.toDate().toString().split(' ')[0];
    } else if (dateField is String) {
      final parsed = DateTime.tryParse(dateField);
      return parsed != null ? parsed.toString().split(' ')[0] : 'N/A';
    }
    return 'N/A';
  }

  void openAddDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      titleController.text = doc['title'];
      imageUrlController.text = doc['imageUrl'];
      priceController.text = doc['price'].toString();
    } else {
      titleController.clear();
      imageUrlController.clear();
      priceController.clear();
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(doc == null ? "Add Service" : "Edit Service"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: "Image URL"),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      imageUrlController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final data = {
                    'title': titleController.text.trim(),
                    'imageUrl': imageUrlController.text.trim(),
                    'price': int.tryParse(priceController.text.trim()) ?? 0,
                  };

                  if (doc == null) {
                    FirebaseFirestore.instance.collection('services').add(data);
                  } else {
                    FirebaseFirestore.instance
                        .collection('services')
                        .doc(doc.id)
                        .update(data);
                  }

                  Navigator.pop(context);
                },

                child: Text(doc == null ? "Add" : "Update"),
              ),
            ],
          ),
    );
  }

  void deleteService(String docId) {
    FirebaseFirestore.instance.collection('services').doc(docId).delete();
  }

  void showAllBookingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("All Bookings"),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('bookings')
                        .orderBy('date', descending: true)
                        .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bookings = snapshot.data!.docs;

                  if (bookings.isEmpty) {
                    return const Text("No bookings found.");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                            "Service: ${booking['serviceTitle'] ?? 'No Title'}",
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "User: ${(booking.data() as Map<String, dynamic>).containsKey('userEmail') ? booking['userEmail'] : 'No Email'}",
                              ),
                              Text("BHK: ${booking['bhk'] ?? 'N/A'}"),
                              Text(
                                "Date: ${booking['date']?.toString().split('T')[0] ?? 'N/A'}",
                              ),
                              Text(
                                "Address: ${(booking.data() as Map<String, dynamic>).containsKey('address') ? booking['address'] : 'No address'}",
                              ),
                              Text("Amount: ₹${booking['price'] ?? 0}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  void showUserListDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select User"),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('bookings')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bookings = snapshot.data!.docs;
                  final Set<String> userEmailSet = {};

                  for (var doc in bookings) {
                    try {
                      final email =
                          (doc.data() as Map<String, dynamic>)['userEmail'];
                      if (email != null && email.toString().isNotEmpty) {
                        userEmailSet.add(email.toString());
                      }
                    } catch (e) {
                      print("Skipping invalid booking: $e");
                    }
                  }

                  final userEmails = userEmailSet.toList();

                  if (userEmails.isEmpty) {
                    return const Text("No user bookings found.");
                  }

                  return ListView.builder(
                    itemCount: userEmails.length,
                    itemBuilder: (context, index) {
                      final userEmail = userEmails[index];
                      return ListTile(
                        title: Text(userEmail),
                        onTap: () {
                          Navigator.pop(context);
                          showBookingsForUser(userEmail);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  void showBookingsForUser(String userEmail) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Bookings for $userEmail"),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('bookings')
                        .where('userEmail', isEqualTo: userEmail)
                        .orderBy('date', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No bookings found.");
                  }

                  final bookings = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return ListTile(
                        title: Text(
                          "Service: ${booking['serviceTitle'] ?? 'No Title'}",
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${_formatDate(booking['date'])}"),
                            Text("BHK: ${booking['bhk'] ?? 'N/A'}"),
                            Text(
                              "Address: ${booking['address'] ?? 'No address'}",
                            ),
                            Text("Amount: ₹${booking['price'] ?? 'N/A'}"),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: "View All Bookings",
            onPressed: showAllBookingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: "View Bookings by User",
            onPressed: showUserListDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final doc = services[index];
              return ListTile(
                leading: Image.network(
                  doc['imageUrl'],
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 60),
                ),
                title: Text(doc['title']),
                subtitle: Text("₹ ${doc['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => openAddDialog(doc: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteService(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
