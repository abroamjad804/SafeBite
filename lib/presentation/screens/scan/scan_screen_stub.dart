import 'package:flutter/material.dart';

/// Stub ScanScreen — should never be reached in practice.
class ScanScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const ScanScreen({super.key, this.onBack});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Scanning not supported on this platform')),
    );
  }
}
