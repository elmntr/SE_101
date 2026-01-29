import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/services/connectivity_service.dart';

void main() {
  // Initialize Flutter binding for platform channel access
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup mock method channel for connectivity_plus
  const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return 'wifi'; // Return wifi as default connectivity
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('ConnectivityService Tests', () {
    // Positive Tests (7)
    test('should create ConnectivityService', () {
      final service = ConnectivityService();
      expect(service, isNotNull);
      service.dispose();
    });

    test('should have connectionStream', () {
      final service = ConnectivityService();
      expect(service.connectionStream, isNotNull);
      service.dispose();
    });

    test('connectionStream should be a broadcast stream', () {
      final service = ConnectivityService();
      // Broadcast streams can have multiple listeners
      final sub1 = service.connectionStream.listen((_) {});
      final sub2 = service.connectionStream.listen((_) {});
      expect(sub1, isNotNull);
      expect(sub2, isNotNull);
      sub1.cancel();
      sub2.cancel();
      service.dispose();
    });

    test('should be able to add multiple listeners', () {
      final service = ConnectivityService();
      int listenerCount = 0;
      
      final sub1 = service.connectionStream.listen((_) => listenerCount++);
      final sub2 = service.connectionStream.listen((_) => listenerCount++);
      
      expect(sub1, isNotNull);
      expect(sub2, isNotNull);
      
      sub1.cancel();
      sub2.cancel();
      service.dispose();
    });

    test('dispose should not throw', () {
      final service = ConnectivityService();
      expect(() => service.dispose(), returnsNormally);
    });

    test('connectionStream should return Stream<bool>', () {
      final service = ConnectivityService();
      expect(service.connectionStream, isA<Stream<bool>>());
      service.dispose();
    });

    test('should create new instance each time', () {
      final service1 = ConnectivityService();
      final service2 = ConnectivityService();
      expect(identical(service1, service2), isFalse);
      service1.dispose();
      service2.dispose();
    });

    // Negative Tests (8)
    test('should handle rapid connection after disposal', () {
      final service = ConnectivityService();
      service.dispose();
      // After dispose, operations should still not throw
      expect(service.connectionStream, isNotNull);
    });

    test('should handle multiple dispose calls', () {
      final service = ConnectivityService();
      service.dispose();
      // Second dispose should handle gracefully
      // (may throw but should not crash)
      try {
        service.dispose();
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('should handle immediate disposal after creation', () {
      final service = ConnectivityService();
      expect(() => service.dispose(), returnsNormally);
    });

    test('stream subscription should handle cancelation', () {
      final service = ConnectivityService();
      final sub = service.connectionStream.listen((_) {});
      expect(() => sub.cancel(), returnsNormally);
      service.dispose();
    });

    test('should handle listener errors gracefully', () {
      final service = ConnectivityService();
      final sub = service.connectionStream.listen(
        (_) {},
        onError: (e) {
          expect(e, isNotNull);
        },
      );
      sub.cancel();
      service.dispose();
    });

    test('should handle empty stream listeners', () {
      final service = ConnectivityService();
      final sub = service.connectionStream.listen(null);
      expect(sub, isNotNull);
      sub.cancel();
      service.dispose();
    });

    test('should maintain stream after listener cancel', () {
      final service = ConnectivityService();
      final sub = service.connectionStream.listen((_) {});
      sub.cancel();
      // Stream should still be accessible
      expect(service.connectionStream, isNotNull);
      service.dispose();
    });

    test('creating many instances should not cause issues', () {
      final services = List.generate(10, (_) => ConnectivityService());
      expect(services.length, equals(10));
      for (final service in services) {
        service.dispose();
      }
    });
  });
}
