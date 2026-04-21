import 'package:flutter/material.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool isEditing = false;

  final TextEditingController nameController =
      TextEditingController(text: "Patient Name");
  final TextEditingController emailController =
      TextEditingController(text: "patient@email.com");
  final TextEditingController phoneController =
      TextEditingController(text: "+91 98765 43210");
  final TextEditingController ageController = TextEditingController(text: "22");
  final TextEditingController addressController =
      TextEditingController(text: "Ahmedabad, Gujarat");

  @override
  Widget build(BuildContext context) {
    final profileBody = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!widget.showScaffold)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                icon: Icon(isEditing ? Icons.close : Icons.edit),
                label: Text(isEditing ? "Cancel" : "Edit"),
              ),
            ),
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  "Patient Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildField("Name", nameController, Icons.person),
          _buildField("Email", emailController, Icons.email),
          _buildField("Phone", phoneController, Icons.phone),
          _buildField("Age", ageController, Icons.cake),
          _buildField("Address", addressController, Icons.location_on),

          const SizedBox(height: 20),

          if (isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    isEditing = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Profile updated successfully")),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
              ),
            ),
        ],
      ),
    );

    if (!widget.showScaffold) {
      return Container(
        color: const Color(0xFFF5F7FA),
        child: profileBody,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: profileBody,
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(label),
        subtitle: isEditing
            ? TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              )
            : Text(controller.text),
      ),
    );
  }
}
