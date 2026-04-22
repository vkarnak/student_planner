import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final email = TextEditingController();

  String? error;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    provider.loadProfile().then((_) {
      name.text = provider.user?['name'] ?? "";
      email.text = provider.user?['email'] ?? "";
    });
  }

  void save() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    // 🔥 d. validate
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),

      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(labelText: "Name"),
                  ),

                  TextField(
                    controller: email,
                    decoration: InputDecoration(labelText: "Email"),
                  ),

                  if (error != null)
                    Text(error!, style: TextStyle(color: Colors.red)),

                  SizedBox(height: 20),

                  ElevatedButton(onPressed: save, child: Text("Save")),
                ],
              ),
            ),
    );
  }
}
