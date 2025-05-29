import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = doc.data();

    if (data != null) {
      nameController.text = data['name'] ?? '';
      addressController.text = data['address'] ?? '';
      profileImageUrl = data['profileImage'];
    }
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and address cannot be empty")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'email': user.email,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));
    } catch (e) {
      print("Profile update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: ${e.toString()}")),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking canceled")));
    } catch (e) {
      print("Cancel booking error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error cancelling booking")));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String displayName = nameController.text.trim();
    String initialLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade400,
              backgroundImage:
                  (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!)
                      : null,
              child:
                  (profileImageUrl == null || profileImageUrl!.isEmpty)
                      ? Text(
                        initialLetter,
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text("Save Profile"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "My Bookings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('bookings')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading bookings: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No bookings yet."));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];

                    DateTime date;
                    final dynamic dateData = booking['date'];
                    if (dateData is Timestamp) {
                      date = dateData.toDate();
                    } else if (dateData is String) {
                      date = DateTime.tryParse(dateData) ?? DateTime.now();
                    } else {
                      date = DateTime.now();
                    }

                    final formattedDate =
                        "${date.day}/${date.month}/${date.year}";

                    final dynamic bhkData = booking['bhk'];
                    int bhkValue;
                    if (bhkData is int) {
                      bhkValue = bhkData;
                    } else if (bhkData is String) {
                      bhkValue = int.tryParse(bhkData) ?? 0;
                    } else {
                      bhkValue = 0;
                    }

                    String bhkText;
                    if (bhkValue >= 4) {
                      bhkText = "4+ BHK";
                    } else if (bhkValue > 0) {
                      bhkText = "$bhkValue BHK";
                    } else {
                      bhkText = "N/A";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading:
                            booking['imageUrl'] != null
                                ? Image.network(
                                  booking['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.image_not_supported),
                        title: Text(
                          booking['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "BHK: $bhkText",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Date: $formattedDate",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Price: ₹${booking['price']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _cancelBooking(booking.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
