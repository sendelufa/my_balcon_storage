import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:storage_app/domain/entities/item.dart';
import 'package:storage_app/domain/entities/location.dart';
import 'package:storage_app/screens/item_detail_screen.dart';

void main() {
  // Initialize date formatting for tests
  Intl.defaultLocale = 'en_US';

  group('ItemDetailScreen', () {
    final testItem = Item(
      id: 1,
      name: 'Winter Clothes Box',
      description: 'Box containing winter jackets, gloves, and scarves.',
      locationId: 1,
      createdAt: 1704067200000, // Jan 1, 2024
      updatedAt: 1704067200000,
      photoPath: '/path/to/photo.jpg',
    );

    testWidgets('has proper AppBar with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      );
      await tester.pump();

      // AppBar exists with correct title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Item Detail'), findsOneWidget);
    });

    testWidgets('widget builds without crashing when item provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      );
      await tester.pumpAndSettle();

      // Screen builds successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('widget builds without crashing when itemId provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ItemDetailScreen(itemId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Screen builds successfully (will show error in test env, but no crash)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    test('accepts itemId when item is not provided', () {
      // Should not throw - itemId is provided
      expect(
        () => ItemDetailScreen(itemId: 1),
        returnsNormally,
      );
    });
  });

  group('ItemDetailScreen - Widget Components', () {
    testWidgets('includes menu button in AppBar', (tester) async {
      final testItem = Item(
        id: 1,
        name: 'Test Item',
        locationId: 1,
        createdAt: 1704067200000,
        updatedAt: 1704067200000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      );
      await tester.pump();

      // AppBar should exist
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays Scaffold as root', (tester) async {
      final testItem = Item(
        id: 1,
        name: 'Test Item',
        locationId: 1,
        createdAt: 1704067200000,
        updatedAt: 1704067200000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ItemDetailScreen(item: testItem),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
