import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sensors/sensors.dart';

class LightSensorPage extends StatefulWidget {
  const LightSensorPage({Key? key}) : super(key: key);

  @override
  State<LightSensorPage> createState() => _LightSensorPageState();
}

class _LightSensorPageState extends State<LightSensorPage> {
  static const platform =
      MethodChannel('com.example.calculatorapp.sensors/lightsensor');
  double _lightReading = 0.0;
  double maxLightLevel = 500.0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _getLightLevel();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(double lightLevel) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ambient_light_channel', // The id of the channel.
        'Ambient Light Channel', // The name of the channel.
        // 'Channel for ambient light level notifications', // The description of the channel.
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Ambient Light Level Changed',
      'Current light level: $lightLevel lux',
      platformChannelSpecifics,
    );
  }

  Future<void> _getLightLevel() async {
    try {
      final double result = await platform.invokeMethod('getLightLevel');
      setState(() {
        _lightReading = result;
      });
      _showNotification(result);
    } on PlatformException {
      _lightReading = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_lightReading / maxLightLevel).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambient Light'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomLeft,
        //     colors: [
        //       Colors.deepPurple,
        //       Colors.indigo,
        //     ],
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text(
              'Ambient Light Level',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.orange,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
            ),
            SizedBox(height: 20),
            Text(
              "${_lightReading.toStringAsFixed(2)} lux",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                letterSpacing: 1.1,
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _getLightLevel,
              icon: Icon(Icons.lightbulb_outline, size: 24),
              label: Text("Refresh"),
              style: ElevatedButton.styleFrom(
                // primary: Colors.amber, // Button color
                // onPrimary: Colors.black, // Text color
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
