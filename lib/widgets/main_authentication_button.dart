import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainAuthenticationButton extends StatelessWidget {
  const MainAuthenticationButton(
      {super.key,
      required this.label,
      required this.onPressed,
      required this.fontSize});

  final String label;
  final Function() onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      color: Colors.black,
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.infinity,
        child: Text(label,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2)),
      ),
    );
  }
}
