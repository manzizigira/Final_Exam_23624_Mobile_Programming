import 'dart:async';

import 'package:calculatorapp/dependency_injection.dart';
import 'package:calculatorapp/pages/auth_page.dart';
import 'package:calculatorapp/pages/image_p.dart';
import 'package:calculatorapp/pages/login_or_register_oages.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:calculatorapp/pages/sign_up.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:calculatorapp/pages/counter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DependecyInjection.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MaterialApp( // Wrap with MaterialApp
        debugShowCheckedModeBanner: false,
        home: Myapp(),
      ),
    ),
  );
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
       
        debugShowCheckedModeBanner: false,
        home: LoginOrRegisterPage(),
        theme: Provider.of<ThemeProvider>(context).themeData,
      
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> displayNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      // Set the small icon resource
      icon: 'notification_icon',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}