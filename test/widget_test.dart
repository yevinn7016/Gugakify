import 'package:flutter_test/flutter_test.dart';
import 'package:gugakify/app.dart';

void main() {
  testWidgets('Gugakify starts with intro screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GugakifyApp());

    expect(find.text('K-POP을\n국악과 전통 MV로\n변환하다'), findsOneWidget);
  });
}
