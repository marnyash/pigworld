import 'package:flutter/widgets.dart';

class PigWorldIcon extends StatelessWidget {
  const PigWorldIcon(this.assetName, {this.size = 24, super.key});

  final String assetName;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/icons/$assetName.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}
