import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/ocr_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/scan_provider.dart';
import '../../widgets/common/brand.dart';
import '../../widgets/common/fx.dart';

class ScanView extends StatefulWidget {
  final bool webNote;
  final VoidCallback? onBack;
  const ScanView({super.key, this.webNote = false, this.onBack});
  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool _working = false;
  Uint8List? _imageBytes;
  String? _recognizedText;

  Future<void> _pickAndRead() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredient OCR is currently available in the Android app.')));
      return;
    }
    final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
    if (image == null || !mounted) return;
    setState(() { _working = true; _imageBytes = null; _recognizedText = null; });
    final bytes = await image.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
    try {
      final text = await extractTextFromImage(image.path);
      if (!mounted) return;
      setState(() => _recognizedText = text);
      if (text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No text detected. Please capture the ingredient label clearly.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OCR failed: $e')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _analyze() async {
    final text = _recognizedText;
    final user = context.read<AuthProvider>().user;
    if (text == null || user == null) return;
    setState(() => _working = true);
    final scan = context.read<ScanProvider>();
    await scan.analyzeIngredientText(text, user);
    if (!mounted) return;
    setState(() => _working = false);
    if (scan.currentProduct != null) context.push('/result');
    else if (scan.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(scan.error!)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: AppBackground(
      child: SafeArea(bottom: false, child: Column(children: [
        PageHeader(title: 'Scan Ingredients', onBack: widget.onBack),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              height: 250, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(26)),
              child: _imageBytes == null
                ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.document_scanner_outlined, size: 72, color: AppColors.primaryDark),
                    SizedBox(height: 12),
                    Text('Capture the ingredient label', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
                    SizedBox(height: 6),
                    Text('Keep the text clear and well-lit', style: TextStyle(color: AppColors.textSecondary)),
                  ])
                : ClipRRect(borderRadius: BorderRadius.circular(26), child: Image.memory(_imageBytes!, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(onPressed: _working ? null : _pickAndRead, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Capture Ingredient Label')),
            if (_working) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            if (_recognizedText != null) ...[
              const SizedBox(height: 18),
              const Text('Review extracted text', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextFormField(initialValue: _recognizedText, minLines: 5, maxLines: 12,
                decoration: const InputDecoration(hintText: 'Edit OCR text if needed'),
                onChanged: (v) => _recognizedText = v),
              const SizedBox(height: 14),
              ElevatedButton.icon(onPressed: _working ? null : _analyze, icon: const Icon(Icons.health_and_safety_outlined), label: const Text('Evaluate Ingredients & Calculate PHSS')),
            ],
            const SizedBox(height: 14),
            const Text('SafeBite matches extracted ingredient names against its local dataset. Items not found are clearly marked for verification; they are never automatically treated as safe.', style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          ]),
        )),
      ])),
    ),
  );
}
