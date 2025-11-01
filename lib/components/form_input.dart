import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;

  const FormInput({
    super.key,
    required this.icon,
    required this.hint,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF044C9C);
    const Color borderColor = Color(0xFFBFC3C4);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: borderColor),
        ),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
      ),
    );
  }
}