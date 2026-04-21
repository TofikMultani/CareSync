import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaboratoryManageTestsPage extends StatefulWidget {
  const LaboratoryManageTestsPage({super.key});

  @override
  State<LaboratoryManageTestsPage> createState() => _LaboratoryManageTestsPageState();
}

class _LaboratoryManageTestsPageState extends State<LaboratoryManageTestsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _addOrEditTest({String? id, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      _nameController.text = existingData['testName'] ?? '';
      _priceController.text = existingData['price']?.toString() ?? '';
      _descController.text = existingData['description'] ?? '';
    } else {
      _nameController.clear();
      _priceController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(id == null ? "Add Lab Test" : "Edit Lab Test"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Test Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price (\$)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (_nameController.text.isEmpty) return;
              
              final data = {
                'testName': _nameController.text.trim(),
                'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
                'description': _descController.text.trim(),
              };

              if (id == null) {
                data['createdAt'] = FieldValue.serverTimestamp();
                await FirebaseFirestore.instance.collection('laboratory_tests').add(data);
              } else {
                await FirebaseFirestore.instance.collection('laboratory_tests').doc(id).update(data);
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteTest(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Test"),
        content: const Text("Are you sure you want to remove this test from the catalog?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('laboratory_tests').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Lab Test Catalog"),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditTest(),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text("Add Test"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('laboratory_tests').orderBy('testName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No laboratory tests found in catalog."));

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.teal.withOpacity(0.15),
                    child: const Icon(Icons.biotech, color: Colors.teal),
                  ),
                  title: Text(data['testName'] ?? 'Unknown Test', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data['description'] ?? 'No description provided.', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("\$${data['price']?.toString() ?? '0'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _addOrEditTest(id: doc.id, existingData: data),
                            child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _deleteTest(doc.id),
                            child: const Icon(Icons.delete, color: Colors.red, size: 20),
                          ),
                        ],
                      ),
                    ],
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
