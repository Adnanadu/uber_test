import 'package:flutter/material.dart';

class CustomizedTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;

  const CustomizedTextField({
    super.key,
    required this.text,
    required this.controller,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
          fillColor: Colors.white,
          filled: true,
          suffixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
