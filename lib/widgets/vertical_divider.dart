import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
