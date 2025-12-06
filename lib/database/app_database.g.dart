// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    lastUpdated,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isDeleted;
  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, createdAt, lastUpdated, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _soldMeta = const VerificationMeta('sold');
  @override
  late final GeneratedColumn<int> sold = GeneratedColumn<int>(
    'sold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _spoilageMeta = const VerificationMeta(
    'spoilage',
  );
  @override
  late final GeneratedColumn<int> spoilage = GeneratedColumn<int>(
    'spoilage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryId,
    stock,
    sold,
    spoilage,
    createdAt,
    lastUpdated,
    isSynced,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('sold')) {
      context.handle(
        _soldMeta,
        sold.isAcceptableOrUnknown(data['sold']!, _soldMeta),
      );
    }
    if (data.containsKey('spoilage')) {
      context.handle(
        _spoilageMeta,
        spoilage.isAcceptableOrUnknown(data['spoilage']!, _spoilageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      sold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sold'],
      )!,
      spoilage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spoilage'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final String name;
  final int? categoryId;
  final int stock;
  final int sold;
  final int spoilage;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  const Item({
    required this.id,
    required this.name,
    this.categoryId,
    required this.stock,
    required this.sold,
    required this.spoilage,
    required this.createdAt,
    required this.lastUpdated,
    required this.isSynced,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['stock'] = Variable<int>(stock);
    map['sold'] = Variable<int>(sold);
    map['spoilage'] = Variable<int>(spoilage);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      stock: Value(stock),
      sold: Value(sold),
      spoilage: Value(spoilage),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      stock: serializer.fromJson<int>(json['stock']),
      sold: serializer.fromJson<int>(json['sold']),
      spoilage: serializer.fromJson<int>(json['spoilage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int?>(categoryId),
      'stock': serializer.toJson<int>(stock),
      'sold': serializer.toJson<int>(sold),
      'spoilage': serializer.toJson<int>(spoilage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Item copyWith({
    int? id,
    String? name,
    Value<int?> categoryId = const Value.absent(),
    int? stock,
    int? sold,
    int? spoilage,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isSynced,
    bool? isDeleted,
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    stock: stock ?? this.stock,
    sold: sold ?? this.sold,
    spoilage: spoilage ?? this.spoilage,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      stock: data.stock.present ? data.stock.value : this.stock,
      sold: data.sold.present ? data.sold.value : this.sold,
      spoilage: data.spoilage.present ? data.spoilage.value : this.spoilage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    categoryId,
    stock,
    sold,
    spoilage,
    createdAt,
    lastUpdated,
    isSynced,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.stock == this.stock &&
          other.sold == this.sold &&
          other.spoilage == this.spoilage &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> categoryId;
  final Value<int> stock;
  final Value<int> sold;
  final Value<int> spoilage;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.categoryId = const Value.absent(),
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? stock,
    Expression<int>? sold,
    Expression<int>? spoilage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (stock != null) 'stock': stock,
      if (sold != null) 'sold': sold,
      if (spoilage != null) 'spoilage': spoilage,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? categoryId,
    Value<int>? stock,
    Value<int>? sold,
    Value<int>? spoilage,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      spoilage: spoilage ?? this.spoilage,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (sold.present) {
      map['sold'] = Variable<int>(sold.value);
    }
    if (spoilage.present) {
      map['spoilage'] = Variable<int>(spoilage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, Role> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canViewInventoryMeta = const VerificationMeta(
    'canViewInventory',
  );
  @override
  late final GeneratedColumn<bool> canViewInventory = GeneratedColumn<bool>(
    'can_view_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_view_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canAddInventoryMeta = const VerificationMeta(
    'canAddInventory',
  );
  @override
  late final GeneratedColumn<bool> canAddInventory = GeneratedColumn<bool>(
    'can_add_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_add_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canEditInventoryMeta = const VerificationMeta(
    'canEditInventory',
  );
  @override
  late final GeneratedColumn<bool> canEditInventory = GeneratedColumn<bool>(
    'can_edit_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_edit_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canDeleteInventoryMeta =
      const VerificationMeta('canDeleteInventory');
  @override
  late final GeneratedColumn<bool> canDeleteInventory = GeneratedColumn<bool>(
    'can_delete_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_delete_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canViewReportsMeta = const VerificationMeta(
    'canViewReports',
  );
  @override
  late final GeneratedColumn<bool> canViewReports = GeneratedColumn<bool>(
    'can_view_reports',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_view_reports" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canExportDataMeta = const VerificationMeta(
    'canExportData',
  );
  @override
  late final GeneratedColumn<bool> canExportData = GeneratedColumn<bool>(
    'can_export_data',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_export_data" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canAccessSettingsMeta = const VerificationMeta(
    'canAccessSettings',
  );
  @override
  late final GeneratedColumn<bool> canAccessSettings = GeneratedColumn<bool>(
    'can_access_settings',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_access_settings" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSystemRoleMeta = const VerificationMeta(
    'isSystemRole',
  );
  @override
  late final GeneratedColumn<bool> isSystemRole = GeneratedColumn<bool>(
    'is_system_role',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_role" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _canManageEmployeesMeta =
      const VerificationMeta('canManageEmployees');
  @override
  late final GeneratedColumn<bool> canManageEmployees = GeneratedColumn<bool>(
    'can_manage_employees',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage_employees" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canManageRolesMeta = const VerificationMeta(
    'canManageRoles',
  );
  @override
  late final GeneratedColumn<bool> canManageRoles = GeneratedColumn<bool>(
    'can_manage_roles',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage_roles" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    canViewInventory,
    canAddInventory,
    canEditInventory,
    canDeleteInventory,
    canViewReports,
    canExportData,
    canAccessSettings,
    createdAt,
    lastUpdated,
    isSystemRole,
    isActive,
    canManageEmployees,
    canManageRoles,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Role> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('can_view_inventory')) {
      context.handle(
        _canViewInventoryMeta,
        canViewInventory.isAcceptableOrUnknown(
          data['can_view_inventory']!,
          _canViewInventoryMeta,
        ),
      );
    }
    if (data.containsKey('can_add_inventory')) {
      context.handle(
        _canAddInventoryMeta,
        canAddInventory.isAcceptableOrUnknown(
          data['can_add_inventory']!,
          _canAddInventoryMeta,
        ),
      );
    }
    if (data.containsKey('can_edit_inventory')) {
      context.handle(
        _canEditInventoryMeta,
        canEditInventory.isAcceptableOrUnknown(
          data['can_edit_inventory']!,
          _canEditInventoryMeta,
        ),
      );
    }
    if (data.containsKey('can_delete_inventory')) {
      context.handle(
        _canDeleteInventoryMeta,
        canDeleteInventory.isAcceptableOrUnknown(
          data['can_delete_inventory']!,
          _canDeleteInventoryMeta,
        ),
      );
    }
    if (data.containsKey('can_view_reports')) {
      context.handle(
        _canViewReportsMeta,
        canViewReports.isAcceptableOrUnknown(
          data['can_view_reports']!,
          _canViewReportsMeta,
        ),
      );
    }
    if (data.containsKey('can_export_data')) {
      context.handle(
        _canExportDataMeta,
        canExportData.isAcceptableOrUnknown(
          data['can_export_data']!,
          _canExportDataMeta,
        ),
      );
    }
    if (data.containsKey('can_access_settings')) {
      context.handle(
        _canAccessSettingsMeta,
        canAccessSettings.isAcceptableOrUnknown(
          data['can_access_settings']!,
          _canAccessSettingsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_system_role')) {
      context.handle(
        _isSystemRoleMeta,
        isSystemRole.isAcceptableOrUnknown(
          data['is_system_role']!,
          _isSystemRoleMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('can_manage_employees')) {
      context.handle(
        _canManageEmployeesMeta,
        canManageEmployees.isAcceptableOrUnknown(
          data['can_manage_employees']!,
          _canManageEmployeesMeta,
        ),
      );
    }
    if (data.containsKey('can_manage_roles')) {
      context.handle(
        _canManageRolesMeta,
        canManageRoles.isAcceptableOrUnknown(
          data['can_manage_roles']!,
          _canManageRolesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Role map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Role(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      canViewInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_view_inventory'],
      )!,
      canAddInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_add_inventory'],
      )!,
      canEditInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_edit_inventory'],
      )!,
      canDeleteInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_delete_inventory'],
      )!,
      canViewReports: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_view_reports'],
      )!,
      canExportData: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_export_data'],
      )!,
      canAccessSettings: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_access_settings'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isSystemRole: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      canManageEmployees: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_employees'],
      )!,
      canManageRoles: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_roles'],
      )!,
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class Role extends DataClass implements Insertable<Role> {
  final int id;
  final String name;
  final String? description;
  final bool canViewInventory;
  final bool canAddInventory;
  final bool canEditInventory;
  final bool canDeleteInventory;
  final bool canViewReports;
  final bool canExportData;
  final bool canAccessSettings;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isSystemRole;
  final bool isActive;
  final bool canManageEmployees;
  final bool canManageRoles;
  const Role({
    required this.id,
    required this.name,
    this.description,
    required this.canViewInventory,
    required this.canAddInventory,
    required this.canEditInventory,
    required this.canDeleteInventory,
    required this.canViewReports,
    required this.canExportData,
    required this.canAccessSettings,
    required this.createdAt,
    required this.lastUpdated,
    required this.isSystemRole,
    required this.isActive,
    required this.canManageEmployees,
    required this.canManageRoles,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['can_view_inventory'] = Variable<bool>(canViewInventory);
    map['can_add_inventory'] = Variable<bool>(canAddInventory);
    map['can_edit_inventory'] = Variable<bool>(canEditInventory);
    map['can_delete_inventory'] = Variable<bool>(canDeleteInventory);
    map['can_view_reports'] = Variable<bool>(canViewReports);
    map['can_export_data'] = Variable<bool>(canExportData);
    map['can_access_settings'] = Variable<bool>(canAccessSettings);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_system_role'] = Variable<bool>(isSystemRole);
    map['is_active'] = Variable<bool>(isActive);
    map['can_manage_employees'] = Variable<bool>(canManageEmployees);
    map['can_manage_roles'] = Variable<bool>(canManageRoles);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      canViewInventory: Value(canViewInventory),
      canAddInventory: Value(canAddInventory),
      canEditInventory: Value(canEditInventory),
      canDeleteInventory: Value(canDeleteInventory),
      canViewReports: Value(canViewReports),
      canExportData: Value(canExportData),
      canAccessSettings: Value(canAccessSettings),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isSystemRole: Value(isSystemRole),
      isActive: Value(isActive),
      canManageEmployees: Value(canManageEmployees),
      canManageRoles: Value(canManageRoles),
    );
  }

  factory Role.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Role(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      canViewInventory: serializer.fromJson<bool>(json['canViewInventory']),
      canAddInventory: serializer.fromJson<bool>(json['canAddInventory']),
      canEditInventory: serializer.fromJson<bool>(json['canEditInventory']),
      canDeleteInventory: serializer.fromJson<bool>(json['canDeleteInventory']),
      canViewReports: serializer.fromJson<bool>(json['canViewReports']),
      canExportData: serializer.fromJson<bool>(json['canExportData']),
      canAccessSettings: serializer.fromJson<bool>(json['canAccessSettings']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSystemRole: serializer.fromJson<bool>(json['isSystemRole']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      canManageEmployees: serializer.fromJson<bool>(json['canManageEmployees']),
      canManageRoles: serializer.fromJson<bool>(json['canManageRoles']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'canViewInventory': serializer.toJson<bool>(canViewInventory),
      'canAddInventory': serializer.toJson<bool>(canAddInventory),
      'canEditInventory': serializer.toJson<bool>(canEditInventory),
      'canDeleteInventory': serializer.toJson<bool>(canDeleteInventory),
      'canViewReports': serializer.toJson<bool>(canViewReports),
      'canExportData': serializer.toJson<bool>(canExportData),
      'canAccessSettings': serializer.toJson<bool>(canAccessSettings),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSystemRole': serializer.toJson<bool>(isSystemRole),
      'isActive': serializer.toJson<bool>(isActive),
      'canManageEmployees': serializer.toJson<bool>(canManageEmployees),
      'canManageRoles': serializer.toJson<bool>(canManageRoles),
    };
  }

  Role copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? canViewInventory,
    bool? canAddInventory,
    bool? canEditInventory,
    bool? canDeleteInventory,
    bool? canViewReports,
    bool? canExportData,
    bool? canAccessSettings,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isSystemRole,
    bool? isActive,
    bool? canManageEmployees,
    bool? canManageRoles,
  }) => Role(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    canViewInventory: canViewInventory ?? this.canViewInventory,
    canAddInventory: canAddInventory ?? this.canAddInventory,
    canEditInventory: canEditInventory ?? this.canEditInventory,
    canDeleteInventory: canDeleteInventory ?? this.canDeleteInventory,
    canViewReports: canViewReports ?? this.canViewReports,
    canExportData: canExportData ?? this.canExportData,
    canAccessSettings: canAccessSettings ?? this.canAccessSettings,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isSystemRole: isSystemRole ?? this.isSystemRole,
    isActive: isActive ?? this.isActive,
    canManageEmployees: canManageEmployees ?? this.canManageEmployees,
    canManageRoles: canManageRoles ?? this.canManageRoles,
  );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      canViewInventory: data.canViewInventory.present
          ? data.canViewInventory.value
          : this.canViewInventory,
      canAddInventory: data.canAddInventory.present
          ? data.canAddInventory.value
          : this.canAddInventory,
      canEditInventory: data.canEditInventory.present
          ? data.canEditInventory.value
          : this.canEditInventory,
      canDeleteInventory: data.canDeleteInventory.present
          ? data.canDeleteInventory.value
          : this.canDeleteInventory,
      canViewReports: data.canViewReports.present
          ? data.canViewReports.value
          : this.canViewReports,
      canExportData: data.canExportData.present
          ? data.canExportData.value
          : this.canExportData,
      canAccessSettings: data.canAccessSettings.present
          ? data.canAccessSettings.value
          : this.canAccessSettings,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isSystemRole: data.isSystemRole.present
          ? data.isSystemRole.value
          : this.isSystemRole,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      canManageEmployees: data.canManageEmployees.present
          ? data.canManageEmployees.value
          : this.canManageEmployees,
      canManageRoles: data.canManageRoles.present
          ? data.canManageRoles.value
          : this.canManageRoles,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('canViewInventory: $canViewInventory, ')
          ..write('canAddInventory: $canAddInventory, ')
          ..write('canEditInventory: $canEditInventory, ')
          ..write('canDeleteInventory: $canDeleteInventory, ')
          ..write('canViewReports: $canViewReports, ')
          ..write('canExportData: $canExportData, ')
          ..write('canAccessSettings: $canAccessSettings, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSystemRole: $isSystemRole, ')
          ..write('isActive: $isActive, ')
          ..write('canManageEmployees: $canManageEmployees, ')
          ..write('canManageRoles: $canManageRoles')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    canViewInventory,
    canAddInventory,
    canEditInventory,
    canDeleteInventory,
    canViewReports,
    canExportData,
    canAccessSettings,
    createdAt,
    lastUpdated,
    isSystemRole,
    isActive,
    canManageEmployees,
    canManageRoles,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.canViewInventory == this.canViewInventory &&
          other.canAddInventory == this.canAddInventory &&
          other.canEditInventory == this.canEditInventory &&
          other.canDeleteInventory == this.canDeleteInventory &&
          other.canViewReports == this.canViewReports &&
          other.canExportData == this.canExportData &&
          other.canAccessSettings == this.canAccessSettings &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isSystemRole == this.isSystemRole &&
          other.isActive == this.isActive &&
          other.canManageEmployees == this.canManageEmployees &&
          other.canManageRoles == this.canManageRoles);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> canViewInventory;
  final Value<bool> canAddInventory;
  final Value<bool> canEditInventory;
  final Value<bool> canDeleteInventory;
  final Value<bool> canViewReports;
  final Value<bool> canExportData;
  final Value<bool> canAccessSettings;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSystemRole;
  final Value<bool> isActive;
  final Value<bool> canManageEmployees;
  final Value<bool> canManageRoles;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.canViewInventory = const Value.absent(),
    this.canAddInventory = const Value.absent(),
    this.canEditInventory = const Value.absent(),
    this.canDeleteInventory = const Value.absent(),
    this.canViewReports = const Value.absent(),
    this.canExportData = const Value.absent(),
    this.canAccessSettings = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSystemRole = const Value.absent(),
    this.isActive = const Value.absent(),
    this.canManageEmployees = const Value.absent(),
    this.canManageRoles = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.canViewInventory = const Value.absent(),
    this.canAddInventory = const Value.absent(),
    this.canEditInventory = const Value.absent(),
    this.canDeleteInventory = const Value.absent(),
    this.canViewReports = const Value.absent(),
    this.canExportData = const Value.absent(),
    this.canAccessSettings = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSystemRole = const Value.absent(),
    this.isActive = const Value.absent(),
    this.canManageEmployees = const Value.absent(),
    this.canManageRoles = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Role> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? canViewInventory,
    Expression<bool>? canAddInventory,
    Expression<bool>? canEditInventory,
    Expression<bool>? canDeleteInventory,
    Expression<bool>? canViewReports,
    Expression<bool>? canExportData,
    Expression<bool>? canAccessSettings,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSystemRole,
    Expression<bool>? isActive,
    Expression<bool>? canManageEmployees,
    Expression<bool>? canManageRoles,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (canViewInventory != null) 'can_view_inventory': canViewInventory,
      if (canAddInventory != null) 'can_add_inventory': canAddInventory,
      if (canEditInventory != null) 'can_edit_inventory': canEditInventory,
      if (canDeleteInventory != null)
        'can_delete_inventory': canDeleteInventory,
      if (canViewReports != null) 'can_view_reports': canViewReports,
      if (canExportData != null) 'can_export_data': canExportData,
      if (canAccessSettings != null) 'can_access_settings': canAccessSettings,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSystemRole != null) 'is_system_role': isSystemRole,
      if (isActive != null) 'is_active': isActive,
      if (canManageEmployees != null)
        'can_manage_employees': canManageEmployees,
      if (canManageRoles != null) 'can_manage_roles': canManageRoles,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? canViewInventory,
    Value<bool>? canAddInventory,
    Value<bool>? canEditInventory,
    Value<bool>? canDeleteInventory,
    Value<bool>? canViewReports,
    Value<bool>? canExportData,
    Value<bool>? canAccessSettings,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isSystemRole,
    Value<bool>? isActive,
    Value<bool>? canManageEmployees,
    Value<bool>? canManageRoles,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      canViewInventory: canViewInventory ?? this.canViewInventory,
      canAddInventory: canAddInventory ?? this.canAddInventory,
      canEditInventory: canEditInventory ?? this.canEditInventory,
      canDeleteInventory: canDeleteInventory ?? this.canDeleteInventory,
      canViewReports: canViewReports ?? this.canViewReports,
      canExportData: canExportData ?? this.canExportData,
      canAccessSettings: canAccessSettings ?? this.canAccessSettings,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSystemRole: isSystemRole ?? this.isSystemRole,
      isActive: isActive ?? this.isActive,
      canManageEmployees: canManageEmployees ?? this.canManageEmployees,
      canManageRoles: canManageRoles ?? this.canManageRoles,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (canViewInventory.present) {
      map['can_view_inventory'] = Variable<bool>(canViewInventory.value);
    }
    if (canAddInventory.present) {
      map['can_add_inventory'] = Variable<bool>(canAddInventory.value);
    }
    if (canEditInventory.present) {
      map['can_edit_inventory'] = Variable<bool>(canEditInventory.value);
    }
    if (canDeleteInventory.present) {
      map['can_delete_inventory'] = Variable<bool>(canDeleteInventory.value);
    }
    if (canViewReports.present) {
      map['can_view_reports'] = Variable<bool>(canViewReports.value);
    }
    if (canExportData.present) {
      map['can_export_data'] = Variable<bool>(canExportData.value);
    }
    if (canAccessSettings.present) {
      map['can_access_settings'] = Variable<bool>(canAccessSettings.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSystemRole.present) {
      map['is_system_role'] = Variable<bool>(isSystemRole.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (canManageEmployees.present) {
      map['can_manage_employees'] = Variable<bool>(canManageEmployees.value);
    }
    if (canManageRoles.present) {
      map['can_manage_roles'] = Variable<bool>(canManageRoles.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('canViewInventory: $canViewInventory, ')
          ..write('canAddInventory: $canAddInventory, ')
          ..write('canEditInventory: $canEditInventory, ')
          ..write('canDeleteInventory: $canDeleteInventory, ')
          ..write('canViewReports: $canViewReports, ')
          ..write('canExportData: $canExportData, ')
          ..write('canAccessSettings: $canAccessSettings, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSystemRole: $isSystemRole, ')
          ..write('isActive: $isActive, ')
          ..write('canManageEmployees: $canManageEmployees, ')
          ..write('canManageRoles: $canManageRoles')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roles (id)',
    ),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    username,
    password,
    phone,
    roleId,
    isActive,
    createdAt,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String email;
  final String username;
  final String password;
  final String? phone;
  final int roleId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastUpdated;
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    this.phone,
    required this.roleId,
    required this.isActive,
    required this.createdAt,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['role_id'] = Variable<int>(roleId);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      username: Value(username),
      password: Value(password),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      roleId: Value(roleId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      phone: serializer.fromJson<String?>(json['phone']),
      roleId: serializer.fromJson<int>(json['roleId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'phone': serializer.toJson<String?>(phone),
      'roleId': serializer.toJson<int>(roleId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? password,
    Value<String?> phone = const Value.absent(),
    int? roleId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    username: username ?? this.username,
    password: password ?? this.password,
    phone: phone.present ? phone.value : this.phone,
    roleId: roleId ?? this.roleId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      phone: data.phone.present ? data.phone.value : this.phone,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('phone: $phone, ')
          ..write('roleId: $roleId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    username,
    password,
    phone,
    roleId,
    isActive,
    createdAt,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.username == this.username &&
          other.password == this.password &&
          other.phone == this.phone &&
          other.roleId == this.roleId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> username;
  final Value<String> password;
  final Value<String?> phone;
  final Value<int> roleId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.phone = const Value.absent(),
    this.roleId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String username,
    required String password,
    this.phone = const Value.absent(),
    required int roleId,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  }) : email = Value(email),
       username = Value(username),
       password = Value(password),
       roleId = Value(roleId);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? phone,
    Expression<int>? roleId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (phone != null) 'phone': phone,
      if (roleId != null) 'role_id': roleId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? username,
    Value<String>? password,
    Value<String?>? phone,
    Value<int>? roleId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('phone: $phone, ')
          ..write('roleId: $roleId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final RolesDao rolesDao = RolesDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    items,
    roles,
    users,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<Item>> _itemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.items,
    aliasName: $_aliasNameGenerator(db.categories.id, db.items.categoryId),
  );

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemsRefs(
    Expression<bool> Function($$ItemsTableFilterComposer f) f,
  ) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
    Expression<T> Function($$ItemsTableAnnotationComposer a) f,
  ) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool itemsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable, Item>(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._itemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(db, table, p0).itemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool itemsRefs})
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> categoryId,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<bool> isDeleted,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> categoryId,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<bool> isDeleted,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias($_aliasNameGenerator(db.items.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sold => $composableBuilder(
    column: $table.sold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spoilage => $composableBuilder(
    column: $table.spoilage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sold => $composableBuilder(
    column: $table.sold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spoilage => $composableBuilder(
    column: $table.spoilage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get sold =>
      $composableBuilder(column: $table.sold, builder: (column) => column);

  GeneratedColumn<int> get spoilage =>
      $composableBuilder(column: $table.spoilage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, $$ItemsTableReferences),
          Item,
          PrefetchHooks Function({bool categoryId})
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                categoryId: categoryId,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> categoryId = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                categoryId: categoryId,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ItemsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$ItemsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$ItemsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, $$ItemsTableReferences),
      Item,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<bool> canViewInventory,
      Value<bool> canAddInventory,
      Value<bool> canEditInventory,
      Value<bool> canDeleteInventory,
      Value<bool> canViewReports,
      Value<bool> canExportData,
      Value<bool> canAccessSettings,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSystemRole,
      Value<bool> isActive,
      Value<bool> canManageEmployees,
      Value<bool> canManageRoles,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<bool> canViewInventory,
      Value<bool> canAddInventory,
      Value<bool> canEditInventory,
      Value<bool> canDeleteInventory,
      Value<bool> canViewReports,
      Value<bool> canExportData,
      Value<bool> canAccessSettings,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSystemRole,
      Value<bool> isActive,
      Value<bool> canManageEmployees,
      Value<bool> canManageRoles,
    });

final class $$RolesTableReferences
    extends BaseReferences<_$AppDatabase, $RolesTable, Role> {
  $$RolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UsersTable, List<User>> _usersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.users,
    aliasName: $_aliasNameGenerator(db.roles.id, db.users.roleId),
  );

  $$UsersTableProcessedTableManager get usersRefs {
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_usersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canViewInventory => $composableBuilder(
    column: $table.canViewInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canAddInventory => $composableBuilder(
    column: $table.canAddInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canEditInventory => $composableBuilder(
    column: $table.canEditInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canDeleteInventory => $composableBuilder(
    column: $table.canDeleteInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canExportData => $composableBuilder(
    column: $table.canExportData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canAccessSettings => $composableBuilder(
    column: $table.canAccessSettings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> usersRefs(
    Expression<bool> Function($$UsersTableFilterComposer f) f,
  ) {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canViewInventory => $composableBuilder(
    column: $table.canViewInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canAddInventory => $composableBuilder(
    column: $table.canAddInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canEditInventory => $composableBuilder(
    column: $table.canEditInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canDeleteInventory => $composableBuilder(
    column: $table.canDeleteInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canExportData => $composableBuilder(
    column: $table.canExportData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canAccessSettings => $composableBuilder(
    column: $table.canAccessSettings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canViewInventory => $composableBuilder(
    column: $table.canViewInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canAddInventory => $composableBuilder(
    column: $table.canAddInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canEditInventory => $composableBuilder(
    column: $table.canEditInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canDeleteInventory => $composableBuilder(
    column: $table.canDeleteInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canExportData => $composableBuilder(
    column: $table.canExportData,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canAccessSettings => $composableBuilder(
    column: $table.canAccessSettings,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => column,
  );

  Expression<T> usersRefs<T extends Object>(
    Expression<T> Function($$UsersTableAnnotationComposer a) f,
  ) {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolesTable,
          Role,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (Role, $$RolesTableReferences),
          Role,
          PrefetchHooks Function({bool usersRefs})
        > {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> canViewInventory = const Value.absent(),
                Value<bool> canAddInventory = const Value.absent(),
                Value<bool> canEditInventory = const Value.absent(),
                Value<bool> canDeleteInventory = const Value.absent(),
                Value<bool> canViewReports = const Value.absent(),
                Value<bool> canExportData = const Value.absent(),
                Value<bool> canAccessSettings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> canManageEmployees = const Value.absent(),
                Value<bool> canManageRoles = const Value.absent(),
              }) => RolesCompanion(
                id: id,
                name: name,
                description: description,
                canViewInventory: canViewInventory,
                canAddInventory: canAddInventory,
                canEditInventory: canEditInventory,
                canDeleteInventory: canDeleteInventory,
                canViewReports: canViewReports,
                canExportData: canExportData,
                canAccessSettings: canAccessSettings,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSystemRole: isSystemRole,
                isActive: isActive,
                canManageEmployees: canManageEmployees,
                canManageRoles: canManageRoles,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> canViewInventory = const Value.absent(),
                Value<bool> canAddInventory = const Value.absent(),
                Value<bool> canEditInventory = const Value.absent(),
                Value<bool> canDeleteInventory = const Value.absent(),
                Value<bool> canViewReports = const Value.absent(),
                Value<bool> canExportData = const Value.absent(),
                Value<bool> canAccessSettings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> canManageEmployees = const Value.absent(),
                Value<bool> canManageRoles = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                name: name,
                description: description,
                canViewInventory: canViewInventory,
                canAddInventory: canAddInventory,
                canEditInventory: canEditInventory,
                canDeleteInventory: canDeleteInventory,
                canViewReports: canViewReports,
                canExportData: canExportData,
                canAccessSettings: canAccessSettings,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSystemRole: isSystemRole,
                isActive: isActive,
                canManageEmployees: canManageEmployees,
                canManageRoles: canManageRoles,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RolesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({usersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (usersRefs) db.users],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (usersRefs)
                    await $_getPrefetchedData<Role, $RolesTable, User>(
                      currentTable: table,
                      referencedTable: $$RolesTableReferences._usersRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$RolesTableReferences(db, table, p0).usersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolesTable,
      Role,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (Role, $$RolesTableReferences),
      Role,
      PrefetchHooks Function({bool usersRefs})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String email,
      required String username,
      required String password,
      Value<String?> phone,
      required int roleId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> username,
      Value<String> password,
      Value<String?> phone,
      Value<int> roleId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RolesTable _roleIdTable(_$AppDatabase db) =>
      db.roles.createAlias($_aliasNameGenerator(db.users.roleId, db.roles.id));

  $$RolesTableProcessedTableManager get roleId {
    final $_column = $_itemColumn<int>('role_id')!;

    final manager = $$RolesTableTableManager(
      $_db,
      $_db.roles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  $$RolesTableFilterComposer get roleId {
    final $$RolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableFilterComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  $$RolesTableOrderingComposer get roleId {
    final $$RolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableOrderingComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  $$RolesTableAnnotationComposer get roleId {
    final $$RolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableAnnotationComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool roleId})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                username: username,
                password: password,
                phone: phone,
                roleId: roleId,
                isActive: isActive,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String username,
                required String password,
                Value<String?> phone = const Value.absent(),
                required int roleId,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                username: username,
                password: password,
                phone: phone,
                roleId: roleId,
                isActive: isActive,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({roleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roleId,
                                referencedTable: $$UsersTableReferences
                                    ._roleIdTable(db),
                                referencedColumn: $$UsersTableReferences
                                    ._roleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool roleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
