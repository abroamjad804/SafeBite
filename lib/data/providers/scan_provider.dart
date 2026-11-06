import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../models/scan_history_model.dart';
import '../models/user_profile_model.dart';
import '../../core/utils/phss_calculator.dart';

class ScanProvider extends ChangeNotifier {
  ProductModel? _currentProduct;
  PhssResult? _currentPhss;
  List<ScanHistoryItem> _history = [];
  bool _isLoading = false;
  String? _error;

  ProductModel? get currentProduct => _currentProduct;
  PhssResult? get currentPhss => _currentPhss;
  List<ScanHistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ScanProvider() {
    _loadHistory();
  }

  Future<void> analyzeIngredientText(String rawText, UserProfile profile) async {
    _isLoading = true; _error = null; _currentProduct = null; _currentPhss = null;
    notifyListeners();
    try {
      final csv = await rootBundle.loadString('assets/datasets/ingredients.csv');
      final rows = const LineSplitter().convert(csv).skip(1);
      final dataset = <String, Map<String, String>>{};
      for (final row in rows) {
        final cols = row.split(',');
        if (cols.length >= 3) {
          dataset[cols[0].trim().toLowerCase()] = {
            'canonical': cols[0].trim(), 'aliases': cols[1].toLowerCase(),
            'category': cols[2].trim(),
          };
        }
      }
      final cleaned = rawText
          .replaceAll(RegExp(r'ingredients?\s*[:\-]', caseSensitive: false), '')
          .replaceAll(RegExp(r'[\n•;]+'), ',');
      final tokens = cleaned.split(RegExp(r'[,()]'))
          .map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' '))
          .where((e) => e.length > 1 && !RegExp(r'^\d+(\.\d+)?%?$').hasMatch(e))
          .toList();
      final seen = <String>{};
      final ingredients = <IngredientItem>[];
      for (final token in tokens) {
        final key = token.toLowerCase();
        if (!seen.add(key)) continue;
        Map<String, String>? match;
        for (final entry in dataset.values) {
          final aliases = entry['aliases']!.split('|');
          if (entry['canonical']!.toLowerCase() == key ||
              aliases.any((a) => a.trim() == key)) { match = entry; break; }
        }
        ingredients.add(IngredientItem(
          name: token,
          canonicalName: match?['canonical'],
          matchStatus: match == null ? 'unmatched' : 'confirmed',
          confidence: match == null ? null : 1.0,
          description: match == null ? 'Not found in the local ingredient dataset; requires verification.' : 'Matched in local ingredient dataset (${match['category']}).',
        ));
      }
      if (ingredients.isEmpty) throw Exception('No ingredients could be extracted. Try a clearer label photo.');
      _currentProduct = ProductModel(
        barcode: '', name: 'OCR Ingredient Analysis',
        ingredients: ingredients, dataSource: 'ocr',
      );
      _currentPhss = PhssCalculator.calculate(profile, _currentProduct!);
      final unmatched = ingredients.where((i) => i.matchStatus == 'unmatched').length;
      if (unmatched > 0) {
        _currentPhss = PhssResult(
          score: _currentPhss!.score, label: _currentPhss!.label,
          warnings: [..._currentPhss!.warnings, '$unmatched ingredient(s) were not found in the dataset and require manual verification.', 'Nutrition facts were not extracted; nutrition-based H and N factors may be incomplete.'],
          reasons: [..._currentPhss!.reasons, 'PHSS is calculated using recognized ingredient signals only; unmatched items are not assumed safe.'],
          isUnverified: false,
        );
      } else {
        _currentPhss = PhssResult(
          score: _currentPhss!.score, label: _currentPhss!.label,
          warnings: [..._currentPhss!.warnings, 'Nutrition facts were not extracted; nutrition-based H and N factors may be incomplete.'],
          reasons: _currentPhss!.reasons,
          isUnverified: false,
        );
      }
    } catch (e) { _error = e.toString().replaceFirst('Exception: ', ''); }
    _isLoading = false; notifyListeners();
  }

  void saveCurrentScan() {
    if (_currentProduct == null || _currentPhss == null) return;

    final item = ScanHistoryItem(
      id: const Uuid().v4(),
      product: _currentProduct!,
      phssScore: _currentPhss!.score,
      suitabilityLabel: PhssCalculator.labelText(_currentPhss!.label)
          .toLowerCase()
          .replaceAll('*', ''),
      warnings: _currentPhss!.warnings,
      scannedAt: DateTime.now(),
    );

    _history.insert(0, item);
    _persistHistory();
    notifyListeners();
  }

  void clearCurrentScan() {
    _currentProduct = null;
    _currentPhss = null;
    _error = null;
    notifyListeners();
  }

  void removeHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    _persistHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _persistHistory();
    notifyListeners();
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_history.map((h) => h.toJson()).toList());
    await prefs.setString('scan_history', data);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('scan_history');
    if (data != null) {
      final list = jsonDecode(data) as List<dynamic>;
      _history = list
          .map((item) =>
              ScanHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }
}
