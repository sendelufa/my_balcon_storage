import 'package:flutter_test/flutter_test.dart';

import 'package:storage_app/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StorageApp());

    expect(find.text('Storage App'), findsOneWidget);
    expect(find.text('Coming soon...'), findsOneWidget);
  });
}
