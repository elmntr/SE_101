// lib/services/sync/sync_conflict.dart

/// Conflict resolution strategies for sync operations
enum ConflictResolution {
  /// Use the record with the most recent lastUpdated timestamp (default)
  lastWriteWins,

  /// Always prefer the cloud version
  cloudWins,

  /// Always prefer the local version
  localWins,

  /// For status-based entities: prefer more advanced status, fallback to lastUpdated
  /// Status hierarchy: approved > rejected > pending > draft
  statusAware,

  /// Log conflict for manual review (no auto-resolution)
  manual,
}

/// Types of sync conflicts that can occur
enum ConflictType {
  /// Both local and cloud have changes since last sync
  bothModified,

  /// Local record was deleted but cloud has updates
  localDeletedCloudModified,

  /// Cloud record was deleted but local has updates
  cloudDeletedLocalModified,

  /// Status field conflict (for statusAware resolution)
  statusConflict,
}

/// Represents a sync conflict record for audit/review
class SyncConflictRecord {
  final int? id;
  final String tableName;
  final String cloudId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> cloudData;
  final ConflictType conflictType;
  final String? resolution;
  final int? organizationId;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SyncConflictRecord({
    this.id,
    required this.tableName,
    required this.cloudId,
    required this.localData,
    required this.cloudData,
    required this.conflictType,
    this.resolution,
    this.organizationId,
    DateTime? createdAt,
    this.resolvedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  /// Create from database row
  factory SyncConflictRecord.fromDb(Map<String, dynamic> row) {
    return SyncConflictRecord(
      id: row['id'] as int?,
      tableName: row['table_name'] as String,
      cloudId: row['cloud_id'] as String,
      localData: _parseJson(row['local_data']),
      cloudData: _parseJson(row['cloud_data']),
      conflictType: ConflictType.values.firstWhere(
        (e) => e.name == row['conflict_type'],
        orElse: () => ConflictType.bothModified,
      ),
      resolution: row['resolution'] as String?,
      organizationId: row['organization_id'] as int?,
      createdAt: DateTime.parse(row['created_at'] as String),
      resolvedAt: row['resolved_at'] != null
          ? DateTime.parse(row['resolved_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> _parseJson(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return Map<String, dynamic>.from(
          const JsonDecoder().convert(value) as Map,
        );
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  /// Convert to map for database insertion
  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'table_name': tableName,
      'cloud_id': cloudId,
      'local_data': const JsonEncoder().convert(localData),
      'cloud_data': const JsonEncoder().convert(cloudData),
      'conflict_type': conflictType.name,
      'resolution': resolution,
      'organization_id': organizationId,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  /// Check if conflict is resolved
  bool get isResolved => resolvedAt != null;

  /// Get a human-readable summary
  String get summary {
    final localUpdated = localData['last_updated'] ?? 'unknown';
    final cloudUpdated = cloudData['last_updated'] ?? 'unknown';
    return '$tableName conflict: local=$localUpdated, cloud=$cloudUpdated';
  }

  @override
  String toString() =>
      'SyncConflictRecord($tableName, $cloudId, $conflictType)';
}

/// Custom JSON encoder for sync conflict data.
///
/// WHY CUSTOM IMPLEMENTATION:
/// This custom encoder is used instead of dart:convert's jsonEncode() because:
/// 1. Handles DateTime objects directly (converts to ISO8601 strings)
/// 2. Provides consistent encoding for sync conflict records stored in SQLite
/// 3. Ensures all data types used in sync records are properly serialized
///
/// The standard dart:convert jsonEncode() throws on DateTime and other non-primitive types.
/// While we could use a custom encoder function with jsonEncode(), this implementation
/// keeps the encoding logic self-contained and consistent with fromDb() parsing.
class JsonEncoder {
  const JsonEncoder();

  String convert(Map<String, dynamic> data) {
    return _encodeValue(data);
  }

  String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num || value is bool) return value.toString();
    if (value is DateTime) return '"${value.toIso8601String()}"';
    if (value is List) {
      final items = value.map(_encodeValue).join(',');
      return '[$items]';
    }
    if (value is Map) {
      final entries = value.entries
          .map((e) => '"${e.key}":${_encodeValue(e.value)}')
          .join(',');
      return '{$entries}';
    }
    return '"$value"';
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}

/// Custom JSON decoder for sync conflict data.
///
/// WHY CUSTOM IMPLEMENTATION:
/// Paired with the custom JsonEncoder above. While dart:convert's jsonDecode()
/// could be used for basic JSON parsing, this decoder:
/// 1. Provides symmetric handling with JsonEncoder
/// 2. Enables consistent error handling during sync conflict resolution
/// 3. Can be extended to handle special types (like DateTime parsing) if needed
///
/// TODO: Consider migrating to dart:convert if DateTime handling is moved to
/// the fromDb()/toDbMap() layer instead.
class JsonDecoder {
  const JsonDecoder();

  dynamic convert(String json) {
    return _parseValue(json.trim(), 0).$1;
  }

  (dynamic, int) _parseValue(String json, int index) {
    if (index >= json.length) return (null, index);

    final char = json[index];
    if (char == '{') return _parseObject(json, index);
    if (char == '[') return _parseArray(json, index);
    if (char == '"') return _parseString(json, index);
    if (char == 't' || char == 'f') return _parseBool(json, index);
    if (char == 'n') return _parseNull(json, index);
    if (char == '-' || (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57)) {
      return _parseNumber(json, index);
    }

    return (null, index);
  }

  (Map<String, dynamic>, int) _parseObject(String json, int index) {
    final result = <String, dynamic>{};
    index++; // skip '{'

    while (index < json.length) {
      index = _skipWhitespace(json, index);
      if (json[index] == '}') return (result, index + 1);

      // Parse key
      final (key, keyEnd) = _parseString(json, index);
      index = _skipWhitespace(json, keyEnd);

      // Skip ':'
      if (json[index] == ':') index++;
      index = _skipWhitespace(json, index);

      // Parse value
      final (value, valueEnd) = _parseValue(json, index);
      result[key as String] = value;
      index = _skipWhitespace(json, valueEnd);

      // Skip ',' or end
      if (json[index] == ',') index++;
    }

    return (result, index);
  }

  (List<dynamic>, int) _parseArray(String json, int index) {
    final result = <dynamic>[];
    index++; // skip '['

    while (index < json.length) {
      index = _skipWhitespace(json, index);
      if (json[index] == ']') return (result, index + 1);

      final (value, valueEnd) = _parseValue(json, index);
      result.add(value);
      index = _skipWhitespace(json, valueEnd);

      if (json[index] == ',') index++;
    }

    return (result, index);
  }

  (String, int) _parseString(String json, int index) {
    index++; // skip opening '"'
    final buffer = StringBuffer();

    while (index < json.length) {
      final char = json[index];
      if (char == '"') return (buffer.toString(), index + 1);
      if (char == '\\' && index + 1 < json.length) {
        index++;
        final escaped = json[index];
        switch (escaped) {
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case '"':
            buffer.write('"');
            break;
          case '\\':
            buffer.write('\\');
            break;
          default:
            buffer.write(escaped);
        }
      } else {
        buffer.write(char);
      }
      index++;
    }

    return (buffer.toString(), index);
  }

  (num, int) _parseNumber(String json, int index) {
    final start = index;
    if (json[index] == '-') index++;

    while (index < json.length) {
      final char = json[index];
      if ((char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) ||
          char == '.' ||
          char == 'e' ||
          char == 'E' ||
          char == '+' ||
          char == '-') {
        index++;
      } else {
        break;
      }
    }

    final numStr = json.substring(start, index);
    if (numStr.contains('.') || numStr.contains('e') || numStr.contains('E')) {
      return (double.parse(numStr), index);
    }
    return (int.parse(numStr), index);
  }

  (bool, int) _parseBool(String json, int index) {
    if (json.substring(index).startsWith('true')) {
      return (true, index + 4);
    }
    return (false, index + 5);
  }

  (dynamic, int) _parseNull(String json, int index) {
    return (null, index + 4);
  }

  int _skipWhitespace(String json, int index) {
    while (index < json.length) {
      final char = json[index];
      if (char != ' ' && char != '\n' && char != '\r' && char != '\t') break;
      index++;
    }
    return index;
  }
}

/// Status hierarchy for statusAware conflict resolution
class StatusHierarchy {
  static const Map<String, int> _statusOrder = {
    'draft': 0,
    'pending': 1,
    'in_progress': 2,
    'rejected': 3,
    'approved': 4,
    'completed': 5,
    'cancelled': 6,
  };

  /// Compare two status values
  /// Returns positive if status1 > status2, negative if status1 < status2, 0 if equal
  static int compare(String? status1, String? status2) {
    final order1 = _statusOrder[status1?.toLowerCase()] ?? -1;
    final order2 = _statusOrder[status2?.toLowerCase()] ?? -1;
    return order1.compareTo(order2);
  }

  /// Check if status1 is more advanced than status2
  static bool isMoreAdvanced(String? status1, String? status2) {
    return compare(status1, status2) > 0;
  }
}
