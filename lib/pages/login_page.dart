import 'package:calculatorapp/api/google_signin_api.dart';
import 'package:calculatorapp/components/box.dart';
import 'package:calculatorapp/components/button.dart';
import 'package:calculatorapp/components/my_textfield.dart';
import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/calculator.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/pages/sign_up.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:calculatorapp/components/my_button.dart';

class LoginPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {}
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
        title: Text(
          'W E L C O M E',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          Row(
            children: [
              MyBox(
                color: Colors.red,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(color: Colors.white),
                  ),
                  MyButton(
                    color: Colors.brown,
                    onTap: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.orange,
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'M E N U',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  'Home',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.calculate),
                title: Text(
                  'Calculator',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Calculator()));
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text(
                  'About Me',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UserAbout()));
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Login',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.app_registration_rounded),
                title: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                },
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              //logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              //welcome back, you've been missed
              Text(
                'Welcome back dearest client!',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),

              const SizedBox(height: 50),

              //username textified
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //password textified
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              //forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'forgot password?,',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              //sign in button?
              MyButtonn(
                onTap: signUserIn,
              ),

              const SizedBox(height: 50),

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

              const SizedBox(height: 50),

              //google + apple sign in buttons
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                label: Text('Sign In with Google'),
                onPressed: signIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
