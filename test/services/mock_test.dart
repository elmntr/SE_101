import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mock_test.mocks.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder])
void main() {
  group('Mock Test', () {
    late MockSupabaseClient mockSupabase;
    late MockSupabaseQueryBuilder mockQueryBuilder;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      
      print('Setting up mock...');
      when(mockSupabase.from(any)).thenAnswer((_) => mockQueryBuilder);
    });

    test('basic mock test', () {
      print('Testing mock...');
      final result = mockSupabase.from('test');
      print('Result type: ${result.runtimeType}');
      expect(result, isA<SupabaseQueryBuilder>());
    });
  });
}
