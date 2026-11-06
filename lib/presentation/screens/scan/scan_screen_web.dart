import 'package:flutter/material.dart';
import 'scan_view.dart';

/// Web / desktop screen. OCR processing currently requires the Android app.
class ScanScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const ScanScreen({super.key, this.onBack});
  @override
  Widget build(BuildContext context) => ScanView(webNote: true, onBack: onBack);
}
