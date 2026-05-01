import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  String? error;

  bool obscure = true;

  void login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() => error = null);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    bool success = await auth.login(email.text, password.text);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login successful")));

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      setState(() => error = "Invalid credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Student Planner",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                ),
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/forgot-password");
                },
                child: Text("Forgot Password?", style: TextStyle(fontSize: 13)),
              ),
            ),

            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            SizedBox(height: 10),

            auth.isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      child: Text("Login"),
                    ),
                  ),

            SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              child: Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}
