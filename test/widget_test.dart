import 'package:flutter_test/flutter_test.dart';
import 'package:safebite_app/main.dart';

void main() {
  testWidgets('SafeBite app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeBiteApp());
    expect(find.byType(SafeBiteApp), findsOneWidget);
  });
}
