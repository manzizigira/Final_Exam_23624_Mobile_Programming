import 'package:calculatorapp/components/box.dart';
import 'package:calculatorapp/components/button.dart';
import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/calculator.dart';
import 'package:calculatorapp/pages/contact.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:calculatorapp/pages/sign_up.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                leading: Icon(Icons.message),
                title: Text(
                  'Contacts',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyContact()));
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
      body: Center(
        child: Text(
          'G&M',
          style: TextStyle(fontSize: 50),
        ),
      ),
    );
  }
}
