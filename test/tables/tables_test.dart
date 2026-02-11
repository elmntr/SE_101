import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';

void main() {
  group('EmptyButtonType Enum', () {
    test('1. should have 3 values', () {
      expect(EmptyButtonType.values.length, equals(3));
    });

    test('2. should contain none, icon, elevated', () {
      expect(EmptyButtonType.values, contains(EmptyButtonType.none));
      expect(EmptyButtonType.values, contains(EmptyButtonType.icon));
      expect(EmptyButtonType.values, contains(EmptyButtonType.elevated));
    });

    test('3. none should have index 0', () {
      expect(EmptyButtonType.none.index, equals(0));
    });

    test('4. icon should have index 1', () {
      expect(EmptyButtonType.icon.index, equals(1));
    });

    test('5. elevated should have index 2', () {
      expect(EmptyButtonType.elevated.index, equals(2));
    });
  });

  group('emptyTables Widget', () {
    testWidgets('6. should display message text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(message: 'No items found'),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('7. should be centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(message: 'Empty'),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('8. should not show button when buttonType is none', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.none,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('9. should show icon button when buttonType is icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.icon,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('10. should show elevated button when buttonType is elevated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.elevated,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('11. elevated button should show custom text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.elevated,
              onAddPressed: () {},
              buttonText: 'Add New',
            ),
          ),
        ),
      );

      expect(find.text('Add New'), findsOneWidget);
    });

    testWidgets('12. elevated button should default to Confirm', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.elevated,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('13. icon button should trigger callback on tap', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.icon,
              onAddPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(pressed, isTrue);
    });

    testWidgets('14. should not show button when onAddPressed is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No data',
              buttonType: EmptyButtonType.icon,
              onAddPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('15. should contain Column layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(message: 'Test'),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
    });
  });
}
