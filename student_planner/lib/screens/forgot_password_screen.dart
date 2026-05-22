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
  bool obscure = true;

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
      backgroundColor: const Color.fromARGB(255, 145, 159, 239),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),

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
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.mail_outline),
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
                      controller: newPassword,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),

                          onPressed: () => setState(() => obscure = !obscure),
                        ),
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

                    const SizedBox(height: 14),

                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: ElevatedButton(
                              onPressed: reset,

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

                              child: const Text("Reset Password"),
                            ),
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
