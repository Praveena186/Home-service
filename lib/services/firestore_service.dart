import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference servicesCollection =
      FirebaseFirestore.instance.collection('services');

  Future<void> addService(Map<String, dynamic> data) async {
    await servicesCollection.add(data);
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await servicesCollection.doc(id).update(data);
  }

  Future<void> deleteService(String id) async {
    await servicesCollection.doc(id).delete();
  }

  Stream<QuerySnapshot> getServices() {
    return servicesCollection.snapshots();
  }
}
