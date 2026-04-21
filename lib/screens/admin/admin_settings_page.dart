import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool notificationsEnabled = true;
  bool autoApproveLabReports = false;
  bool darkModePreview = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      autoApproveLabReports = prefs.getBool('autoApproveLabReports') ?? false;
      darkModePreview = prefs.getBool('darkModePreview') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: darkModePreview ? Colors.blueGrey.shade900 : const Color(0xFFF5F7FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  value: notificationsEnabled,
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive urgent system alerts'),
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                    _saveSetting('notificationsEnabled', value);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Push Notifications ${value ? 'Enabled' : 'Disabled'}')));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: autoApproveLabReports,
                  title: const Text('Auto-approve Lab Reports'),
                  subtitle:
                      const Text('Use with caution for verified workflows'),
                  onChanged: (value) {
                    setState(() => autoApproveLabReports = value);
                    _saveSetting('autoApproveLabReports', value);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-approve Lab Reports ${value ? 'Enabled' : 'Disabled'}')));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: darkModePreview,
                  title: const Text('Dark Mode Preview'),
                  subtitle:
                      const Text('Preview only, app theme integration pending'),
                  onChanged: (value) {
                    setState(() => darkModePreview = value);
                    _saveSetting('darkModePreview', value);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dark Mode Preview ${value ? 'Enabled' : 'Disabled'}')));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.teal),
              title: const Text('Access & Role Policies'),
              subtitle: const Text('Configure role-level restrictions'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Access & Role Policies"),
                    content: const Text("All roles are currently governed by default Firebase rules. Custom policy UI is actively mocked."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.teal),
              title: const Text('Backup & Restore'),
              subtitle:
                  const Text('Prepare backup preferences before backend setup'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("System Backup"),
                    content: const Text("Initiate system backup for all users, settings, and database entries?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup initiated successfully.")));
                        },
                        child: const Text("Start Backup"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
