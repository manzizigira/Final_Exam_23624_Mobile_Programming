import 'dart:async';
import 'package:flutter/material.dart';
import 'package:charts_flutter_updated/flutter.dart' as charts;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  static const platform =
      MethodChannel('com.example.calculatorapp.sensors/lightsensor');
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  double _lightReading = 0.0;
  int _stepCount = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<List<LightData>> _lightDataController =
      StreamController.broadcast();
  final StreamController<List<StepData>> _stepDataController =
      StreamController.broadcast();

  final List<LightData> _lightData = [];
  final List<StepData> _stepData = [];

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
    _getLightLevel();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _lightDataController.close();
    _stepDataController.close();
    super.dispose();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.z.abs() > 10.0) {
        setState(() {
          _stepCount++;
          _stepData.add(StepData(DateTime.now(), _stepCount));
          if (_stepData.length > 10) {
            _stepData.removeAt(0); // Keep the list at a manageable size
          }
          _stepDataController.add(_stepData);
          _showNotification('Step Detected!', 'You took a step!');
        });
      }
    });
  }

  Future<void> _getLightLevel() async {
    try {
      final double result = await platform.invokeMethod('getLightLevel');
      setState(() {
        _lightReading = result;
        _lightData.add(LightData(DateTime.now(), _lightReading));
        if (_lightData.length > 10) {
          _lightData.removeAt(0); // Keep the list at a manageable size
        }
        _lightDataController.add(_lightData);
        _showNotification(
            'Ambient Light Level Changed', 'Current light level: $result lux');
      });
    } on PlatformException {
      setState(() {
        _lightReading = 0.0;
      });
    }
  }

  Future<void> _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'sensor_channel', 'Sensor Channel',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _refreshPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SensorDataPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<List<LightData>>(
              stream: _lightDataController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return charts.BarChart(
                    _createLightData(snapshot.data!),
                    animate: true,
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<StepData>>(
              stream: _stepDataController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return charts.BarChart(
                    _createStepData(snapshot.data!),
                    animate: true,
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Ambient Light Level'),
              subtitle: Text('${_lightReading.toStringAsFixed(2)} lux'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Step Count'),
              subtitle: Text('$_stepCount'),
            ),
          ),
        ],
      ),
    );
  }

  List<charts.Series<LightData, String>> _createLightData(
      List<LightData> data) {
    return [
      charts.Series<LightData, String>(
        id: 'Light',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LightData data, _) => data.time.toIso8601String(),
        measureFn: (LightData data, _) => data.value,
        data: data,
      )
    ];
  }

  List<charts.Series<StepData, String>> _createStepData(List<StepData> data) {
    return [
      charts.Series<StepData, String>(
        id: 'Steps',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (StepData data, _) => data.time.toIso8601String(),
        measureFn: (StepData data, _) => data.value,
        data: data,
      )
    ];
  }
}

class LightData {
  final DateTime time;
  final double value;

  LightData(this.time, this.value);
}

class StepData {
  final DateTime time;
  final int value;

  StepData(this.time, this.value);
}
