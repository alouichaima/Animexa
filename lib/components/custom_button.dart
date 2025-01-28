import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final double? height;
  final double? width;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.height, // Optional height
    this.width, // Optional width
    this.padding, // Optional padding
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50, // Default to 50 if height is not provided
      width: width, // Use provided width, or fit content by default
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding ?? const EdgeInsets.all(16), // Default padding
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(color: textColor),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
