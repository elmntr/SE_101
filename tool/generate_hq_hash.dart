// Run with: dart run tool/generate_hq_hash.dart
// Generates the PBKDF2 hash for the HQ access code using the same
// algorithm as app_database.dart hashPassword().

import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

String _generateSalt([int length = 16]) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

String _hashPasswordWithSalt(String password, String salt) {
  const int iterations = 100000;
  const int keyLength = 32;

  final hmac = Hmac(sha256, utf8.encode(password));
  final saltBytes = utf8.encode(salt);

  List<int> int32ToBytes(int i) => [
        (i >> 24) & 0xff,
        (i >> 16) & 0xff,
        (i >> 8) & 0xff,
        i & 0xff,
      ];

  final blockIndexBytes = int32ToBytes(1);
  var u = hmac.convert([...saltBytes, ...blockIndexBytes]).bytes;
  final List<int> derivedBlock = List<int>.from(u);

  for (int i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (int j = 0; j < derivedBlock.length; j++) {
      derivedBlock[j] ^= u[j];
    }
  }

  final dk = derivedBlock.sublist(0, keyLength);
  final hashHex = dk.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '$salt\$$hashHex';
}

String hashPassword(String password) {
  final salt = _generateSalt();
  return _hashPasswordWithSalt(password, salt);
}

bool verifyPassword(String password, String storedHash) {
  final parts = storedHash.split('\$');
  if (parts.length != 2) return false;
  final salt = parts[0];
  final expected = _hashPasswordWithSalt(password, salt);
  if (storedHash.length != expected.length) return false;
  int result = 0;
  for (int i = 0; i < storedHash.length; i++) {
    result |= storedHash.codeUnitAt(i) ^ expected.codeUnitAt(i);
  }
  return result == 0;
}

void main() {
  const code = '123456';
  print('Generating hash for access code: "$code"');
  print('(This uses 100,000 PBKDF2 iterations — may take a few seconds...)\n');

  final hash = hashPassword(code);
  print('Hash: $hash\n');

  // Verify it round-trips correctly
  final ok = verifyPassword(code, hash);
  print('Verification: ${ok ? "✅ PASSED" : "❌ FAILED"}\n');

  print('Run this SQL in Supabase:');
  print("UPDATE organizations");
  print("SET hq_access_code_hash = '\$hash'");
  print("WHERE type = 'commissary' AND local_id = 1;");
}
