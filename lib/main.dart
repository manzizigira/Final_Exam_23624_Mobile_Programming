import 'package:calculatorapp/dependency_injection.dart';
import 'package:calculatorapp/pages/image_p.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:calculatorapp/pages/sign_up.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
//import 'package:calculatorapp/pages/counter.dart';

void main() {
  DependecyInjection.init(); 
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Myapp(),
    ),
  );
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
