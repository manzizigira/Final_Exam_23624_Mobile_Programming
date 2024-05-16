// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_charts/flutter_charts.dart';

// class SensorDataPage extends StatefulWidget {
//   @override
//   _SensorDataPageState createState() => _SensorDataPageState();
// }

// class _SensorDataPageState extends State<SensorDataPage> {
//   final StreamController<List<double>> _dataStreamController =
//       StreamController<List<double>>();

//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startStream();
//   }

//   @override
//   void dispose() {
//     _dataStreamController.close();
//     _stopStream();
//     super.dispose();
//   }

//   void _startStream() {
//     _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
//       _dataStreamController.sink.add(_generateRandomData());
//     });
//   }

//   void _stopStream() {
//     _timer?.cancel();
//   }

//   List<double> _generateRandomData() {
//     return List.generate(10, (index) => Random().nextInt(100) + 50);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sensor Data'),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Expanded(
//               child: StreamBuilder<List<double>>(
//                 stream: _dataStreamController.stream,
//                 initialData: [],
//                 builder: (context, snapshot) {
//                   return LineChart(
//                     painter: LineChartPainter.fromData(
//                       LineChartOptions(),
//                       [
//                         LineSeries<double>(
//                           data: snapshot.data,
//                           color: Colors.blue,
//                           displayName: 'Sensor Data',
//                         ),
//                       ],
//                     ),
//                     size: Size(double.infinity, double.infinity),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

