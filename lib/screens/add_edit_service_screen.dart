import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddEditServiceScreen extends StatefulWidget {
  final String? serviceId;
  final Map<String, dynamic>? existingData;

  const AddEditServiceScreen({super.key, this.serviceId, this.existingData});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();

  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _titleController.text = widget.existingData!['title'];
      _imageController.text = widget.existingData!['image'];
      _descController.text = widget.existingData!['description'];
    }
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'title': _titleController.text,
        'image': _imageController.text,
        'description': _descController.text,
      };

      if (widget.serviceId == null) {
        firestoreService.addService(data);
      } else {
        firestoreService.updateService(widget.serviceId!, data);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.serviceId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Service" : "Add Service"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Service Title"),
                validator:
                    (value) => value!.isEmpty ? "Please enter title" : null,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
                validator:
                    (value) => value!.isEmpty ? "Please enter image URL" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator:
                    (value) =>
                        value!.isEmpty ? "Please enter description" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSubmit,
                child: Text(isEdit ? "Update Service" : "Add Service"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
