import 'package:flutter/material.dart';
import 'package:student_planner/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  final newPassword = TextEditingController();

  String? error;
  bool loading = false;

  void reset() async {
    if (email.text.isEmpty || newPassword.text.isEmpty) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() => loading = true);

    final success = await ApiService.resetPassword(
      email.text,
      newPassword.text,
    );

    setState(() => loading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => error = "Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: newPassword,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            SizedBox(height: 20),

            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: reset, child: Text("Reset")),
          ],
        ),
      ),
    );
  }
}
