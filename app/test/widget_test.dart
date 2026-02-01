import 'package:flutter_test/flutter_test.dart';

import 'package:storage_app/main.dart';
import 'package:storage_app/screens/locations_list_screen.dart';

void main() {
  testWidgets('App starts with locations list screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StorageApp());

    // Verify the locations list screen is displayed
    expect(find.byType(LocationsListScreen), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
  });
}
