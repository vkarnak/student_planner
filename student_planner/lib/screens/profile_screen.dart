import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();

  String? error;

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileProvider>();
    final settings = context.read<SettingsProvider>();

    profile.loadProfile().then((_) {
      name.text = profile.user?['name'] ?? "";
      email.text = profile.user?['email'] ?? "";
    });

    settings.load();
  }

  void save() async {
    final provider = context.read<ProfileProvider>();

    if (name.text.isEmpty || email.text.isEmpty) {
      setState(() => error = "Fill all fields");
      return;
    }

    final success = await provider.updateProfile(name.text, email.text);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated")));
    }
  }

  void changePassword() async {
    final success = await ApiService.changePassword(
      oldPassword.text,
      newPassword.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Password updated" : "Error")),
    );
  }

  Future<void> logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),

      body: profile.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: name,
                            decoration: InputDecoration(labelText: "Name"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: email,
                            decoration: InputDecoration(labelText: "Email"),
                          ),

                          if (error != null)
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                error!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                          SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: save,
                              child: Text("Save"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Notifications",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        SwitchListTile(
                          title: Text("Daily plan"),
                          subtitle: Text("Morning schedule"),
                          value: settings.settings.dailyPlan,
                          onChanged: settings.toggleDailyPlan,
                        ),

                        SwitchListTile(
                          title: Text("Deadlines"),
                          subtitle: Text("Remind before deadline"),
                          value: settings.settings.deadlines,
                          onChanged: settings.toggleDeadlines,
                        ),

                        SwitchListTile(
                          title: Text("AI suggestions"),
                          subtitle: Text("Smart time suggestions"),
                          value: settings.settings.aiSuggestions,
                          onChanged: settings.toggleAi,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: oldPassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Old password",
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: newPassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "New password",
                            ),
                          ),

                          SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: changePassword,
                              child: Text("Change password"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Card(
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text("Logout"),
                      onTap: logout,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
