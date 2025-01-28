// lib/widgets/custom_card.dart
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final double borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      elevation: elevation ?? 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
