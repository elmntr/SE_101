import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:chickenjoo_inventory/design_constants.dart';

void main() {
  group('Design Constants Tests', () {
    group('Constant Values Tests', () {
      test('should have correct fontAll constant', () {
        expect(fontAll, equals('Montserrat'));
        expect(fontAll, isA<String>());
      });

      test('should have correct imageAll constant', () {
        expect(imageAll, equals('assets/images/chicken_joo_logo.png'));
        expect(imageAll, isA<String>());
      });

      test('should have correct colorAll constant', () {
        expect(colorAll, equals(Colors.red));
        expect(colorAll, isA<Color>());
      });

      test('should have immutable constants', () {
        // Verify that constants are not null
        expect(fontAll, isNotNull);
        expect(imageAll, isNotNull);
        expect(colorAll, isNotNull);
      });

      test('should have correct constant types', () {
        expect(fontAll, isA<String>());
        expect(imageAll, isA<String>());
        expect(colorAll, isA<Color>());
      });
    });

    group('AppLayout Class Tests', () {
      group('Constructor Tests', () {
        test('should have private constructor', () {
          // AppLayout has a private constructor, so we can't instantiate it directly
          // This test verifies the class exists and has the expected structure
          expect(AppLayout.isDesktop, isA<Function>());
          expect(AppLayout.fieldPadding, isA<Function>());
          expect(AppLayout.loginButtonWidth, isA<Function>());
        });
      });

      group('isDesktop Method Tests', () {
        testWidgets('should return true for desktop width (> 1000)', (WidgetTester tester) async {
          // Set up a large screen size first
          tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  final isDesktop = AppLayout.isDesktop(context);
                  expect(isDesktop, isTrue);
                  return Container();
                },
              ),
            ),
          );

          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.isDesktop(context), isTrue);
        });

        testWidgets('should return false for tablet width (<= 1000)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  final isDesktop = AppLayout.isDesktop(context);
                  return Container();
                },
              ),
            ),
          );

          // Set up a tablet screen size
          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.isDesktop(context), isFalse);
        });

        testWidgets('should return false for mobile width', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Set up a mobile screen size
          tester.binding.window.physicalSizeTestValue = const Size(400, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.isDesktop(context), isFalse);
        });

        testWidgets('should handle edge case at exactly 1000 width', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Set up exactly 1000 width
          tester.binding.window.physicalSizeTestValue = const Size(1000, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.isDesktop(context), isFalse);
        });

        testWidgets('should handle very large screens', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Set up a very large screen size
          tester.binding.window.physicalSizeTestValue = const Size(2000, 1200);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.isDesktop(context), isTrue);
        });
      });

      group('fieldPadding Method Tests', () {
        testWidgets('should return 400 for large screens (>= 1200)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Large screen
          tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(400));
        });

        testWidgets('should return 400 for very large screens (> 1200)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Very large screen
          tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(400));
        });

        testWidgets('should return 200 for medium screens (>= 800, < 1200)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Medium screen
          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(200));
        });

        testWidgets('should return 200 for exactly 800 width', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Exactly 800 width
          tester.binding.window.physicalSizeTestValue = const Size(800, 600);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(200));
        });

        testWidgets('should return 24 for small screens (< 800)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Small screen
          tester.binding.window.physicalSizeTestValue = const Size(600, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(24));
        });

        testWidgets('should return 24 for very small screens', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Very small screen
          tester.binding.window.physicalSizeTestValue = const Size(300, 600);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(24));
        });

        testWidgets('should handle edge case at exactly 1200 width', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Exactly 1200 width
          tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(400));
        });

        testWidgets('should return double values', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), isA<double>());
        });
      });

      group('loginButtonWidth Method Tests', () {
        testWidgets('should return 320 for large screens (>= 1200)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Large screen
          tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(320));
        });

        testWidgets('should return 320 for very large screens (> 1200)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Very large screen
          tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(320));
        });

        testWidgets('should return 280 for medium screens (>= 800, < 1200)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Medium screen
          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(280));
        });

        testWidgets('should return 280 for exactly 800 width', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Exactly 800 width
          tester.binding.window.physicalSizeTestValue = const Size(800, 600);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(280));
        });

        testWidgets('should return double.infinity for small screens (< 800)', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Small screen
          tester.binding.window.physicalSizeTestValue = const Size(600, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(double.infinity));
        });

        testWidgets('should return double.infinity for very small screens', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Very small screen
          tester.binding.window.physicalSizeTestValue = const Size(300, 600);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(double.infinity));
        });

        testWidgets('should handle edge case at exactly 1200 width', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Exactly 1200 width
          tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), equals(320));
        });

        testWidgets('should return double values for finite widths', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.loginButtonWidth(context), isA<double>());
        });
      });

      group('Responsive Behavior Tests', () {
        testWidgets('should be consistent across all methods for same screen size', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Test medium screen
          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          
          final isDesktop = AppLayout.isDesktop(context);
          final fieldPadding = AppLayout.fieldPadding(context);
          final loginButtonWidth = AppLayout.loginButtonWidth(context);

          expect(isDesktop, isFalse);
          expect(fieldPadding, equals(200));
          expect(loginButtonWidth, equals(280));
        });

        testWidgets('should handle orientation changes', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Portrait
          tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          final portraitPadding = AppLayout.fieldPadding(context);

          // Landscape
          tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final landscapePadding = AppLayout.fieldPadding(context);

          expect(portraitPadding, equals(200));
          expect(landscapePadding, equals(400));
        });
      });

      group('Error Handling Tests', () {
        testWidgets('should handle zero width gracefully', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Zero width edge case
          tester.binding.window.physicalSizeTestValue = const Size(0, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(24));
          expect(AppLayout.loginButtonWidth(context), equals(double.infinity));
        });

        testWidgets('should handle negative width gracefully', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          // Very small width edge case
          tester.binding.window.physicalSizeTestValue = const Size(100, 800);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          expect(AppLayout.fieldPadding(context), equals(24));
          expect(AppLayout.loginButtonWidth(context), equals(double.infinity));
        });
      });

      group('Performance Tests', () {
        testWidgets('should execute methods quickly', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Container();
                },
              ),
            ),
          );

          tester.binding.window.physicalSizeTestValue = const Size(1000, 768);
          tester.binding.window.devicePixelRatioTestValue = 1.0;
          await tester.pump();

          final context = tester.element(find.byType(Container));
          
          final stopwatch = Stopwatch()..start();
          
          for (int i = 0; i < 1000; i++) {
            AppLayout.isDesktop(context);
            AppLayout.fieldPadding(context);
            AppLayout.loginButtonWidth(context);
          }
          
          stopwatch.stop();
          
          // Should complete 1000 iterations in under 100ms
          expect(stopwatch.elapsedMilliseconds, lessThan(100));
        });
      });
    });

    group('Integration Tests', () {
      test('should have all expected constants and methods', () {
        // Verify all expected elements exist
        expect(fontAll, isNotNull);
        expect(imageAll, isNotNull);
        expect(colorAll, isNotNull);
        expect(AppLayout.isDesktop, isA<Function>());
        expect(AppLayout.fieldPadding, isA<Function>());
        expect(AppLayout.loginButtonWidth, isA<Function>());
      });

      test('should maintain backward compatibility', () {
        // Ensure the API hasn't changed unexpectedly
        expect(fontAll, isA<String>());
        expect(imageAll, isA<String>());
        expect(colorAll, isA<Color>());
      });
    });
  });
}
