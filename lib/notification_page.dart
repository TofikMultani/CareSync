import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [
    {"title": "Appointment Confirmed", "subtitle": "Your appointment is confirmed for tomorrow.", "read": false},
    {"title": "Prescription Uploaded", "subtitle": "Doctor uploaded your prescription.", "read": false},
    {"title": "System Alert", "subtitle": "Welcome to CareSync Healthcare.", "read": true},
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All notifications marked as read.")));
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All notifications cleared.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Notifications"), 
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: _notifications.isEmpty ? null : _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Clear all",
            onPressed: _notifications.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text("No notifications at this time.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final isRead = notif['read'] == true;
                return Card(
                  elevation: isRead ? 0 : 2,
                  color: isRead ? Colors.transparent : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isRead ? BorderSide(color: Colors.grey.shade300) : BorderSide.none),
                  child: ListTile(
                    leading: Icon(
                      isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: isRead ? Colors.grey : Colors.teal,
                    ),
                    title: Text(notif['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(notif['subtitle']),
                    onTap: () {
                      if (!isRead) {
                        setState(() {
                          _notifications[index]['read'] = true;
                        });
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
