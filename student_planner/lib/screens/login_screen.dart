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
      backgroundColor: const Color.fromARGB(255, 145, 159, 239),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width < 600
                  ? double.infinity
                  : 500,
            ),

            child: Card(
              elevation: 12,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Text(
                      "Student Planner",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? 32
                            : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.mail_outline),

                        filled: true,
                        fillColor: Colors.grey.shade50,

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.indigo.shade100,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18),

                    TextField(
                      controller: password,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        hintText: "Password",

                        prefixIcon: const Icon(Icons.lock_outline),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.indigo.shade100,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgot-password");
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),

                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    auth.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: ElevatedButton(
                              onPressed: login,

                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),

                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              child: const Text("Login"),
                            ),
                          ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },

                          child: const Text("Create account"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
