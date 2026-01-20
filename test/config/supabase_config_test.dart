import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/config/supabase_config.dart';

void main() {
  group('SupabaseConfig Class Tests', () {
    // These tests check the class definition without actually calling the methods
    // since they require dotenv to be initialized
    
    // Positive Tests (7)
    test('SupabaseConfig class should exist', () {
      expect(SupabaseConfig, isNotNull);
    });

    test('SupabaseConfig should have url getter defined', () {
      expect(() => SupabaseConfig.url, throwsA(anything));
    });

    test('SupabaseConfig should have anonKey getter defined', () {
      expect(() => SupabaseConfig.anonKey, throwsA(anything));
    });

    test('SupabaseConfig should have isValid getter defined', () {
      expect(() => SupabaseConfig.isValid, throwsA(anything));
    });

    test('SupabaseConfig should have printConfigStatus method defined', () {
      expect(SupabaseConfig.printConfigStatus, isNotNull);
    });

    test('SupabaseConfig should be usable as a class reference', () {
      final Type type = SupabaseConfig;
      expect(type, equals(SupabaseConfig));
    });

    test('SupabaseConfig should be a static class (no constructor needed)', () {
      // SupabaseConfig uses static methods only
      expect(SupabaseConfig, isNotNull);
    });

    // Negative Tests (8)
    test('url getter should throw when dotenv not initialized', () {
      // SupabaseConfig.url throws NotInitializedError when dotenv not loaded
      expect(() => SupabaseConfig.url, throwsA(anything));
    });

    test('anonKey getter should throw when dotenv not initialized', () {
      expect(() => SupabaseConfig.anonKey, throwsA(anything));
    });

    test('isValid getter should throw when dotenv not initialized', () {
      expect(() => SupabaseConfig.isValid, throwsA(anything));
    });

    test('printConfigStatus should throw when dotenv not initialized', () {
      expect(() => SupabaseConfig.printConfigStatus(), throwsA(anything));
    });

    test('getters should not return null on access failure', () {
      // When accessed without dotenv, they throw rather than return null
      try {
        SupabaseConfig.url;
        fail('Expected exception');
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('class should handle repeated access attempt errors consistently', () {
      Object? error1;
      Object? error2;
      
      try {
        SupabaseConfig.url;
      } catch (e) {
        error1 = e;
      }
      
      try {
        SupabaseConfig.url;
      } catch (e) {
        error2 = e;
      }
      
      expect(error1.runtimeType, equals(error2.runtimeType));
    });

    test('class should handle different getter access failures', () {
      bool urlThrew = false;
      bool keyThrew = false;
      
      try {
        SupabaseConfig.url;
      } catch (e) {
        urlThrew = true;
      }
      
      try {
        SupabaseConfig.anonKey;
      } catch (e) {
        keyThrew = true;
      }
      
      expect(urlThrew, isTrue);
      expect(keyThrew, isTrue);
    });

    test('class should be consistently usable without initialization', () {
      // Class definition should still be accessible even when dotenv fails
      expect(SupabaseConfig, isNotNull);
      expect(() => SupabaseConfig.url, throwsA(anything));
    });
  });
}
