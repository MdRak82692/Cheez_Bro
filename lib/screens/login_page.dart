import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/admin/admin_dashboard.dart'; // Admin Dashboard Screen
import '../screens/staff/staff_order_list.dart'; // Staff Order List Screen
import '../utils/show_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showCustomDialog(
          context, 'Error', 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check Firebase Authentication
      UserCredential? adminCredential;
      try {
        adminCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (_) {
        adminCredential = null;
      }

      if (adminCredential != null) {
        // If email/password exists in Firebase Auth, it's Admin
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
        return;
      }

      // Check Firestore Admin Collection
      final QuerySnapshot<Map<String, dynamic>> adminQuery = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminData = adminQuery.docs.first.data();
        if (adminData['password'] == password) {
          // If email/password exists in Admin Collection, it's Admin
          Navigator.pushReplacement(
            context, // ignore: use_build_context_synchronously
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
          return;
        }
      }

      // Check Firestore Users Collection
      final QuerySnapshot<Map<String, dynamic>> userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        if (userData['password'] == password) {
          // Update the lastSignedIn timestamp
          await userQuery.docs.first.reference.update({
            'lastSignedIn': FieldValue.serverTimestamp(),
          });

          // If email/password exists in Users Collection, it's Staff
          Navigator.pushReplacement(
            context, // ignore: use_build_context_synchronously
            MaterialPageRoute(builder: (context) => const StaffOrderList()),
          );
          return;
        }
      }

      // If none of the above, credentials are invalid
      throw FirebaseAuthException(
        code: 'invalid-credentials',
        message: 'Invalid email or password.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-credentials':
          errorMessage = 'Invalid email or password.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
          break;
      }
      // ignore: use_build_context_synchronously
      showCustomDialog(context, 'Login Failed', errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with circular shapes
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Login Form
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Merriweather',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign in to continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Merriweather',
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Email",
                          hintStyle: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Merriweather',
                            color: Colors.black,
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'PlayfairDisplay',
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Merriweather',
                            color: Colors.black,
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'PlayfairDisplay',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 16),
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontFamily: 'Merriweather',
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
