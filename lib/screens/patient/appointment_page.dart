import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedDoctor = "Dr. Sharma";
  DateTime selectedDate = DateTime.now();
  String selectedTime = "10:00 AM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment"), backgroundColor: Colors.teal),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              child: DropdownButtonFormField<String>(
                value: selectedDoctor,
                items: const [
                  DropdownMenuItem(value: "Dr. Sharma", child: Text("Dr. Sharma (Physician)")),
                  DropdownMenuItem(value: "Dr. Patel", child: Text("Dr. Patel (Cardiologist)")),
                  DropdownMenuItem(value: "Dr. Mehta", child: Text("Dr. Mehta (Orthopedic)")),
                ],
                onChanged: (val) => setState(() => selectedDoctor = val!),
                decoration: const InputDecoration(labelText: "Select Doctor"),
              ),
            ),
            _card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: const Text("Select Date"),
                subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    initialDate: selectedDate,
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ),
            _card(
              child: DropdownButtonFormField<String>(
                value: selectedTime,
                items: const [
                  DropdownMenuItem(value: "10:00 AM", child: Text("10:00 AM")),
                  DropdownMenuItem(value: "12:00 PM", child: Text("12:00 PM")),
                  DropdownMenuItem(value: "03:00 PM", child: Text("03:00 PM")),
                ],
                onChanged: (val) => setState(() => selectedTime = val!),
                decoration: const InputDecoration(labelText: "Select Time Slot"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Appointment booked successfully!")),
                  );
                },
                child: const Text("Confirm Appointment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
