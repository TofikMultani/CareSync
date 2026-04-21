import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientEditableProfilePage extends StatefulWidget {
  const PatientEditableProfilePage({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<PatientEditableProfilePage> createState() =>
      _PatientEditableProfilePageState();
}

class _PatientEditableProfilePageState
    extends State<PatientEditableProfilePage> {
  bool isEditing = false;
  bool _isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController(text: "None");
  final TextEditingController chronicDiseaseController = TextEditingController(text: "None");

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            nameController.text = doc.get('fullName') ?? '';
            emailController.text = doc.get('email') ?? '';
            phoneController.text = doc.get('phone') ?? '';
            ageController.text = doc.get('age') ?? '';
            genderController.text = doc.get('gender') ?? '';
            bloodGroupController.text = doc.get('bloodGroup') ?? '';
            heightController.text = doc.get('height') ?? '';
            weightController.text = doc.get('weight') ?? '';
            addressController.text = doc.get('address') ?? '';
            cityController.text = doc.get('city') ?? '';
            allergiesController.text = doc.get('allergies') ?? 'None';
            chronicDiseaseController.text = doc.get('chronicDisease') ?? 'None';
            _isLoading = false;
          });
        } else {
            if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
         if (mounted) setState(() => _isLoading = false);
      }
    } else {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'age': ageController.text.trim(),
          'gender': genderController.text.trim(),
          'bloodGroup': bloodGroupController.text.trim(),
          'height': heightController.text.trim(),
          'weight': weightController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'allergies': allergiesController.text.trim(),
          'chronicDisease': chronicDiseaseController.text.trim(),
        });
        if (mounted) {
          setState(() {
            isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating profile: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    final profileBody = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Edit Button
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
                label: Text(isEditing ? "Cancel" : "Edit Profile"),
              ),
            ),

          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nameController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailController.text,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section: Basic Information
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Basic Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          _buildField("Full Name", nameController, Icons.person, isEditing),
          _buildField(
              "Email (Cannot Change)", emailController, Icons.email, false,
              isLocked: true),
          _buildField("Phone Number", phoneController, Icons.phone, isEditing),
          _buildField("Age", ageController, Icons.cake, isEditing,
              isNumber: true),

          const SizedBox(height: 16),

          // Section: Health Information
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Health Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          _buildField("Gender", genderController, Icons.wc, isEditing),
          _buildField(
              "Blood Group", bloodGroupController, Icons.bloodtype, isEditing),
          _buildField("Height (cm)", heightController, Icons.height, isEditing,
              isNumber: true),
          _buildField(
              "Weight (kg)", weightController, Icons.monitor_weight, isEditing,
              isNumber: true),

          const SizedBox(height: 16),

          // Section: Address & Location
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Address & Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          _buildField(
              "Address", addressController, Icons.location_on, isEditing,
              maxLines: 2),
          _buildField("City", cityController, Icons.location_city, isEditing),

          const SizedBox(height: 16),

          // Section: Medical History
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Medical History",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          _buildField(
              "Allergies", allergiesController, Icons.warning, isEditing,
              maxLines: 2),
          _buildField("Chronic Diseases", chronicDiseaseController,
              Icons.favorite, isEditing,
              maxLines: 2),

          const SizedBox(height: 24),

          // Save Button
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
                onPressed: _saveProfileData,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
              ),
            ),

          const SizedBox(height: 20),
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
    String label,
    TextEditingController controller,
    IconData icon,
    bool isEditable, {
    bool isLocked = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(label),
        subtitle: isEditable && !isLocked
            ? TextField(
                controller: controller,
                keyboardType:
                    isNumber ? TextInputType.number : TextInputType.text,
                maxLines: maxLines,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Text(
                controller.text,
                style: TextStyle(
                  color: isLocked ? Colors.grey : Colors.black87,
                ),
              ),
        trailing: isLocked
            ? const Tooltip(
                message: "Email cannot be changed",
                child: Icon(Icons.lock, color: Colors.orange, size: 20),
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    genderController.dispose();
    bloodGroupController.dispose();
    heightController.dispose();
    weightController.dispose();
    addressController.dispose();
    cityController.dispose();
    allergiesController.dispose();
    chronicDiseaseController.dispose();
    super.dispose();
  }
}
