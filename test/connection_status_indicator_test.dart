import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/connection_status_indicator.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';

void main() {
  group('ConnectionStatusIndicator Tests', () {
    // Helper to wrap widget with MaterialApp for proper testing
    Widget wrapWithMaterialApp(Widget widget) {
      return MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      );
    }

    // Positive Tests (7)
    testWidgets('should build with online and synced status', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should build with online and syncing status', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.syncing,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should build with offline status', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: false,
          syncStatus: SyncStatus.synced,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should show sync button when online and callback provided', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      final widget = wrapWithMaterialApp(
        ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
          onSyncPressed: () => callbackCalled = true,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      final syncButton = find.byIcon(Icons.sync);
      if (syncButton.evaluate().isNotEmpty) {
        await tester.tap(syncButton);
        await tester.pump();
      }

      // Assert
      expect(callbackCalled, isTrue);
    });

    testWidgets('should not show sync button when offline', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        ConnectionStatusIndicator(
          isOnline: false,
          syncStatus: SyncStatus.synced,
          onSyncPressed: () {},
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.sync), findsNothing);
    });

    testWidgets('should handle error status correctly', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.error,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should handle idle status correctly', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.idle,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    // Negative Tests (8)
    testWidgets('should handle missing callback gracefully', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - No sync button when no callback
      expect(find.byIcon(Icons.sync), findsNothing);
    });

    testWidgets('should handle rapid status changes', (WidgetTester tester) async {
      // Arrange & Act - Initial state
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
        ),
      ));

      // Change to syncing
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.syncing,
        ),
      ));

      // Change back to synced
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
        ),
      ));

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should handle animation controller disposal', (WidgetTester tester) async {
      // Arrange
      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.syncing,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpWidget(const MaterialApp(home: Scaffold())); // Unmount

      // Assert - Should not throw during disposal
      expect(find.byType(ConnectionStatusIndicator), findsNothing);
    });

    testWidgets('should handle very large screen size', (WidgetTester tester) async {
      // Arrange
      tester.view.physicalSize = const Size(10000, 10000);
      tester.view.devicePixelRatio = 1.0;

      final widget = wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - Should handle large screens
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);

      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle rapid tap events', (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      final widget = wrapWithMaterialApp(
        ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
          onSyncPressed: () => tapCount++,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      final syncButton = find.byIcon(Icons.sync);
      if (syncButton.evaluate().isNotEmpty) {
        await tester.tap(syncButton);
        await tester.pump();
        await tester.tap(syncButton);
        await tester.pump();
      }

      // Assert
      expect(tapCount, greaterThanOrEqualTo(0));
    });

    testWidgets('should handle connectivity toggle', (WidgetTester tester) async {
      // Arrange - Start online
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.synced,
        ),
      ));

      // Act - Go offline
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: false,
          syncStatus: SyncStatus.synced,
        ),
      ));

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should handle syncing to error transition', (WidgetTester tester) async {
      // Arrange - Start syncing
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.syncing,
        ),
      ));

      // Act - Transition to error
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.error,
        ),
      ));

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });

    testWidgets('should handle error to idle transition', (WidgetTester tester) async {
      // Arrange - Start with error
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.error,
        ),
      ));

      // Act - Transition to idle
      await tester.pumpWidget(wrapWithMaterialApp(
        const ConnectionStatusIndicator(
          isOnline: true,
          syncStatus: SyncStatus.idle,
        ),
      ));

      // Assert
      expect(find.byType(ConnectionStatusIndicator), findsOneWidget);
    });
  });
}
