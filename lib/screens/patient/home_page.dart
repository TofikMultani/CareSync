import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/patient/appointment_page.dart';
import 'package:healthcare_system/screens/patient/report_page.dart';
import 'package:healthcare_system/screens/patient/prescription_page.dart';
import 'package:healthcare_system/screens/patient/patient_editable_profile_page.dart';
import 'package:healthcare_system/app_drawer.dart';
import 'package:healthcare_system/screens/patient/support_page.dart';
import 'package:healthcare_system/screens/patient/upload_report_page.dart';
import 'package:healthcare_system/screens/patient/my_lab_tests_page.dart';
import 'package:intl/intl.dart';
import 'package:healthcare_system/notification_service.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String patientName = "Loading...";

  String currentHeartRate = "--";
  String currentSystolic = "--";
  String currentDiastolic = "--";
  String currentTemp = "--";
  String currentSteps = "--";
  String currentCalories = "--";
  String currentActiveTime = "--";

  List<Map<String, dynamic>> upcomingAppointments = [];
  Map<String, dynamic>? activePrescription;
  Map<String, dynamic>? recentReport;
  bool isLoading = true;
  bool isReminderSet = false;
  StreamSubscription<QuerySnapshot>? _prescriptionSubscription;
  bool _listenersSetup = false;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    Health().configure();
    
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BODY_TEMPERATURE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.EXERCISE_TIME,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      await Permission.activityRecognition.request();
      bool? hasPermissions = await Health().hasPermissions(types, permissions: permissions);
      if (hasPermissions == false) {
        bool requested = await Health().requestAuthorization(types, permissions: permissions);
        if (!requested) return;
      }

      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 30)); // Search last 30 days for data

      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(types: types, startTime: yesterday, endTime: now);

      HealthDataPoint? latestHR;
      HealthDataPoint? latestSys;
      HealthDataPoint? latestDia;
      HealthDataPoint? latestTemp;

      DateTime todayStart = DateTime(now.year, now.month, now.day);
      int todaySteps = 0;
      double todayCalories = 0.0;
      int todayActiveMinutes = 0;

      print("--- HEALTH DATA FETCH START ---");
      print("Found ${healthData.length} records in the last 30 days.");

      for (var point in healthData) {
        if (point.type == HealthDataType.HEART_RATE) {
          if (latestHR == null || point.dateTo.isAfter(latestHR.dateTo)) latestHR = point;
        } else if (point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
          if (latestSys == null || point.dateTo.isAfter(latestSys.dateTo)) latestSys = point;
        } else if (point.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
          if (latestDia == null || point.dateTo.isAfter(latestDia.dateTo)) latestDia = point;
        } else if (point.type == HealthDataType.BODY_TEMPERATURE) {
          if (latestTemp == null || point.dateTo.isAfter(latestTemp.dateTo)) latestTemp = point;
        }

        if (point.dateFrom.isAfter(todayStart)) {
          if (point.type == HealthDataType.STEPS) {
            todaySteps += (double.tryParse(point.value.toString())?.round() ?? 0);
          } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            todayCalories += (double.tryParse(point.value.toString()) ?? 0.0);
          } else if (point.type == HealthDataType.EXERCISE_TIME) {
            todayActiveMinutes += (double.tryParse(point.value.toString())?.round() ?? 0);
          }
        }
      }

      print("Parsed metrics -> HR: $latestHR, Steps: $todaySteps, Calories: $todayCalories");
      print("--- HEALTH DATA FETCH END ---");

      if (mounted) {
        setState(() {
          if (latestHR != null) currentHeartRate = double.tryParse(latestHR.value.toString())?.round().toString() ?? currentHeartRate;
          if (latestSys != null) currentSystolic = double.tryParse(latestSys.value.toString())?.round().toString() ?? currentSystolic;
          if (latestDia != null) currentDiastolic = double.tryParse(latestDia.value.toString())?.round().toString() ?? currentDiastolic;
          if (latestTemp != null) currentTemp = double.tryParse(latestTemp.value.toString())?.toStringAsFixed(1) ?? currentTemp;
          
          if (todaySteps > 0) currentSteps = todaySteps.toString();
          if (todayCalories > 0) currentCalories = todayCalories.round().toString();
          if (todayActiveMinutes > 0) currentActiveTime = todayActiveMinutes.toString();
        });
      }
    } catch (e) {
      print("Health package error: $e");
    }
  }

  Future<void> _fetchPatientData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            patientName = doc.get('fullName') ?? 'Patient';
          });
        }
        
        if (!_listenersSetup) {
          _setupListeners(user.uid);
          _listenersSetup = true;
        }

        DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        
        // Fetch appointment
        try {
          final apptSnapshot = await FirebaseFirestore.instance.collection('appointments')
              .where('patientId', isEqualTo: user.uid)
              .get();
          if (apptSnapshot.docs.isNotEmpty) {
            var docs = apptSnapshot.docs.toList();
            docs = docs.where((d) {
              final data = d.data();
              if (data['status'] == 'Completed') return false;
              final date = ((data['date'] as Timestamp?) ?? Timestamp.now()).toDate();
              return date.isAfter(today.subtract(const Duration(days: 1)));
            }).toList();
            if (docs.isNotEmpty) {
              docs.sort((a, b) => ((a.data()['date'] as Timestamp?) ?? Timestamp.now()).compareTo((b.data()['date'] as Timestamp?) ?? Timestamp.now()));
              upcomingAppointments = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
            } else {
              upcomingAppointments = [];
            }
          }
        } catch(e) {}

        // Fetch prescription
        try {
          final presSnapshot = await FirebaseFirestore.instance.collection('prescriptions')
              .where('patientId', isEqualTo: user.uid)
              .get();
          if (presSnapshot.docs.isNotEmpty) {
            var docs = presSnapshot.docs.toList();
            docs.sort((a, b) => ((b.data()['createdAt'] as Timestamp?) ?? Timestamp.now()).compareTo((a.data()['createdAt'] as Timestamp?) ?? Timestamp.now()));
            activePrescription = docs.first.data();
          }
        } catch(e) {}

        // Fetch report
        try {
          final repSnapshot = await FirebaseFirestore.instance.collection('reports')
              .where('patientId', isEqualTo: user.uid)
              .get();
          if (repSnapshot.docs.isNotEmpty) {
            var docs = repSnapshot.docs.toList();
            docs.sort((a, b) => ((b.data()['createdAt'] as Timestamp?) ?? Timestamp.now()).compareTo((a.data()['createdAt'] as Timestamp?) ?? Timestamp.now()));
            recentReport = docs.first.data();
          }
        } catch(e) {}

        if (mounted) {
          setState(() => isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
            patientName = 'Guest';
            isLoading = false;
        });
      }
    }
  }

  void _setupListeners(String userId) {
    _prescriptionSubscription?.cancel();
    _prescriptionSubscription = FirebaseFirestore.instance
        .collection('prescriptions')
        .where('patientId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null && data['createdAt'] != null) {
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            if (DateTime.now().difference(createdAt).inSeconds < 30) {
               NotificationService.sendPrescriptionNotification(patientName);
               _fetchPatientData(); // Refresh UI
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _prescriptionSubscription?.cancel();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: backgroundColor,
      appBar: _currentIndex == 0 ? AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: IconButton(
                icon: Icon(Icons.notifications_outlined, color: primaryColor),
                onPressed: () {},
              ),
            ),
          )
        ],
      ) : null,
      body: _currentIndex == 1
          ? const SupportPage(showScaffold: false)
          : _currentIndex == 2
              ? const PatientEditableProfilePage(showScaffold: false)
              : isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: _fetchPatientData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting Header
                              Text(
                                "Hello,",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                patientName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Quick Action Booking Card
                              Container(
                                width: double.infinity,
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
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "How are you feeling\ntoday?",
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: primaryColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const AppointmentPage()),
                                              ).then((_) => _fetchPatientData());
                                            },
                                            child: Text(
                                              "Book Appointment",
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.medical_services, color: Colors.white, size: 48),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Vitals
                              Text(
                                "Your Health Activity",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _vitalCard(icon: Icons.directions_walk, label: "Steps Today", value: currentSteps, unit: "steps", color: Colors.green),
                                  const SizedBox(width: 16),
                                  _vitalCard(icon: Icons.local_fire_department, label: "Calories", value: currentCalories, unit: "kcal", color: Colors.deepOrange),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _vitalCard(icon: Icons.timer, label: "Active Time", value: currentActiveTime, unit: "mins", color: Colors.blueAccent),
                                  const SizedBox(width: 16),
                                  _vitalCard(icon: Icons.favorite, label: "Heart Rate", value: currentHeartRate, unit: "bpm", color: Colors.red),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _vitalCard(icon: Icons.bloodtype, label: "Blood Press.", value: "$currentSystolic/$currentDiastolic", unit: "mmHg", color: Colors.blue),
                                  const SizedBox(width: 16),
                                  _vitalCard(icon: Icons.thermostat, label: "Temp", value: currentTemp, unit: "°F", color: Colors.purple),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Upcoming Appointments
                              _sectionHeader("Upcoming Appointments", () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentPage()));
                              }),
                              const SizedBox(height: 12),
                              if (upcomingAppointments.isEmpty)
                                _emptyStateCard("No upcoming appointments.", Icons.event_available)
                              else
                                ...upcomingAppointments.map((appt) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(Icons.calendar_month, color: primaryColor),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Dr. ${appt['doctorName'] ?? 'Unknown'}",
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${DateFormat('MMM dd, yyyy').format((appt['date'] as Timestamp).toDate())} • ${appt['time']}",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                      ],
                                    ),
                                  );
                                }),

                              const SizedBox(height: 32),

                              // Active Prescriptions
                              _sectionHeader("Active Prescription", () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionPage()));
                              }),
                              const SizedBox(height: 12),
                              if (activePrescription != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Icon(Icons.medication, color: Colors.blue),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  activePrescription!['medicationName'] ?? 'Medication',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: const Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  activePrescription!['dosage'] ?? 'Details',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(isReminderSet ? Icons.alarm_on : Icons.alarm_add, 
                                                color: isReminderSet ? Colors.green : Colors.grey.shade400),
                                            onPressed: () {
                                              if (!isReminderSet) {
                                                NotificationService.scheduleMedicationReminder(
                                                  1, 
                                                  activePrescription!['medicationName'] ?? 'Medication', 
                                                  activePrescription!['dosage'] ?? 'Morning'
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Reminder scheduled for 10 seconds from now (Demo)")),
                                                );
                                                setState(() => isReminderSet = true);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              else
                                _emptyStateCard("No active prescriptions.", Icons.medication_liquid),

                              const SizedBox(height: 32),

                              // Recent Reports
                              _sectionHeader("Recent Reports", () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage())).then((_) => _fetchPatientData());
                              }),
                              const SizedBox(height: 12),
                              if (recentReport != null)
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage())).then((_) => _fetchPatientData());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(Icons.description, color: Colors.orange),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recentReport!['title'] ?? 'Report',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Uploaded ${DateFormat('MMM dd, yyyy').format((recentReport!['createdAt'] as Timestamp).toDate())}",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                _emptyStateCard("No recent reports.", Icons.insert_drive_file),

                              const SizedBox(height: 32),

                              // Quick Actions Grid
                              Text(
                                "Quick Actions",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _quickActionButton(
                                      icon: Icons.upload_file,
                                      label: "Upload Report",
                                      color: primaryColor,
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadReportPage())).then((_) => _fetchPatientData());
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _quickActionButton(
                                      icon: Icons.science,
                                      label: "Lab Tests",
                                      color: Colors.blue,
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLabTestsPage()));
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 12),
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: _onBottomNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: "Support"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vitalCard({required IconData icon, required String label, required String value, required String unit, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(width: 4),
                Text(unit, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            "See All",
            style: GoogleFonts.plusJakartaSans(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyStateCard(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
