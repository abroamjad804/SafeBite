import 'package:flutter/material.dart';
import 'scan_view.dart';

/// Android ingredient-label OCR screen.
class ScanScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const ScanScreen({super.key, this.onBack});
  @override
  Widget build(BuildContext context) => ScanView(onBack: onBack);
}
