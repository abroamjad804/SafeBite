import 'product_model.dart';

class ScanHistoryItem {
  final String id;
  final ProductModel product;
  final double phssScore;
  final String suitabilityLabel; // 'safe', 'caution', 'avoid', 'unverified'
  final List<String> warnings;
  final DateTime scannedAt;

  ScanHistoryItem({
    required this.id,
    required this.product,
    required this.phssScore,
    required this.suitabilityLabel,
    required this.warnings,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product.toJson(),
        'phssScore': phssScore,
        'suitabilityLabel': suitabilityLabel,
        'warnings': warnings,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>;
    final ingredientsRaw =
        productData['ingredients'] as List<dynamic>? ?? [];

    return ScanHistoryItem(
      id: json['id'] ?? '',
      product: ProductModel(
        barcode: productData['barcode'] ?? '',
        name: productData['name'] ?? '',
        brand: productData['brand'],
        imageUrl: productData['imageUrl'],
        ingredients: ingredientsRaw
            .map((i) => IngredientItem(name: i['name'] ?? ''))
            .toList(),
        nutritionPer100g:
            Map<String, dynamic>.from(productData['nutritionPer100g'] ?? {}),
        allergenStatements:
            List<String>.from(productData['allergenStatements'] ?? []),
      ),
      phssScore: (json['phssScore'] ?? 0).toDouble(),
      suitabilityLabel: json['suitabilityLabel'] ?? 'unverified',
      warnings: List<String>.from(json['warnings'] ?? []),
      scannedAt: DateTime.parse(
          json['scannedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
