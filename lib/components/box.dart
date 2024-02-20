import 'package:flutter/material.dart';

class MyBox extends StatelessWidget {
  final List<Widget>? children;
  final Color? color;

  const MyBox({
    Key? key,
    required this.children,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      height: 40,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children!,
      ),
    );
  }
}
