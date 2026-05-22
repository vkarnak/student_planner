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
  bool obscure = true;

  String? error;

  void register() async {
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

    bool success = await auth.register(email.text, password.text, name.text);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Account created successfully")));

      Navigator.pop(context);
    } else {
      setState(() => error = "User already exists");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 145, 159, 239),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: Colors.white,
              elevation: 10,
              shadowColor: Colors.black26,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),

              child: Padding(
                padding: const EdgeInsets.all(32),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Align(
                      alignment: Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),

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
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(context, "/login");
                            }
                          },
                        ),
                      ),
                    ),

                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: isMobile ? 30 : 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: name,
                      decoration: InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.person_outline),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FF),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.indigo.shade200),
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
                    const SizedBox(height: 18),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FF),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.indigo.shade200),
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
                    const SizedBox(height: 18),

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
                        fillColor: const Color(0xFFF8F9FF),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide(color: Colors.indigo.shade200),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: const BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: Text(
                          error!,

                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: isMobile ? 52 : 56,

                            child: ElevatedButton(
                              onPressed: register,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B5BD7),

                                foregroundColor: Colors.white,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),

                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              child: const Text("Register"),
                            ),
                          ),

                    const SizedBox(height: 18),
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
