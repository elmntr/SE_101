// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    stock,
    sold,
    spoilage,
    lastUpdated,
    isSynced,
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
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
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
  final int stock;
  final int sold;
  final int spoilage;
  final DateTime lastUpdated;
  final bool isSynced;
  const Item({
    required this.id,
    required this.name,
    required this.stock,
    required this.sold,
    required this.spoilage,
    required this.lastUpdated,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['stock'] = Variable<int>(stock);
    map['sold'] = Variable<int>(sold);
    map['spoilage'] = Variable<int>(spoilage);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      stock: Value(stock),
      sold: Value(sold),
      spoilage: Value(spoilage),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
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
      stock: serializer.fromJson<int>(json['stock']),
      sold: serializer.fromJson<int>(json['sold']),
      spoilage: serializer.fromJson<int>(json['spoilage']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stock': serializer.toJson<int>(stock),
      'sold': serializer.toJson<int>(sold),
      'spoilage': serializer.toJson<int>(spoilage),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Item copyWith({
    int? id,
    String? name,
    int? stock,
    int? sold,
    int? spoilage,
    DateTime? lastUpdated,
    bool? isSynced,
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    stock: stock ?? this.stock,
    sold: sold ?? this.sold,
    spoilage: spoilage ?? this.spoilage,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isSynced: isSynced ?? this.isSynced,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stock: data.stock.present ? data.stock.value : this.stock,
      sold: data.sold.present ? data.sold.value : this.sold,
      spoilage: data.spoilage.present ? data.spoilage.value : this.spoilage,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, stock, sold, spoilage, lastUpdated, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.stock == this.stock &&
          other.sold == this.sold &&
          other.spoilage == this.spoilage &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> stock;
  final Value<int> sold;
  final Value<int> spoilage;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? stock,
    Expression<int>? sold,
    Expression<int>? spoilage,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stock != null) 'stock': stock,
      if (sold != null) 'sold': sold,
      if (spoilage != null) 'spoilage': spoilage,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? stock,
    Value<int>? sold,
    Value<int>? spoilage,
    Value<DateTime>? lastUpdated,
    Value<bool>? isSynced,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      spoilage: spoilage ?? this.spoilage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
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
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (sold.present) {
      map['sold'] = Variable<int>(sold.value);
    }
    if (spoilage.present) {
      map['spoilage'] = Variable<int>(spoilage.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced')
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    name,
    phone,
    password,
    role,
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
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
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
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
  final String? name;
  final String? phone;
  final String password;
  final String role;
  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.password,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['password'] = Variable<String>(password);
    map['role'] = Variable<String>(role);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      password: Value(password),
      role: Value(role),
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
      name: serializer.fromJson<String?>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      password: serializer.fromJson<String>(json['password']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String?>(name),
      'phone': serializer.toJson<String?>(phone),
      'password': serializer.toJson<String>(password),
      'role': serializer.toJson<String>(role),
    };
  }

  User copyWith({
    int? id,
    String? email,
    Value<String?> name = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? password,
    String? role,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name.present ? name.value : this.name,
    phone: phone.present ? phone.value : this.phone,
    password: password ?? this.password,
    role: role ?? this.role,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      password: data.password.present ? data.password.value : this.password,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('password: $password, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, name, phone, password, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.password == this.password &&
          other.role == this.role);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> email;
  final Value<String?> name;
  final Value<String?> phone;
  final Value<String> password;
  final Value<String> role;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    required String password,
    required String role,
  }) : email = Value(email),
       password = Value(password),
       role = Value(role);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? password,
    Expression<String>? role,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String?>? name,
    Value<String?>? phone,
    Value<String>? password,
    Value<String>? role,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('password: $password, ')
          ..write('role: $role')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    canViewInventory,
    canAddInventory,
    canEditInventory,
    canDeleteInventory,
    canManageEmployees,
    canManageRoles,
    canViewReports,
    canAccessSettings,
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
    if (data.containsKey('can_view_reports')) {
      context.handle(
        _canViewReportsMeta,
        canViewReports.isAcceptableOrUnknown(
          data['can_view_reports']!,
          _canViewReportsMeta,
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
      canManageEmployees: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_employees'],
      )!,
      canManageRoles: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_roles'],
      )!,
      canViewReports: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_view_reports'],
      )!,
      canAccessSettings: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_access_settings'],
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
  final bool canViewInventory;
  final bool canAddInventory;
  final bool canEditInventory;
  final bool canDeleteInventory;
  final bool canManageEmployees;
  final bool canManageRoles;
  final bool canViewReports;
  final bool canAccessSettings;
  const Role({
    required this.id,
    required this.name,
    required this.canViewInventory,
    required this.canAddInventory,
    required this.canEditInventory,
    required this.canDeleteInventory,
    required this.canManageEmployees,
    required this.canManageRoles,
    required this.canViewReports,
    required this.canAccessSettings,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['can_view_inventory'] = Variable<bool>(canViewInventory);
    map['can_add_inventory'] = Variable<bool>(canAddInventory);
    map['can_edit_inventory'] = Variable<bool>(canEditInventory);
    map['can_delete_inventory'] = Variable<bool>(canDeleteInventory);
    map['can_manage_employees'] = Variable<bool>(canManageEmployees);
    map['can_manage_roles'] = Variable<bool>(canManageRoles);
    map['can_view_reports'] = Variable<bool>(canViewReports);
    map['can_access_settings'] = Variable<bool>(canAccessSettings);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      name: Value(name),
      canViewInventory: Value(canViewInventory),
      canAddInventory: Value(canAddInventory),
      canEditInventory: Value(canEditInventory),
      canDeleteInventory: Value(canDeleteInventory),
      canManageEmployees: Value(canManageEmployees),
      canManageRoles: Value(canManageRoles),
      canViewReports: Value(canViewReports),
      canAccessSettings: Value(canAccessSettings),
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
      canViewInventory: serializer.fromJson<bool>(json['canViewInventory']),
      canAddInventory: serializer.fromJson<bool>(json['canAddInventory']),
      canEditInventory: serializer.fromJson<bool>(json['canEditInventory']),
      canDeleteInventory: serializer.fromJson<bool>(json['canDeleteInventory']),
      canManageEmployees: serializer.fromJson<bool>(json['canManageEmployees']),
      canManageRoles: serializer.fromJson<bool>(json['canManageRoles']),
      canViewReports: serializer.fromJson<bool>(json['canViewReports']),
      canAccessSettings: serializer.fromJson<bool>(json['canAccessSettings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'canViewInventory': serializer.toJson<bool>(canViewInventory),
      'canAddInventory': serializer.toJson<bool>(canAddInventory),
      'canEditInventory': serializer.toJson<bool>(canEditInventory),
      'canDeleteInventory': serializer.toJson<bool>(canDeleteInventory),
      'canManageEmployees': serializer.toJson<bool>(canManageEmployees),
      'canManageRoles': serializer.toJson<bool>(canManageRoles),
      'canViewReports': serializer.toJson<bool>(canViewReports),
      'canAccessSettings': serializer.toJson<bool>(canAccessSettings),
    };
  }

  Role copyWith({
    int? id,
    String? name,
    bool? canViewInventory,
    bool? canAddInventory,
    bool? canEditInventory,
    bool? canDeleteInventory,
    bool? canManageEmployees,
    bool? canManageRoles,
    bool? canViewReports,
    bool? canAccessSettings,
  }) => Role(
    id: id ?? this.id,
    name: name ?? this.name,
    canViewInventory: canViewInventory ?? this.canViewInventory,
    canAddInventory: canAddInventory ?? this.canAddInventory,
    canEditInventory: canEditInventory ?? this.canEditInventory,
    canDeleteInventory: canDeleteInventory ?? this.canDeleteInventory,
    canManageEmployees: canManageEmployees ?? this.canManageEmployees,
    canManageRoles: canManageRoles ?? this.canManageRoles,
    canViewReports: canViewReports ?? this.canViewReports,
    canAccessSettings: canAccessSettings ?? this.canAccessSettings,
  );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
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
      canManageEmployees: data.canManageEmployees.present
          ? data.canManageEmployees.value
          : this.canManageEmployees,
      canManageRoles: data.canManageRoles.present
          ? data.canManageRoles.value
          : this.canManageRoles,
      canViewReports: data.canViewReports.present
          ? data.canViewReports.value
          : this.canViewReports,
      canAccessSettings: data.canAccessSettings.present
          ? data.canAccessSettings.value
          : this.canAccessSettings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('canViewInventory: $canViewInventory, ')
          ..write('canAddInventory: $canAddInventory, ')
          ..write('canEditInventory: $canEditInventory, ')
          ..write('canDeleteInventory: $canDeleteInventory, ')
          ..write('canManageEmployees: $canManageEmployees, ')
          ..write('canManageRoles: $canManageRoles, ')
          ..write('canViewReports: $canViewReports, ')
          ..write('canAccessSettings: $canAccessSettings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    canViewInventory,
    canAddInventory,
    canEditInventory,
    canDeleteInventory,
    canManageEmployees,
    canManageRoles,
    canViewReports,
    canAccessSettings,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.name == this.name &&
          other.canViewInventory == this.canViewInventory &&
          other.canAddInventory == this.canAddInventory &&
          other.canEditInventory == this.canEditInventory &&
          other.canDeleteInventory == this.canDeleteInventory &&
          other.canManageEmployees == this.canManageEmployees &&
          other.canManageRoles == this.canManageRoles &&
          other.canViewReports == this.canViewReports &&
          other.canAccessSettings == this.canAccessSettings);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> canViewInventory;
  final Value<bool> canAddInventory;
  final Value<bool> canEditInventory;
  final Value<bool> canDeleteInventory;
  final Value<bool> canManageEmployees;
  final Value<bool> canManageRoles;
  final Value<bool> canViewReports;
  final Value<bool> canAccessSettings;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.canViewInventory = const Value.absent(),
    this.canAddInventory = const Value.absent(),
    this.canEditInventory = const Value.absent(),
    this.canDeleteInventory = const Value.absent(),
    this.canManageEmployees = const Value.absent(),
    this.canManageRoles = const Value.absent(),
    this.canViewReports = const Value.absent(),
    this.canAccessSettings = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.canViewInventory = const Value.absent(),
    this.canAddInventory = const Value.absent(),
    this.canEditInventory = const Value.absent(),
    this.canDeleteInventory = const Value.absent(),
    this.canManageEmployees = const Value.absent(),
    this.canManageRoles = const Value.absent(),
    this.canViewReports = const Value.absent(),
    this.canAccessSettings = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Role> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? canViewInventory,
    Expression<bool>? canAddInventory,
    Expression<bool>? canEditInventory,
    Expression<bool>? canDeleteInventory,
    Expression<bool>? canManageEmployees,
    Expression<bool>? canManageRoles,
    Expression<bool>? canViewReports,
    Expression<bool>? canAccessSettings,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (canViewInventory != null) 'can_view_inventory': canViewInventory,
      if (canAddInventory != null) 'can_add_inventory': canAddInventory,
      if (canEditInventory != null) 'can_edit_inventory': canEditInventory,
      if (canDeleteInventory != null)
        'can_delete_inventory': canDeleteInventory,
      if (canManageEmployees != null)
        'can_manage_employees': canManageEmployees,
      if (canManageRoles != null) 'can_manage_roles': canManageRoles,
      if (canViewReports != null) 'can_view_reports': canViewReports,
      if (canAccessSettings != null) 'can_access_settings': canAccessSettings,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? canViewInventory,
    Value<bool>? canAddInventory,
    Value<bool>? canEditInventory,
    Value<bool>? canDeleteInventory,
    Value<bool>? canManageEmployees,
    Value<bool>? canManageRoles,
    Value<bool>? canViewReports,
    Value<bool>? canAccessSettings,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      canViewInventory: canViewInventory ?? this.canViewInventory,
      canAddInventory: canAddInventory ?? this.canAddInventory,
      canEditInventory: canEditInventory ?? this.canEditInventory,
      canDeleteInventory: canDeleteInventory ?? this.canDeleteInventory,
      canManageEmployees: canManageEmployees ?? this.canManageEmployees,
      canManageRoles: canManageRoles ?? this.canManageRoles,
      canViewReports: canViewReports ?? this.canViewReports,
      canAccessSettings: canAccessSettings ?? this.canAccessSettings,
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
    if (canManageEmployees.present) {
      map['can_manage_employees'] = Variable<bool>(canManageEmployees.value);
    }
    if (canManageRoles.present) {
      map['can_manage_roles'] = Variable<bool>(canManageRoles.value);
    }
    if (canViewReports.present) {
      map['can_view_reports'] = Variable<bool>(canViewReports.value);
    }
    if (canAccessSettings.present) {
      map['can_access_settings'] = Variable<bool>(canAccessSettings.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('canViewInventory: $canViewInventory, ')
          ..write('canAddInventory: $canAddInventory, ')
          ..write('canEditInventory: $canEditInventory, ')
          ..write('canDeleteInventory: $canDeleteInventory, ')
          ..write('canManageEmployees: $canManageEmployees, ')
          ..write('canManageRoles: $canManageRoles, ')
          ..write('canViewReports: $canViewReports, ')
          ..write('canAccessSettings: $canAccessSettings')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $RolesTable roles = $RolesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [items, users, roles];
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
    });

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

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
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
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
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
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String email,
      Value<String?> name,
      Value<String?> phone,
      required String password,
      required String role,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String?> name,
      Value<String?> phone,
      Value<String> password,
      Value<String> role,
    });

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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
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
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
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
                Value<String?> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> role = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                name: name,
                phone: phone,
                password: password,
                role: role,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                Value<String?> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String password,
                required String role,
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                name: name,
                phone: phone,
                password: password,
                role: role,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> canViewInventory,
      Value<bool> canAddInventory,
      Value<bool> canEditInventory,
      Value<bool> canDeleteInventory,
      Value<bool> canManageEmployees,
      Value<bool> canManageRoles,
      Value<bool> canViewReports,
      Value<bool> canAccessSettings,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> canViewInventory,
      Value<bool> canAddInventory,
      Value<bool> canEditInventory,
      Value<bool> canDeleteInventory,
      Value<bool> canManageEmployees,
      Value<bool> canManageRoles,
      Value<bool> canViewReports,
      Value<bool> canAccessSettings,
    });

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

  ColumnFilters<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canAccessSettings => $composableBuilder(
    column: $table.canAccessSettings,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canAccessSettings => $composableBuilder(
    column: $table.canAccessSettings,
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

  GeneratedColumn<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canAccessSettings => $composableBuilder(
    column: $table.canAccessSettings,
    builder: (column) => column,
  );
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
          (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
          Role,
          PrefetchHooks Function()
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
                Value<bool> canViewInventory = const Value.absent(),
                Value<bool> canAddInventory = const Value.absent(),
                Value<bool> canEditInventory = const Value.absent(),
                Value<bool> canDeleteInventory = const Value.absent(),
                Value<bool> canManageEmployees = const Value.absent(),
                Value<bool> canManageRoles = const Value.absent(),
                Value<bool> canViewReports = const Value.absent(),
                Value<bool> canAccessSettings = const Value.absent(),
              }) => RolesCompanion(
                id: id,
                name: name,
                canViewInventory: canViewInventory,
                canAddInventory: canAddInventory,
                canEditInventory: canEditInventory,
                canDeleteInventory: canDeleteInventory,
                canManageEmployees: canManageEmployees,
                canManageRoles: canManageRoles,
                canViewReports: canViewReports,
                canAccessSettings: canAccessSettings,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> canViewInventory = const Value.absent(),
                Value<bool> canAddInventory = const Value.absent(),
                Value<bool> canEditInventory = const Value.absent(),
                Value<bool> canDeleteInventory = const Value.absent(),
                Value<bool> canManageEmployees = const Value.absent(),
                Value<bool> canManageRoles = const Value.absent(),
                Value<bool> canViewReports = const Value.absent(),
                Value<bool> canAccessSettings = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                name: name,
                canViewInventory: canViewInventory,
                canAddInventory: canAddInventory,
                canEditInventory: canEditInventory,
                canDeleteInventory: canDeleteInventory,
                canManageEmployees: canManageEmployees,
                canManageRoles: canManageRoles,
                canViewReports: canViewReports,
                canAccessSettings: canAccessSettings,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
      Role,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
}
