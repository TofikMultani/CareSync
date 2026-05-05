import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';

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
  bool _isUploadingImage = false;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

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
  
  String? profileImageUrl;

  Timer? _debounce;

  void _onFieldChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      _saveProfileData(silent: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      File file = File(image.path);
      String fileName = 'profile_images/${user.uid}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(file);
      String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        profileImageUrl = downloadUrl;
      });

      await _saveProfileData(silent: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile image updated!", style: GoogleFonts.plusJakartaSans()),
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading image: $e", style: GoogleFonts.plusJakartaSans()),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _fetchProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>?;
          setState(() {
            nameController.text = data?['fullName'] ?? '';
            emailController.text = data?['email'] ?? '';
            phoneController.text = data?['phone'] ?? '';
            ageController.text = data?['age'] ?? '';
            genderController.text = data?['gender'] ?? '';
            bloodGroupController.text = data?['bloodGroup'] ?? '';
            heightController.text = data?['height'] ?? '';
            weightController.text = data?['weight'] ?? '';
            addressController.text = data?['address'] ?? '';
            cityController.text = data?['city'] ?? '';
            allergiesController.text = data?['allergies'] ?? 'None';
            chronicDiseaseController.text = data?['chronicDisease'] ?? 'None';
            profileImageUrl = data?['profileImageUrl'] ?? 'assets/images/patient_profile.png';
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

  Future<void> _saveProfileData({bool silent = false}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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
          'profileImageUrl': profileImageUrl ?? 'assets/images/patient_profile.png',
        }, SetOptions(merge: true));
        if (mounted && !silent) {
          setState(() {
            isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile updated successfully!", style: GoogleFonts.plusJakartaSans()),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted && !silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating profile: $e", style: GoogleFonts.plusJakartaSans()),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final profileBody = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Edit Button
          if (!widget.showScaffold)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: isEditing ? Colors.red.shade400 : primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                icon: Icon(isEditing ? Icons.close_rounded : Icons.edit_rounded, size: 18),
                label: Text(
                  isEditing ? "Cancel" : "Edit Profile", 
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage: (profileImageUrl != null && profileImageUrl!.startsWith('http'))
                            ? NetworkImage(profileImageUrl!) as ImageProvider
                            : AssetImage(profileImageUrl ?? 'assets/images/patient_profile.png'),
                        child: _isUploadingImage 
                            ? CircularProgressIndicator(color: primaryColor) 
                            : null,
                      ),
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Profile",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nameController.text.isNotEmpty ? nameController.text : "Update Name",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailController.text,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section: Basic Information
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Basic Information",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 16),

          _buildField("Full Name", nameController, Icons.person_rounded, isEditing),
          _buildField("Email (Cannot Change)", emailController, Icons.email_rounded, false, isLocked: true),
          _buildField("Phone Number", phoneController, Icons.phone_rounded, isEditing),
          _buildField("Age", ageController, Icons.cake_rounded, isEditing, isNumber: true),

          const SizedBox(height: 24),

          // Section: Health Information
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Health Information",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 16),

          _buildField("Gender", genderController, Icons.wc_rounded, isEditing),
          _buildField("Blood Group", bloodGroupController, Icons.bloodtype_rounded, isEditing),
          _buildField("Height (cm)", heightController, Icons.height_rounded, isEditing, isNumber: true),
          _buildField("Weight (kg)", weightController, Icons.monitor_weight_rounded, isEditing, isNumber: true),

          const SizedBox(height: 24),

          // Section: Address & Location
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Address & Location",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 16),

          _buildField("Address", addressController, Icons.location_on_rounded, isEditing, maxLines: 2),
          _buildField("City", cityController, Icons.location_city_rounded, isEditing),

          const SizedBox(height: 24),

          // Section: Medical History
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Medical History",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 16),

          _buildField("Allergies", allergiesController, Icons.warning_rounded, isEditing, maxLines: 2),
          _buildField("Chronic Diseases", chronicDiseaseController, Icons.favorite_rounded, isEditing, maxLines: 2),

          const SizedBox(height: 40),

          // Save Button
          if (isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A), // Slate 900
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => _saveProfileData(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text("Save Changes", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );

    if (!widget.showScaffold) {
      return SafeArea(
        child: Container(
          color: backgroundColor,
          child: profileBody,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("My Profile", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close_rounded : Icons.edit_rounded, color: isEditing ? Colors.red.shade400 : primaryColor),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEditable ? primaryColor.withOpacity(0.5) : Colors.grey.shade200, width: isEditable ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
        subtitle: isEditable && !isLocked
            ? TextField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                maxLines: maxLines,
                onChanged: _onFieldChanged,
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  controller.text.isEmpty ? "Not set" : controller.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isLocked ? Colors.grey.shade600 : const Color(0xFF0F172A),
                  ),
                ),
              ),
        trailing: isLocked
            ? Tooltip(
                message: "Email cannot be changed",
                child: Icon(Icons.lock_rounded, color: Colors.orange.shade400, size: 20),
              )
            : (isEditable ? Icon(Icons.edit_rounded, color: primaryColor, size: 16) : null),
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
