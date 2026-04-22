import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;
  String? error;

  void register() async {
    // 🔥 c. validate input
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      setState(() => error = "All fields are required");
      return;
    }

    if (!email.text.contains("@")) {
      setState(() => error = "Invalid email");
      return;
    }

    if (password.text.length < 6) {
      setState(() => error = "Password must be at least 6 chars");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // 🔥 d. send request
    bool success = await auth.register(email.text, password.text, name.text);

    setState(() => isLoading = false);

    if (success) {
      // 🔥 h. notify UI
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Account created successfully")));

      // 🔥 i. navigate
      Navigator.pop(context);
    } else {
      setState(() => error = "User already exists");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height: 20),

            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            SizedBox(height: 10),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: register, child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
