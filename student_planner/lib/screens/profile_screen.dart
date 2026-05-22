import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final email = TextEditingController();

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();

  String? error;

  bool obscureOld = true;
  bool obscureNew = true;

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

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color(0xFFF8F9FF),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.indigo.shade200),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }

  ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4B5BD7),
      foregroundColor: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget buildSection({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFF),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.black12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: child,
    );
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
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));
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
        title: const Text("Logout"),

        content: const Text("Are you sure?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),

            child: const Text("Logout"),
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

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 159, 239),

      body: SafeArea(
        child: profile.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),

                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),

                    child: Column(
                      children: [
                        buildSection(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,

                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),

                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(14),

                                    border: Border.all(color: Colors.black12),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),

                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 18,
                                      color: Colors.black87,
                                    ),

                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),

                              CircleAvatar(
                                radius: 42,

                                backgroundColor: const Color(0xFFEEF2FF),

                                child: const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: Color(0xFF4B5BD7),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                "Profile",

                                style: TextStyle(
                                  fontSize: isMobile ? 30 : 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900,
                                ),
                              ),

                              const SizedBox(height: 28),

                              TextField(
                                controller: name,

                                decoration: fieldDecoration(
                                  hint: "Name",
                                  icon: Icons.person_outline,
                                ),
                              ),

                              const SizedBox(height: 18),

                              TextField(
                                controller: email,

                                decoration: fieldDecoration(
                                  hint: "Email",
                                  icon: Icons.mail_outline,
                                ),
                              ),

                              if (error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),

                                  child: Text(
                                    error!,

                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),

                              const SizedBox(height: 22),

                              SizedBox(
                                width: double.infinity,
                                height: isMobile ? 52 : 56,

                                child: ElevatedButton(
                                  onPressed: save,

                                  style: primaryButtonStyle(),

                                  child: const Text("Save"),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        buildSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Notifications",

                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,

                                title: const Text("Daily plan"),

                                subtitle: const Text("Morning schedule"),

                                value: settings.settings.dailyPlan,

                                onChanged: settings.toggleDailyPlan,
                              ),

                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,

                                title: const Text("Deadlines"),

                                subtitle: const Text("Remind before deadline"),

                                value: settings.settings.deadlines,

                                onChanged: settings.toggleDeadlines,
                              ),

                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,

                                title: const Text("Suggestions"),

                                subtitle: const Text("Planning suggestions"),

                                value: settings.settings.aiSuggestions,

                                onChanged: settings.toggleAi,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        buildSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Change Password",

                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 18),

                              TextField(
                                controller: oldPassword,

                                obscureText: obscureOld,

                                decoration: fieldDecoration(
                                  hint: "Old password",
                                  icon: Icons.lock_outline,

                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureOld
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        obscureOld = !obscureOld;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              TextField(
                                controller: newPassword,

                                obscureText: obscureNew,

                                decoration: fieldDecoration(
                                  hint: "New password",
                                  icon: Icons.lock_outline,

                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureNew
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        obscureNew = !obscureNew;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              SizedBox(
                                width: double.infinity,
                                height: isMobile ? 52 : 56,

                                child: ElevatedButton(
                                  onPressed: changePassword,

                                  style: primaryButtonStyle(),

                                  child: const Text("Change Password"),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 52 : 56,

                          child: ElevatedButton.icon(
                            onPressed: logout,

                            icon: const Icon(Icons.logout),

                            label: const Text("Logout"),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,

                              foregroundColor: Colors.red,

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
