import 'package:flutter/material.dart';


class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Counter()
    );
  }
}
 class _Counter extends StatefulWidget{
    @override
    _CounterState createState() => _CounterState();
  }

class _CounterState extends State<_Counter>{
  int _count = 0;

  void _increment(){
    setState(() {
      _count++;
    });
  }

  void _decrement(){
    setState(() {
      if(_count<0){
        return;
      }
      _count--;
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Counter"),)
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: _increment,
            ),
            Text("${_count}"),
            FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: _decrement,
            ),
          ],
          ),
        ),
      );
  }
}