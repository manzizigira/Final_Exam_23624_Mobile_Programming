import 'package:calculatorapp/api/google_signin_api.dart';
import 'package:calculatorapp/components/box.dart';
import 'package:calculatorapp/components/button.dart';
import 'package:calculatorapp/components/my_button.dart';
import 'package:calculatorapp/components/my_textfield.dart';
import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/calculator.dart';
import 'package:calculatorapp/pages/contact.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/pages/login_or_register_oages.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final Function()? onTap;
  const SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final studentIDController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        addUserDetails(int.parse(studentIDController.text.trim()),
            nameController.text.trim(), emailController.text.trim(), 'Student');

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginOrRegisterPage(),
        ));
      } else {
        showErrorMessage("Password don't Match");
      }
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Future addUserDetails(
      int stuid, String email, String full, String role) async {
    try {
      await FirebaseFirestore.instance.collection('User').add({
        'Student ID': stuid,
        'Full name': full,
        'Email': email,
        'Role': role,
      });
    } catch (e) {
      print('Firestore Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future signIn() async {
      final user = await GoogleSignInApi.login();
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign in Failed')));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),

                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 25),

                //welcome back, you've been missed
                Text(
                  'Welcome our dearest client! Join us!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: studentIDController,
                  hintText: 'Student ID',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //sign up button
                ElevatedButton(
                  onPressed: () {
                    signUserUp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //google + apple sign in buttons
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red,
                  ),
                  label: Text('Sign Up with Google'),
                  onPressed: signIn,
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
