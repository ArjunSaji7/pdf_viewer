import 'package:flutter/material.dart';
import 'package:pdf_viewer/screens/screen_login.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({super.key});

  @override
  State<ScreenSignUp> createState() => _ScreenSignUpState();
}

class _ScreenSignUpState extends State<ScreenSignUp> {
  bool _obscureText = true;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Function to validate email format
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Function to register the user using Firebase Authentication.
  Future<void> _signupUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Validate email format
      if (!_validateEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please enter a valid email address.'),
          ),
        );
        return;
      }

      // Create a new user with the provided email and password.
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally, update the user's display name with the provided name.
      await userCredential.user!
          .updateDisplayName(_nameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Registration Successful')));
      // Registration successful. Navigate to LoginScreen (or HomeScreen if desired)
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ScreenLogin()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else {
        message = 'Error: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.brown, content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.brown,
            content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Create Account',
                style: TextStyle(
                    fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 24),
              ),
              const SizedBox(
                height: 40,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Name',
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        hintText: 'Full Name',
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        hintText: 'example@gmail.com',
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey)),
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 8.0, right: 8, top: 4),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: '***********',
                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Password confirmation field
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm Password',
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey)),
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 8.0, right: 8, top: 4),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: '***********',
                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    if (_nameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty &&
                        _confirmPasswordController.text.isNotEmpty) {
                      if (!_validateEmail(_emailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Please enter a valid email address.')));
                      } else if (_passwordController.text.trim() !=
                          _confirmPasswordController.text.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Passwords do not match.')));
                      } else {
                        // Call the sign up function
                        _signupUser();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please fill in all fields.')));
                    }
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500),
                        )),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ScreenLogin()));
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
