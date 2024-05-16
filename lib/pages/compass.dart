import 'dart:math';

import 'package:calculatorapp/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class Compass_Page extends StatefulWidget {
  const Compass_Page({super.key});

  @override
  State<Compass_Page> createState() => _Compass_PageState();
}

class _Compass_PageState extends State<Compass_Page> {
  double? heading = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterCompass.events!.listen((event) {
      setState(() {
        heading = event.heading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: AppLogo(),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${heading!.ceil()}°",
            style: TextStyle(
                fontSize: 26.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: EdgeInsets.all(18.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("lib/images/cadrant.png"),
                Transform.rotate(
                  angle: ((heading ?? 0) * (pi / 100) * -1),
                  child: Image.asset(
                    "lib/images/compass.png",
                    scale: 1.1,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
