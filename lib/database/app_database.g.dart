// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, Organization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentCommissaryIdMeta =
      const VerificationMeta('parentCommissaryId');
  @override
  late final GeneratedColumn<int> parentCommissaryId = GeneratedColumn<int>(
    'parent_commissary_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    parentCommissaryId,
    contactPerson,
    phone,
    email,
    address,
    createdAt,
    lastUpdated,
    isActive,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Organization> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_commissary_id')) {
      context.handle(
        _parentCommissaryIdMeta,
        parentCommissaryId.isAcceptableOrUnknown(
          data['parent_commissary_id']!,
          _parentCommissaryIdMeta,
        ),
      );
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
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
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Organization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Organization(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentCommissaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_commissary_id'],
      ),
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class Organization extends DataClass implements Insertable<Organization> {
  /// Primary key
  final int id;

  /// Organization name (e.g., "Main Commissary", "Branch Makati")
  final String name;

  /// Type of organization: 'commissary' or 'franchisee'
  /// - commissary: Creates ingredients and items, supplies franchisees
  /// - franchisee: Orders from commissary, sells to customers
  final String type;

  /// For franchisees: Reference to parent commissary
  /// For commissary: NULL (they are the top-level)
  final int? parentCommissaryId;

  /// Contact information
  final String? contactPerson;
  final String? phone;
  final String? email;

  /// Physical address
  final String? address;

  /// Track when organization was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Active status (for soft delete)
  final bool isActive;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const Organization({
    required this.id,
    required this.name,
    required this.type,
    this.parentCommissaryId,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    required this.createdAt,
    required this.lastUpdated,
    required this.isActive,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentCommissaryId != null) {
      map['parent_commissary_id'] = Variable<int>(parentCommissaryId);
    }
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_active'] = Variable<bool>(isActive);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      parentCommissaryId: parentCommissaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCommissaryId),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isActive: Value(isActive),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory Organization.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Organization(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      parentCommissaryId: serializer.fromJson<int?>(json['parentCommissaryId']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'parentCommissaryId': serializer.toJson<int?>(parentCommissaryId),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isActive': serializer.toJson<bool>(isActive),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  Organization copyWith({
    int? id,
    String? name,
    String? type,
    Value<int?> parentCommissaryId = const Value.absent(),
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isActive,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => Organization(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    parentCommissaryId: parentCommissaryId.present
        ? parentCommissaryId.value
        : this.parentCommissaryId,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isActive: isActive ?? this.isActive,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  Organization copyWithCompanion(OrganizationsCompanion data) {
    return Organization(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parentCommissaryId: data.parentCommissaryId.present
          ? data.parentCommissaryId.value
          : this.parentCommissaryId,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Organization(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentCommissaryId: $parentCommissaryId, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isActive: $isActive, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    parentCommissaryId,
    contactPerson,
    phone,
    email,
    address,
    createdAt,
    lastUpdated,
    isActive,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Organization &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.parentCommissaryId == this.parentCommissaryId &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isActive == this.isActive &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class OrganizationsCompanion extends UpdateCompanion<Organization> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int?> parentCommissaryId;
  final Value<String?> contactPerson;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isActive;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parentCommissaryId = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.parentCommissaryId = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<Organization> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? parentCommissaryId,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isActive,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parentCommissaryId != null)
        'parent_commissary_id': parentCommissaryId,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isActive != null) 'is_active': isActive,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  OrganizationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int?>? parentCommissaryId,
    Value<String?>? contactPerson,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isActive,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentCommissaryId: parentCommissaryId ?? this.parentCommissaryId,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentCommissaryId.present) {
      map['parent_commissary_id'] = Variable<int>(parentCommissaryId.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentCommissaryId: $parentCommissaryId, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isActive: $isActive, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    isSynced,
    cloudId,
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
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
  final bool isSynced;
  final String? cloudId;
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
    required this.isSynced,
    this.cloudId,
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
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
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
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
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
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
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
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
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
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
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
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
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
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
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
          ..write('canManageRoles: $canManageRoles, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
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
    isSynced,
    cloudId,
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
          other.canManageRoles == this.canManageRoles &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
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
  final Value<bool> isSynced;
  final Value<String?> cloudId;
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
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
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
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
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
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
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
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
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
    Value<bool>? isSynced,
    Value<String?>? cloudId,
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
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
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
          ..write('canManageRoles: $canManageRoles, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
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
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
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
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    email,
    password,
    phone,
    organizationId,
    roleId,
    fullName,
    isActive,
    createdAt,
    lastUpdated,
    isSynced,
    cloudId,
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
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
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
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
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
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  /// Primary key
  final int id;

  /// Unique username for login
  final String username;

  /// Unique email for login and notifications
  final String email;

  /// Hashed password
  final String password;

  /// Optional phone number
  final String? phone;

  /// Which organization this user belongs to
  /// - Commissary users → commissary organization
  /// - Franchisee owner/manager → franchisee organization
  /// - Franchisee employee → franchisee organization
  final int organizationId;

  /// Role defines permissions (from Roles table)
  final int roleId;

  /// Full name of user
  final String? fullName;

  /// Active status (for soft delete)
  final bool isActive;

  /// Track when user was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    required this.organizationId,
    required this.roleId,
    this.fullName,
    required this.isActive,
    required this.createdAt,
    required this.lastUpdated,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['organization_id'] = Variable<int>(organizationId);
    map['role_id'] = Variable<int>(roleId);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      email: Value(email),
      password: Value(password),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      organizationId: Value(organizationId),
      roleId: Value(roleId),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      phone: serializer.fromJson<String?>(json['phone']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      roleId: serializer.fromJson<int>(json['roleId']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'phone': serializer.toJson<String?>(phone),
      'organizationId': serializer.toJson<int>(organizationId),
      'roleId': serializer.toJson<int>(roleId),
      'fullName': serializer.toJson<String?>(fullName),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    Value<String?> phone = const Value.absent(),
    int? organizationId,
    int? roleId,
    Value<String?> fullName = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    password: password ?? this.password,
    phone: phone.present ? phone.value : this.phone,
    organizationId: organizationId ?? this.organizationId,
    roleId: roleId ?? this.roleId,
    fullName: fullName.present ? fullName.value : this.fullName,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      phone: data.phone.present ? data.phone.value : this.phone,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('phone: $phone, ')
          ..write('organizationId: $organizationId, ')
          ..write('roleId: $roleId, ')
          ..write('fullName: $fullName, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    email,
    password,
    phone,
    organizationId,
    roleId,
    fullName,
    isActive,
    createdAt,
    lastUpdated,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.email == this.email &&
          other.password == this.password &&
          other.phone == this.phone &&
          other.organizationId == this.organizationId &&
          other.roleId == this.roleId &&
          other.fullName == this.fullName &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> email;
  final Value<String> password;
  final Value<String?> phone;
  final Value<int> organizationId;
  final Value<int> roleId;
  final Value<String?> fullName;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.phone = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String email,
    required String password,
    this.phone = const Value.absent(),
    required int organizationId,
    required int roleId,
    this.fullName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : username = Value(username),
       email = Value(email),
       password = Value(password),
       organizationId = Value(organizationId),
       roleId = Value(roleId);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? phone,
    Expression<int>? organizationId,
    Expression<int>? roleId,
    Expression<String>? fullName,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (phone != null) 'phone': phone,
      if (organizationId != null) 'organization_id': organizationId,
      if (roleId != null) 'role_id': roleId,
      if (fullName != null) 'full_name': fullName,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? email,
    Value<String>? password,
    Value<String?>? phone,
    Value<int>? organizationId,
    Value<int>? roleId,
    Value<String?>? fullName,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      organizationId: organizationId ?? this.organizationId,
      roleId: roleId ?? this.roleId,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('phone: $phone, ')
          ..write('organizationId: $organizationId, ')
          ..write('roleId: $roleId, ')
          ..write('fullName: $fullName, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
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
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _masterItemIdMeta = const VerificationMeta(
    'masterItemId',
  );
  @override
  late final GeneratedColumn<int> masterItemId = GeneratedColumn<int>(
    'master_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('piece'),
  );
  static const VerificationMeta _minimumStockMeta = const VerificationMeta(
    'minimumStock',
  );
  @override
  late final GeneratedColumn<int> minimumStock = GeneratedColumn<int>(
    'minimum_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryId,
    organizationId,
    masterItemId,
    stock,
    sold,
    spoilage,
    price,
    costPrice,
    unit,
    minimumStock,
    description,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
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
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('master_item_id')) {
      context.handle(
        _masterItemIdMeta,
        masterItemId.isAcceptableOrUnknown(
          data['master_item_id']!,
          _masterItemIdMeta,
        ),
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
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
        _minimumStockMeta,
        minimumStock.isAcceptableOrUnknown(
          data['minimum_stock']!,
          _minimumStockMeta,
        ),
      );
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
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
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      masterItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}master_item_id'],
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
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      minimumStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_stock'],
      ),
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  /// Primary key
  final int id;

  /// Item name (e.g., "Fried Chicken Meal", "Burger Combo")
  final String name;

  /// Optional category for filtering (e.g., "Food", "Beverages")
  final int? categoryId;

  /// Which organization owns this item
  /// - If commissary: This is the master item that can be ordered
  /// - If franchisee: This is their local copy with their own price
  final int organizationId;

  /// For franchisee items: Reference to the commissary's master item
  /// For commissary items: NULL (they are the master)
  final int? masterItemId;

  /// Current stock quantity
  final int stock;

  /// Total sold quantity (cumulative)
  final int sold;

  /// Total spoiled quantity (cumulative)
  final int spoilage;

  /// Price set by franchisee (for their customers)
  /// Commissary items may not have a price (only franchisee sets retail price)
  final double? price;

  /// Cost per unit (for franchisee to know their cost from commissary)
  final double? costPrice;

  /// Unit of measurement (e.g., "piece", "serving", "box")
  final String unit;

  /// Minimum stock threshold for low stock alerts
  final int? minimumStock;

  /// Optional description
  final String? description;

  /// Track when item was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Soft delete
  final bool isDeleted;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const Item({
    required this.id,
    required this.name,
    this.categoryId,
    required this.organizationId,
    this.masterItemId,
    required this.stock,
    required this.sold,
    required this.spoilage,
    this.price,
    this.costPrice,
    required this.unit,
    this.minimumStock,
    this.description,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['organization_id'] = Variable<int>(organizationId);
    if (!nullToAbsent || masterItemId != null) {
      map['master_item_id'] = Variable<int>(masterItemId);
    }
    map['stock'] = Variable<int>(stock);
    map['sold'] = Variable<int>(sold);
    map['spoilage'] = Variable<int>(spoilage);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || costPrice != null) {
      map['cost_price'] = Variable<double>(costPrice);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || minimumStock != null) {
      map['minimum_stock'] = Variable<int>(minimumStock);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      organizationId: Value(organizationId),
      masterItemId: masterItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(masterItemId),
      stock: Value(stock),
      sold: Value(sold),
      spoilage: Value(spoilage),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      costPrice: costPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(costPrice),
      unit: Value(unit),
      minimumStock: minimumStock == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumStock),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
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
      organizationId: serializer.fromJson<int>(json['organizationId']),
      masterItemId: serializer.fromJson<int?>(json['masterItemId']),
      stock: serializer.fromJson<int>(json['stock']),
      sold: serializer.fromJson<int>(json['sold']),
      spoilage: serializer.fromJson<int>(json['spoilage']),
      price: serializer.fromJson<double?>(json['price']),
      costPrice: serializer.fromJson<double?>(json['costPrice']),
      unit: serializer.fromJson<String>(json['unit']),
      minimumStock: serializer.fromJson<int?>(json['minimumStock']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int?>(categoryId),
      'organizationId': serializer.toJson<int>(organizationId),
      'masterItemId': serializer.toJson<int?>(masterItemId),
      'stock': serializer.toJson<int>(stock),
      'sold': serializer.toJson<int>(sold),
      'spoilage': serializer.toJson<int>(spoilage),
      'price': serializer.toJson<double?>(price),
      'costPrice': serializer.toJson<double?>(costPrice),
      'unit': serializer.toJson<String>(unit),
      'minimumStock': serializer.toJson<int?>(minimumStock),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  Item copyWith({
    int? id,
    String? name,
    Value<int?> categoryId = const Value.absent(),
    int? organizationId,
    Value<int?> masterItemId = const Value.absent(),
    int? stock,
    int? sold,
    int? spoilage,
    Value<double?> price = const Value.absent(),
    Value<double?> costPrice = const Value.absent(),
    String? unit,
    Value<int?> minimumStock = const Value.absent(),
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    organizationId: organizationId ?? this.organizationId,
    masterItemId: masterItemId.present ? masterItemId.value : this.masterItemId,
    stock: stock ?? this.stock,
    sold: sold ?? this.sold,
    spoilage: spoilage ?? this.spoilage,
    price: price.present ? price.value : this.price,
    costPrice: costPrice.present ? costPrice.value : this.costPrice,
    unit: unit ?? this.unit,
    minimumStock: minimumStock.present ? minimumStock.value : this.minimumStock,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      masterItemId: data.masterItemId.present
          ? data.masterItemId.value
          : this.masterItemId,
      stock: data.stock.present ? data.stock.value : this.stock,
      sold: data.sold.present ? data.sold.value : this.sold,
      spoilage: data.spoilage.present ? data.spoilage.value : this.spoilage,
      price: data.price.present ? data.price.value : this.price,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      unit: data.unit.present ? data.unit.value : this.unit,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('organizationId: $organizationId, ')
          ..write('masterItemId: $masterItemId, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('unit: $unit, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    categoryId,
    organizationId,
    masterItemId,
    stock,
    sold,
    spoilage,
    price,
    costPrice,
    unit,
    minimumStock,
    description,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.organizationId == this.organizationId &&
          other.masterItemId == this.masterItemId &&
          other.stock == this.stock &&
          other.sold == this.sold &&
          other.spoilage == this.spoilage &&
          other.price == this.price &&
          other.costPrice == this.costPrice &&
          other.unit == this.unit &&
          other.minimumStock == this.minimumStock &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> categoryId;
  final Value<int> organizationId;
  final Value<int?> masterItemId;
  final Value<int> stock;
  final Value<int> sold;
  final Value<int> spoilage;
  final Value<double?> price;
  final Value<double?> costPrice;
  final Value<String> unit;
  final Value<int?> minimumStock;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.masterItemId = const Value.absent(),
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.categoryId = const Value.absent(),
    required int organizationId,
    this.masterItemId = const Value.absent(),
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : name = Value(name),
       organizationId = Value(organizationId);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? organizationId,
    Expression<int>? masterItemId,
    Expression<int>? stock,
    Expression<int>? sold,
    Expression<int>? spoilage,
    Expression<double>? price,
    Expression<double>? costPrice,
    Expression<String>? unit,
    Expression<int>? minimumStock,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (organizationId != null) 'organization_id': organizationId,
      if (masterItemId != null) 'master_item_id': masterItemId,
      if (stock != null) 'stock': stock,
      if (sold != null) 'sold': sold,
      if (spoilage != null) 'spoilage': spoilage,
      if (price != null) 'price': price,
      if (costPrice != null) 'cost_price': costPrice,
      if (unit != null) 'unit': unit,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? categoryId,
    Value<int>? organizationId,
    Value<int?>? masterItemId,
    Value<int>? stock,
    Value<int>? sold,
    Value<int>? spoilage,
    Value<double?>? price,
    Value<double?>? costPrice,
    Value<String>? unit,
    Value<int?>? minimumStock,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      organizationId: organizationId ?? this.organizationId,
      masterItemId: masterItemId ?? this.masterItemId,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      spoilage: spoilage ?? this.spoilage,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      unit: unit ?? this.unit,
      minimumStock: minimumStock ?? this.minimumStock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
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
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (masterItemId.present) {
      map['master_item_id'] = Variable<int>(masterItemId.value);
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
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<int>(minimumStock.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('organizationId: $organizationId, ')
          ..write('masterItemId: $masterItemId, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('unit: $unit, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 200,
    ),
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
  static const VerificationMeta _commissaryIdMeta = const VerificationMeta(
    'commissaryId',
  );
  @override
  late final GeneratedColumn<int> commissaryId = GeneratedColumn<int>(
    'commissary_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pieces'),
  );
  static const VerificationMeta _minimumStockMeta = const VerificationMeta(
    'minimumStock',
  );
  @override
  late final GeneratedColumn<int> minimumStock = GeneratedColumn<int>(
    'minimum_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryId,
    commissaryId,
    stock,
    spoilage,
    unit,
    minimumStock,
    description,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
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
    if (data.containsKey('commissary_id')) {
      context.handle(
        _commissaryIdMeta,
        commissaryId.isAcceptableOrUnknown(
          data['commissary_id']!,
          _commissaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commissaryIdMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('spoilage')) {
      context.handle(
        _spoilageMeta,
        spoilage.isAcceptableOrUnknown(data['spoilage']!, _spoilageMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
        _minimumStockMeta,
        minimumStock.isAcceptableOrUnknown(
          data['minimum_stock']!,
          _minimumStockMeta,
        ),
      );
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
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
      commissaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commissary_id'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      spoilage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spoilage'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      minimumStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_stock'],
      ),
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  /// Primary key
  final int id;

  /// Ingredient name (e.g., "Chicken Breast", "Garlic", "Soy Sauce")
  final String name;

  /// Optional category for organization (e.g., "Poultry", "Vegetables", "Spices")
  final int? categoryId;

  /// Which commissary owns this ingredient
  /// Only commissary-type organizations can create ingredients
  final int commissaryId;

  /// Current stock quantity (in base unit)
  final int stock;

  /// Spoiled quantity (deducted from stock when recorded)
  final int spoilage;

  /// Unit of measurement (e.g., "kg", "pieces", "liters", "grams")
  final String unit;

  /// Minimum stock threshold for alerts (e.g., alert when stock < 10)
  final int? minimumStock;

  /// Optional description or notes
  final String? description;

  /// Track when ingredient was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Soft delete
  final bool isDeleted;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const Ingredient({
    required this.id,
    required this.name,
    this.categoryId,
    required this.commissaryId,
    required this.stock,
    required this.spoilage,
    required this.unit,
    this.minimumStock,
    this.description,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['commissary_id'] = Variable<int>(commissaryId);
    map['stock'] = Variable<int>(stock);
    map['spoilage'] = Variable<int>(spoilage);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || minimumStock != null) {
      map['minimum_stock'] = Variable<int>(minimumStock);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      commissaryId: Value(commissaryId),
      stock: Value(stock),
      spoilage: Value(spoilage),
      unit: Value(unit),
      minimumStock: minimumStock == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumStock),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      commissaryId: serializer.fromJson<int>(json['commissaryId']),
      stock: serializer.fromJson<int>(json['stock']),
      spoilage: serializer.fromJson<int>(json['spoilage']),
      unit: serializer.fromJson<String>(json['unit']),
      minimumStock: serializer.fromJson<int?>(json['minimumStock']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int?>(categoryId),
      'commissaryId': serializer.toJson<int>(commissaryId),
      'stock': serializer.toJson<int>(stock),
      'spoilage': serializer.toJson<int>(spoilage),
      'unit': serializer.toJson<String>(unit),
      'minimumStock': serializer.toJson<int?>(minimumStock),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  Ingredient copyWith({
    int? id,
    String? name,
    Value<int?> categoryId = const Value.absent(),
    int? commissaryId,
    int? stock,
    int? spoilage,
    String? unit,
    Value<int?> minimumStock = const Value.absent(),
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => Ingredient(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    commissaryId: commissaryId ?? this.commissaryId,
    stock: stock ?? this.stock,
    spoilage: spoilage ?? this.spoilage,
    unit: unit ?? this.unit,
    minimumStock: minimumStock.present ? minimumStock.value : this.minimumStock,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      commissaryId: data.commissaryId.present
          ? data.commissaryId.value
          : this.commissaryId,
      stock: data.stock.present ? data.stock.value : this.stock,
      spoilage: data.spoilage.present ? data.spoilage.value : this.spoilage,
      unit: data.unit.present ? data.unit.value : this.unit,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('stock: $stock, ')
          ..write('spoilage: $spoilage, ')
          ..write('unit: $unit, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    categoryId,
    commissaryId,
    stock,
    spoilage,
    unit,
    minimumStock,
    description,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.commissaryId == this.commissaryId &&
          other.stock == this.stock &&
          other.spoilage == this.spoilage &&
          other.unit == this.unit &&
          other.minimumStock == this.minimumStock &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> categoryId;
  final Value<int> commissaryId;
  final Value<int> stock;
  final Value<int> spoilage;
  final Value<String> unit;
  final Value<int?> minimumStock;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.commissaryId = const Value.absent(),
    this.stock = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.unit = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.categoryId = const Value.absent(),
    required int commissaryId,
    this.stock = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.unit = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : name = Value(name),
       commissaryId = Value(commissaryId);
  static Insertable<Ingredient> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? commissaryId,
    Expression<int>? stock,
    Expression<int>? spoilage,
    Expression<String>? unit,
    Expression<int>? minimumStock,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (commissaryId != null) 'commissary_id': commissaryId,
      if (stock != null) 'stock': stock,
      if (spoilage != null) 'spoilage': spoilage,
      if (unit != null) 'unit': unit,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  IngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? categoryId,
    Value<int>? commissaryId,
    Value<int>? stock,
    Value<int>? spoilage,
    Value<String>? unit,
    Value<int?>? minimumStock,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      commissaryId: commissaryId ?? this.commissaryId,
      stock: stock ?? this.stock,
      spoilage: spoilage ?? this.spoilage,
      unit: unit ?? this.unit,
      minimumStock: minimumStock ?? this.minimumStock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
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
    if (commissaryId.present) {
      map['commissary_id'] = Variable<int>(commissaryId.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (spoilage.present) {
      map['spoilage'] = Variable<int>(spoilage.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<int>(minimumStock.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('stock: $stock, ')
          ..write('spoilage: $spoilage, ')
          ..write('unit: $unit, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _quantityNeededMeta = const VerificationMeta(
    'quantityNeeded',
  );
  @override
  late final GeneratedColumn<double> quantityNeeded = GeneratedColumn<double>(
    'quantity_needed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    ingredientId,
    quantityNeeded,
    unit,
    notes,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity_needed')) {
      context.handle(
        _quantityNeededMeta,
        quantityNeeded.isAcceptableOrUnknown(
          data['quantity_needed']!,
          _quantityNeededMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityNeededMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_id'],
      )!,
      quantityNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_needed'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  /// Primary key
  final int id;

  /// Reference to the Item/Recipe (final product)
  final int itemId;

  /// Reference to the Ingredient (raw material)
  final int ingredientId;

  /// How much of this ingredient is needed for ONE unit of the item
  /// Example: 200 grams of chicken breast per fried chicken meal
  final double quantityNeeded;

  /// Unit of measurement for this ingredient in the recipe
  /// Should match or be convertible to ingredient's base unit
  /// Example: "g" for grams, "ml" for milliliters, "pieces"
  final String unit;

  /// Optional notes (e.g., "Cut into strips", "Marinate for 2 hours")
  final String? notes;

  /// Track when this recipe ingredient was added/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Soft delete (in case ingredient is removed from recipe)
  final bool isDeleted;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const RecipeIngredient({
    required this.id,
    required this.itemId,
    required this.ingredientId,
    required this.quantityNeeded,
    required this.unit,
    this.notes,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['ingredient_id'] = Variable<int>(ingredientId);
    map['quantity_needed'] = Variable<double>(quantityNeeded);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      ingredientId: Value(ingredientId),
      quantityNeeded: Value(quantityNeeded),
      unit: Value(unit),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      quantityNeeded: serializer.fromJson<double>(json['quantityNeeded']),
      unit: serializer.fromJson<String>(json['unit']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'quantityNeeded': serializer.toJson<double>(quantityNeeded),
      'unit': serializer.toJson<String>(unit),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  RecipeIngredient copyWith({
    int? id,
    int? itemId,
    int? ingredientId,
    double? quantityNeeded,
    String? unit,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => RecipeIngredient(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    ingredientId: ingredientId ?? this.ingredientId,
    quantityNeeded: quantityNeeded ?? this.quantityNeeded,
    unit: unit ?? this.unit,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantityNeeded: data.quantityNeeded.present
          ? data.quantityNeeded.value
          : this.quantityNeeded,
      unit: data.unit.present ? data.unit.value : this.unit,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantityNeeded: $quantityNeeded, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    ingredientId,
    quantityNeeded,
    unit,
    notes,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.ingredientId == this.ingredientId &&
          other.quantityNeeded == this.quantityNeeded &&
          other.unit == this.unit &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<int> ingredientId;
  final Value<double> quantityNeeded;
  final Value<String> unit;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantityNeeded = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required int ingredientId,
    required double quantityNeeded,
    required String unit,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : itemId = Value(itemId),
       ingredientId = Value(ingredientId),
       quantityNeeded = Value(quantityNeeded),
       unit = Value(unit);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<int>? ingredientId,
    Expression<double>? quantityNeeded,
    Expression<String>? unit,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantityNeeded != null) 'quantity_needed': quantityNeeded,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<int>? ingredientId,
    Value<double>? quantityNeeded,
    Value<String>? unit,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (quantityNeeded.present) {
      map['quantity_needed'] = Variable<double>(quantityNeeded.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantityNeeded: $quantityNeeded, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $BranchIngredientStockTable extends BranchIngredientStock
    with TableInfo<$BranchIngredientStockTable, BranchIngredientStockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchIngredientStockTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _minimumStockMeta = const VerificationMeta(
    'minimumStock',
  );
  @override
  late final GeneratedColumn<double> minimumStock = GeneratedColumn<double>(
    'minimum_stock',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReceivedAtMeta = const VerificationMeta(
    'lastReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReceivedAt =
      GeneratedColumn<DateTime>(
        'last_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastReceivedQuantityMeta =
      const VerificationMeta('lastReceivedQuantity');
  @override
  late final GeneratedColumn<double> lastReceivedQuantity =
      GeneratedColumn<double>(
        'last_received_quantity',
        aliasedName,
        true,
        type: DriftSqlType.double,
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    ingredientId,
    quantity,
    minimumStock,
    lastReceivedAt,
    lastReceivedQuantity,
    createdAt,
    lastUpdated,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branch_ingredient_stock';
  @override
  VerificationContext validateIntegrity(
    Insertable<BranchIngredientStockData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
        _minimumStockMeta,
        minimumStock.isAcceptableOrUnknown(
          data['minimum_stock']!,
          _minimumStockMeta,
        ),
      );
    }
    if (data.containsKey('last_received_at')) {
      context.handle(
        _lastReceivedAtMeta,
        lastReceivedAt.isAcceptableOrUnknown(
          data['last_received_at']!,
          _lastReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_received_quantity')) {
      context.handle(
        _lastReceivedQuantityMeta,
        lastReceivedQuantity.isAcceptableOrUnknown(
          data['last_received_quantity']!,
          _lastReceivedQuantityMeta,
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {organizationId, ingredientId},
  ];
  @override
  BranchIngredientStockData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BranchIngredientStockData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      minimumStock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_stock'],
      ),
      lastReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_received_at'],
      ),
      lastReceivedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_received_quantity'],
      ),
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
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $BranchIngredientStockTable createAlias(String alias) {
    return $BranchIngredientStockTable(attachedDatabase, alias);
  }
}

class BranchIngredientStockData extends DataClass
    implements Insertable<BranchIngredientStockData> {
  /// Primary key
  final int id;

  /// Which branch owns this stock
  final int organizationId;

  /// Reference to master ingredient (for name, unit, etc.)
  final int ingredientId;

  /// Current stock quantity at this branch
  final double quantity;

  /// Minimum stock level for alerts
  final double? minimumStock;

  /// Last time this branch received a delivery of this ingredient
  final DateTime? lastReceivedAt;

  /// Quantity from last delivery
  final double? lastReceivedQuantity;

  /// Track when record was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const BranchIngredientStockData({
    required this.id,
    required this.organizationId,
    required this.ingredientId,
    required this.quantity,
    this.minimumStock,
    this.lastReceivedAt,
    this.lastReceivedQuantity,
    required this.createdAt,
    required this.lastUpdated,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['organization_id'] = Variable<int>(organizationId);
    map['ingredient_id'] = Variable<int>(ingredientId);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || minimumStock != null) {
      map['minimum_stock'] = Variable<double>(minimumStock);
    }
    if (!nullToAbsent || lastReceivedAt != null) {
      map['last_received_at'] = Variable<DateTime>(lastReceivedAt);
    }
    if (!nullToAbsent || lastReceivedQuantity != null) {
      map['last_received_quantity'] = Variable<double>(lastReceivedQuantity);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  BranchIngredientStockCompanion toCompanion(bool nullToAbsent) {
    return BranchIngredientStockCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      ingredientId: Value(ingredientId),
      quantity: Value(quantity),
      minimumStock: minimumStock == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumStock),
      lastReceivedAt: lastReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReceivedAt),
      lastReceivedQuantity: lastReceivedQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReceivedQuantity),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory BranchIngredientStockData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BranchIngredientStockData(
      id: serializer.fromJson<int>(json['id']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      minimumStock: serializer.fromJson<double?>(json['minimumStock']),
      lastReceivedAt: serializer.fromJson<DateTime?>(json['lastReceivedAt']),
      lastReceivedQuantity: serializer.fromJson<double?>(
        json['lastReceivedQuantity'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'organizationId': serializer.toJson<int>(organizationId),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'quantity': serializer.toJson<double>(quantity),
      'minimumStock': serializer.toJson<double?>(minimumStock),
      'lastReceivedAt': serializer.toJson<DateTime?>(lastReceivedAt),
      'lastReceivedQuantity': serializer.toJson<double?>(lastReceivedQuantity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  BranchIngredientStockData copyWith({
    int? id,
    int? organizationId,
    int? ingredientId,
    double? quantity,
    Value<double?> minimumStock = const Value.absent(),
    Value<DateTime?> lastReceivedAt = const Value.absent(),
    Value<double?> lastReceivedQuantity = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => BranchIngredientStockData(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    ingredientId: ingredientId ?? this.ingredientId,
    quantity: quantity ?? this.quantity,
    minimumStock: minimumStock.present ? minimumStock.value : this.minimumStock,
    lastReceivedAt: lastReceivedAt.present
        ? lastReceivedAt.value
        : this.lastReceivedAt,
    lastReceivedQuantity: lastReceivedQuantity.present
        ? lastReceivedQuantity.value
        : this.lastReceivedQuantity,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  BranchIngredientStockData copyWithCompanion(
    BranchIngredientStockCompanion data,
  ) {
    return BranchIngredientStockData(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      lastReceivedAt: data.lastReceivedAt.present
          ? data.lastReceivedAt.value
          : this.lastReceivedAt,
      lastReceivedQuantity: data.lastReceivedQuantity.present
          ? data.lastReceivedQuantity.value
          : this.lastReceivedQuantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BranchIngredientStockData(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('lastReceivedAt: $lastReceivedAt, ')
          ..write('lastReceivedQuantity: $lastReceivedQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    ingredientId,
    quantity,
    minimumStock,
    lastReceivedAt,
    lastReceivedQuantity,
    createdAt,
    lastUpdated,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BranchIngredientStockData &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.ingredientId == this.ingredientId &&
          other.quantity == this.quantity &&
          other.minimumStock == this.minimumStock &&
          other.lastReceivedAt == this.lastReceivedAt &&
          other.lastReceivedQuantity == this.lastReceivedQuantity &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class BranchIngredientStockCompanion
    extends UpdateCompanion<BranchIngredientStockData> {
  final Value<int> id;
  final Value<int> organizationId;
  final Value<int> ingredientId;
  final Value<double> quantity;
  final Value<double?> minimumStock;
  final Value<DateTime?> lastReceivedAt;
  final Value<double?> lastReceivedQuantity;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const BranchIngredientStockCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.lastReceivedAt = const Value.absent(),
    this.lastReceivedQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  BranchIngredientStockCompanion.insert({
    this.id = const Value.absent(),
    required int organizationId,
    required int ingredientId,
    this.quantity = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.lastReceivedAt = const Value.absent(),
    this.lastReceivedQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : organizationId = Value(organizationId),
       ingredientId = Value(ingredientId);
  static Insertable<BranchIngredientStockData> custom({
    Expression<int>? id,
    Expression<int>? organizationId,
    Expression<int>? ingredientId,
    Expression<double>? quantity,
    Expression<double>? minimumStock,
    Expression<DateTime>? lastReceivedAt,
    Expression<double>? lastReceivedQuantity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantity != null) 'quantity': quantity,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (lastReceivedAt != null) 'last_received_at': lastReceivedAt,
      if (lastReceivedQuantity != null)
        'last_received_quantity': lastReceivedQuantity,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  BranchIngredientStockCompanion copyWith({
    Value<int>? id,
    Value<int>? organizationId,
    Value<int>? ingredientId,
    Value<double>? quantity,
    Value<double?>? minimumStock,
    Value<DateTime?>? lastReceivedAt,
    Value<double?>? lastReceivedQuantity,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return BranchIngredientStockCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      minimumStock: minimumStock ?? this.minimumStock,
      lastReceivedAt: lastReceivedAt ?? this.lastReceivedAt,
      lastReceivedQuantity: lastReceivedQuantity ?? this.lastReceivedQuantity,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<double>(minimumStock.value);
    }
    if (lastReceivedAt.present) {
      map['last_received_at'] = Variable<DateTime>(lastReceivedAt.value);
    }
    if (lastReceivedQuantity.present) {
      map['last_received_quantity'] = Variable<double>(
        lastReceivedQuantity.value,
      );
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
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchIngredientStockCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('lastReceivedAt: $lastReceivedAt, ')
          ..write('lastReceivedQuantity: $lastReceivedQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $BranchItemStockTable extends BranchItemStock
    with TableInfo<$BranchItemStockTable, BranchItemStockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchItemStockTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minimumStockMeta = const VerificationMeta(
    'minimumStock',
  );
  @override
  late final GeneratedColumn<int> minimumStock = GeneratedColumn<int>(
    'minimum_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReceivedAtMeta = const VerificationMeta(
    'lastReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReceivedAt =
      GeneratedColumn<DateTime>(
        'last_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastReceivedQuantityMeta =
      const VerificationMeta('lastReceivedQuantity');
  @override
  late final GeneratedColumn<int> lastReceivedQuantity = GeneratedColumn<int>(
    'last_received_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    itemId,
    stock,
    sold,
    spoilage,
    price,
    costPrice,
    minimumStock,
    lastReceivedAt,
    lastReceivedQuantity,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branch_item_stock';
  @override
  VerificationContext validateIntegrity(
    Insertable<BranchItemStockData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
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
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
        _minimumStockMeta,
        minimumStock.isAcceptableOrUnknown(
          data['minimum_stock']!,
          _minimumStockMeta,
        ),
      );
    }
    if (data.containsKey('last_received_at')) {
      context.handle(
        _lastReceivedAtMeta,
        lastReceivedAt.isAcceptableOrUnknown(
          data['last_received_at']!,
          _lastReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_received_quantity')) {
      context.handle(
        _lastReceivedQuantityMeta,
        lastReceivedQuantity.isAcceptableOrUnknown(
          data['last_received_quantity']!,
          _lastReceivedQuantityMeta,
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {organizationId, itemId},
  ];
  @override
  BranchItemStockData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BranchItemStockData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
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
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      ),
      minimumStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_stock'],
      ),
      lastReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_received_at'],
      ),
      lastReceivedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_received_quantity'],
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $BranchItemStockTable createAlias(String alias) {
    return $BranchItemStockTable(attachedDatabase, alias);
  }
}

class BranchItemStockData extends DataClass
    implements Insertable<BranchItemStockData> {
  /// Primary key
  final int id;

  /// Which branch owns this stock
  final int organizationId;

  /// Reference to master item (for name, description, recipe, etc.)
  final int itemId;

  /// Current stock quantity at this branch
  final int stock;

  /// Total sold quantity (can be cumulative or daily-reset)
  final int sold;

  /// Total spoiled quantity
  final int spoilage;

  /// Branch-specific selling price (overrides master item price if set)
  final double? price;

  /// Branch-specific cost price (what they pay commissary)
  final double? costPrice;

  /// Minimum stock level for low stock alerts
  final int? minimumStock;

  /// Last time this branch received a delivery of this item
  final DateTime? lastReceivedAt;

  /// Quantity from last delivery
  final int? lastReceivedQuantity;

  /// Track when record was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Soft delete
  final bool isDeleted;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const BranchItemStockData({
    required this.id,
    required this.organizationId,
    required this.itemId,
    required this.stock,
    required this.sold,
    required this.spoilage,
    this.price,
    this.costPrice,
    this.minimumStock,
    this.lastReceivedAt,
    this.lastReceivedQuantity,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['organization_id'] = Variable<int>(organizationId);
    map['item_id'] = Variable<int>(itemId);
    map['stock'] = Variable<int>(stock);
    map['sold'] = Variable<int>(sold);
    map['spoilage'] = Variable<int>(spoilage);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || costPrice != null) {
      map['cost_price'] = Variable<double>(costPrice);
    }
    if (!nullToAbsent || minimumStock != null) {
      map['minimum_stock'] = Variable<int>(minimumStock);
    }
    if (!nullToAbsent || lastReceivedAt != null) {
      map['last_received_at'] = Variable<DateTime>(lastReceivedAt);
    }
    if (!nullToAbsent || lastReceivedQuantity != null) {
      map['last_received_quantity'] = Variable<int>(lastReceivedQuantity);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  BranchItemStockCompanion toCompanion(bool nullToAbsent) {
    return BranchItemStockCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      itemId: Value(itemId),
      stock: Value(stock),
      sold: Value(sold),
      spoilage: Value(spoilage),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      costPrice: costPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(costPrice),
      minimumStock: minimumStock == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumStock),
      lastReceivedAt: lastReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReceivedAt),
      lastReceivedQuantity: lastReceivedQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReceivedQuantity),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory BranchItemStockData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BranchItemStockData(
      id: serializer.fromJson<int>(json['id']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      stock: serializer.fromJson<int>(json['stock']),
      sold: serializer.fromJson<int>(json['sold']),
      spoilage: serializer.fromJson<int>(json['spoilage']),
      price: serializer.fromJson<double?>(json['price']),
      costPrice: serializer.fromJson<double?>(json['costPrice']),
      minimumStock: serializer.fromJson<int?>(json['minimumStock']),
      lastReceivedAt: serializer.fromJson<DateTime?>(json['lastReceivedAt']),
      lastReceivedQuantity: serializer.fromJson<int?>(
        json['lastReceivedQuantity'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'organizationId': serializer.toJson<int>(organizationId),
      'itemId': serializer.toJson<int>(itemId),
      'stock': serializer.toJson<int>(stock),
      'sold': serializer.toJson<int>(sold),
      'spoilage': serializer.toJson<int>(spoilage),
      'price': serializer.toJson<double?>(price),
      'costPrice': serializer.toJson<double?>(costPrice),
      'minimumStock': serializer.toJson<int?>(minimumStock),
      'lastReceivedAt': serializer.toJson<DateTime?>(lastReceivedAt),
      'lastReceivedQuantity': serializer.toJson<int?>(lastReceivedQuantity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  BranchItemStockData copyWith({
    int? id,
    int? organizationId,
    int? itemId,
    int? stock,
    int? sold,
    int? spoilage,
    Value<double?> price = const Value.absent(),
    Value<double?> costPrice = const Value.absent(),
    Value<int?> minimumStock = const Value.absent(),
    Value<DateTime?> lastReceivedAt = const Value.absent(),
    Value<int?> lastReceivedQuantity = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => BranchItemStockData(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    itemId: itemId ?? this.itemId,
    stock: stock ?? this.stock,
    sold: sold ?? this.sold,
    spoilage: spoilage ?? this.spoilage,
    price: price.present ? price.value : this.price,
    costPrice: costPrice.present ? costPrice.value : this.costPrice,
    minimumStock: minimumStock.present ? minimumStock.value : this.minimumStock,
    lastReceivedAt: lastReceivedAt.present
        ? lastReceivedAt.value
        : this.lastReceivedAt,
    lastReceivedQuantity: lastReceivedQuantity.present
        ? lastReceivedQuantity.value
        : this.lastReceivedQuantity,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  BranchItemStockData copyWithCompanion(BranchItemStockCompanion data) {
    return BranchItemStockData(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      stock: data.stock.present ? data.stock.value : this.stock,
      sold: data.sold.present ? data.sold.value : this.sold,
      spoilage: data.spoilage.present ? data.spoilage.value : this.spoilage,
      price: data.price.present ? data.price.value : this.price,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      lastReceivedAt: data.lastReceivedAt.present
          ? data.lastReceivedAt.value
          : this.lastReceivedAt,
      lastReceivedQuantity: data.lastReceivedQuantity.present
          ? data.lastReceivedQuantity.value
          : this.lastReceivedQuantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BranchItemStockData(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('itemId: $itemId, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('lastReceivedAt: $lastReceivedAt, ')
          ..write('lastReceivedQuantity: $lastReceivedQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    itemId,
    stock,
    sold,
    spoilage,
    price,
    costPrice,
    minimumStock,
    lastReceivedAt,
    lastReceivedQuantity,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BranchItemStockData &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.itemId == this.itemId &&
          other.stock == this.stock &&
          other.sold == this.sold &&
          other.spoilage == this.spoilage &&
          other.price == this.price &&
          other.costPrice == this.costPrice &&
          other.minimumStock == this.minimumStock &&
          other.lastReceivedAt == this.lastReceivedAt &&
          other.lastReceivedQuantity == this.lastReceivedQuantity &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class BranchItemStockCompanion extends UpdateCompanion<BranchItemStockData> {
  final Value<int> id;
  final Value<int> organizationId;
  final Value<int> itemId;
  final Value<int> stock;
  final Value<int> sold;
  final Value<int> spoilage;
  final Value<double?> price;
  final Value<double?> costPrice;
  final Value<int?> minimumStock;
  final Value<DateTime?> lastReceivedAt;
  final Value<int?> lastReceivedQuantity;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const BranchItemStockCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.lastReceivedAt = const Value.absent(),
    this.lastReceivedQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  BranchItemStockCompanion.insert({
    this.id = const Value.absent(),
    required int organizationId,
    required int itemId,
    this.stock = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.lastReceivedAt = const Value.absent(),
    this.lastReceivedQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : organizationId = Value(organizationId),
       itemId = Value(itemId);
  static Insertable<BranchItemStockData> custom({
    Expression<int>? id,
    Expression<int>? organizationId,
    Expression<int>? itemId,
    Expression<int>? stock,
    Expression<int>? sold,
    Expression<int>? spoilage,
    Expression<double>? price,
    Expression<double>? costPrice,
    Expression<int>? minimumStock,
    Expression<DateTime>? lastReceivedAt,
    Expression<int>? lastReceivedQuantity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (itemId != null) 'item_id': itemId,
      if (stock != null) 'stock': stock,
      if (sold != null) 'sold': sold,
      if (spoilage != null) 'spoilage': spoilage,
      if (price != null) 'price': price,
      if (costPrice != null) 'cost_price': costPrice,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (lastReceivedAt != null) 'last_received_at': lastReceivedAt,
      if (lastReceivedQuantity != null)
        'last_received_quantity': lastReceivedQuantity,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  BranchItemStockCompanion copyWith({
    Value<int>? id,
    Value<int>? organizationId,
    Value<int>? itemId,
    Value<int>? stock,
    Value<int>? sold,
    Value<int>? spoilage,
    Value<double?>? price,
    Value<double?>? costPrice,
    Value<int?>? minimumStock,
    Value<DateTime?>? lastReceivedAt,
    Value<int?>? lastReceivedQuantity,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return BranchItemStockCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      itemId: itemId ?? this.itemId,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      spoilage: spoilage ?? this.spoilage,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      minimumStock: minimumStock ?? this.minimumStock,
      lastReceivedAt: lastReceivedAt ?? this.lastReceivedAt,
      lastReceivedQuantity: lastReceivedQuantity ?? this.lastReceivedQuantity,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
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
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<int>(minimumStock.value);
    }
    if (lastReceivedAt.present) {
      map['last_received_at'] = Variable<DateTime>(lastReceivedAt.value);
    }
    if (lastReceivedQuantity.present) {
      map['last_received_quantity'] = Variable<int>(lastReceivedQuantity.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchItemStockCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('itemId: $itemId, ')
          ..write('stock: $stock, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('lastReceivedAt: $lastReceivedAt, ')
          ..write('lastReceivedQuantity: $lastReceivedQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $StockReplenishmentRequestsTable extends StockReplenishmentRequests
    with
        TableInfo<$StockReplenishmentRequestsTable, StockReplenishmentRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockReplenishmentRequestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _franchiseeIdMeta = const VerificationMeta(
    'franchiseeId',
  );
  @override
  late final GeneratedColumn<int> franchiseeId = GeneratedColumn<int>(
    'franchisee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _commissaryIdMeta = const VerificationMeta(
    'commissaryId',
  );
  @override
  late final GeneratedColumn<int> commissaryId = GeneratedColumn<int>(
    'commissary_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _quantityRequestedMeta = const VerificationMeta(
    'quantityRequested',
  );
  @override
  late final GeneratedColumn<int> quantityRequested = GeneratedColumn<int>(
    'quantity_requested',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<int> requestedBy = GeneratedColumn<int>(
    'requested_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _reviewedByMeta = const VerificationMeta(
    'reviewedBy',
  );
  @override
  late final GeneratedColumn<int> reviewedBy = GeneratedColumn<int>(
    'reviewed_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryDateMeta = const VerificationMeta(
    'deliveryDate',
  );
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
    'delivery_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _franchiseeNotesMeta = const VerificationMeta(
    'franchiseeNotes',
  );
  @override
  late final GeneratedColumn<String> franchiseeNotes = GeneratedColumn<String>(
    'franchisee_notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissaryNotesMeta = const VerificationMeta(
    'commissaryNotes',
  );
  @override
  late final GeneratedColumn<String> commissaryNotes = GeneratedColumn<String>(
    'commissary_notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    franchiseeId,
    commissaryId,
    itemId,
    quantityRequested,
    status,
    requestedBy,
    requestedAt,
    reviewedBy,
    reviewedAt,
    deliveryDate,
    franchiseeNotes,
    commissaryNotes,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_replenishment_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockReplenishmentRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('franchisee_id')) {
      context.handle(
        _franchiseeIdMeta,
        franchiseeId.isAcceptableOrUnknown(
          data['franchisee_id']!,
          _franchiseeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_franchiseeIdMeta);
    }
    if (data.containsKey('commissary_id')) {
      context.handle(
        _commissaryIdMeta,
        commissaryId.isAcceptableOrUnknown(
          data['commissary_id']!,
          _commissaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commissaryIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity_requested')) {
      context.handle(
        _quantityRequestedMeta,
        quantityRequested.isAcceptableOrUnknown(
          data['quantity_requested']!,
          _quantityRequestedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityRequestedMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByMeta);
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_by')) {
      context.handle(
        _reviewedByMeta,
        reviewedBy.isAcceptableOrUnknown(data['reviewed_by']!, _reviewedByMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
        _deliveryDateMeta,
        deliveryDate.isAcceptableOrUnknown(
          data['delivery_date']!,
          _deliveryDateMeta,
        ),
      );
    }
    if (data.containsKey('franchisee_notes')) {
      context.handle(
        _franchiseeNotesMeta,
        franchiseeNotes.isAcceptableOrUnknown(
          data['franchisee_notes']!,
          _franchiseeNotesMeta,
        ),
      );
    }
    if (data.containsKey('commissary_notes')) {
      context.handle(
        _commissaryNotesMeta,
        commissaryNotes.isAcceptableOrUnknown(
          data['commissary_notes']!,
          _commissaryNotesMeta,
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockReplenishmentRequest map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockReplenishmentRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      franchiseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}franchisee_id'],
      )!,
      commissaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commissary_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      quantityRequested: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_requested'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_by'],
      )!,
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      )!,
      reviewedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_by'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      deliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivery_date'],
      ),
      franchiseeNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}franchisee_notes'],
      ),
      commissaryNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commissary_notes'],
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $StockReplenishmentRequestsTable createAlias(String alias) {
    return $StockReplenishmentRequestsTable(attachedDatabase, alias);
  }
}

class StockReplenishmentRequest extends DataClass
    implements Insertable<StockReplenishmentRequest> {
  final int id;

  /// ✅ FIXED: Added @ReferenceName to distinguish franchisee vs commissary
  final int franchiseeId;
  final int commissaryId;
  final int itemId;
  final int quantityRequested;
  final String status;

  /// ✅ FIXED: Added @ReferenceName to distinguish requester vs reviewer
  final int requestedBy;
  final DateTime requestedAt;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? deliveryDate;
  final String? franchiseeNotes;
  final String? commissaryNotes;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isDeleted;
  final bool isSynced;
  final String? cloudId;
  const StockReplenishmentRequest({
    required this.id,
    required this.franchiseeId,
    required this.commissaryId,
    required this.itemId,
    required this.quantityRequested,
    required this.status,
    required this.requestedBy,
    required this.requestedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.deliveryDate,
    this.franchiseeNotes,
    this.commissaryNotes,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['franchisee_id'] = Variable<int>(franchiseeId);
    map['commissary_id'] = Variable<int>(commissaryId);
    map['item_id'] = Variable<int>(itemId);
    map['quantity_requested'] = Variable<int>(quantityRequested);
    map['status'] = Variable<String>(status);
    map['requested_by'] = Variable<int>(requestedBy);
    map['requested_at'] = Variable<DateTime>(requestedAt);
    if (!nullToAbsent || reviewedBy != null) {
      map['reviewed_by'] = Variable<int>(reviewedBy);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    if (!nullToAbsent || deliveryDate != null) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate);
    }
    if (!nullToAbsent || franchiseeNotes != null) {
      map['franchisee_notes'] = Variable<String>(franchiseeNotes);
    }
    if (!nullToAbsent || commissaryNotes != null) {
      map['commissary_notes'] = Variable<String>(commissaryNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  StockReplenishmentRequestsCompanion toCompanion(bool nullToAbsent) {
    return StockReplenishmentRequestsCompanion(
      id: Value(id),
      franchiseeId: Value(franchiseeId),
      commissaryId: Value(commissaryId),
      itemId: Value(itemId),
      quantityRequested: Value(quantityRequested),
      status: Value(status),
      requestedBy: Value(requestedBy),
      requestedAt: Value(requestedAt),
      reviewedBy: reviewedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedBy),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      deliveryDate: deliveryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryDate),
      franchiseeNotes: franchiseeNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(franchiseeNotes),
      commissaryNotes: commissaryNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(commissaryNotes),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory StockReplenishmentRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockReplenishmentRequest(
      id: serializer.fromJson<int>(json['id']),
      franchiseeId: serializer.fromJson<int>(json['franchiseeId']),
      commissaryId: serializer.fromJson<int>(json['commissaryId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      quantityRequested: serializer.fromJson<int>(json['quantityRequested']),
      status: serializer.fromJson<String>(json['status']),
      requestedBy: serializer.fromJson<int>(json['requestedBy']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
      reviewedBy: serializer.fromJson<int?>(json['reviewedBy']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      deliveryDate: serializer.fromJson<DateTime?>(json['deliveryDate']),
      franchiseeNotes: serializer.fromJson<String?>(json['franchiseeNotes']),
      commissaryNotes: serializer.fromJson<String?>(json['commissaryNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'franchiseeId': serializer.toJson<int>(franchiseeId),
      'commissaryId': serializer.toJson<int>(commissaryId),
      'itemId': serializer.toJson<int>(itemId),
      'quantityRequested': serializer.toJson<int>(quantityRequested),
      'status': serializer.toJson<String>(status),
      'requestedBy': serializer.toJson<int>(requestedBy),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
      'reviewedBy': serializer.toJson<int?>(reviewedBy),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'deliveryDate': serializer.toJson<DateTime?>(deliveryDate),
      'franchiseeNotes': serializer.toJson<String?>(franchiseeNotes),
      'commissaryNotes': serializer.toJson<String?>(commissaryNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  StockReplenishmentRequest copyWith({
    int? id,
    int? franchiseeId,
    int? commissaryId,
    int? itemId,
    int? quantityRequested,
    String? status,
    int? requestedBy,
    DateTime? requestedAt,
    Value<int?> reviewedBy = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
    Value<DateTime?> deliveryDate = const Value.absent(),
    Value<String?> franchiseeNotes = const Value.absent(),
    Value<String?> commissaryNotes = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => StockReplenishmentRequest(
    id: id ?? this.id,
    franchiseeId: franchiseeId ?? this.franchiseeId,
    commissaryId: commissaryId ?? this.commissaryId,
    itemId: itemId ?? this.itemId,
    quantityRequested: quantityRequested ?? this.quantityRequested,
    status: status ?? this.status,
    requestedBy: requestedBy ?? this.requestedBy,
    requestedAt: requestedAt ?? this.requestedAt,
    reviewedBy: reviewedBy.present ? reviewedBy.value : this.reviewedBy,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    deliveryDate: deliveryDate.present ? deliveryDate.value : this.deliveryDate,
    franchiseeNotes: franchiseeNotes.present
        ? franchiseeNotes.value
        : this.franchiseeNotes,
    commissaryNotes: commissaryNotes.present
        ? commissaryNotes.value
        : this.commissaryNotes,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  StockReplenishmentRequest copyWithCompanion(
    StockReplenishmentRequestsCompanion data,
  ) {
    return StockReplenishmentRequest(
      id: data.id.present ? data.id.value : this.id,
      franchiseeId: data.franchiseeId.present
          ? data.franchiseeId.value
          : this.franchiseeId,
      commissaryId: data.commissaryId.present
          ? data.commissaryId.value
          : this.commissaryId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantityRequested: data.quantityRequested.present
          ? data.quantityRequested.value
          : this.quantityRequested,
      status: data.status.present ? data.status.value : this.status,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      requestedAt: data.requestedAt.present
          ? data.requestedAt.value
          : this.requestedAt,
      reviewedBy: data.reviewedBy.present
          ? data.reviewedBy.value
          : this.reviewedBy,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      franchiseeNotes: data.franchiseeNotes.present
          ? data.franchiseeNotes.value
          : this.franchiseeNotes,
      commissaryNotes: data.commissaryNotes.present
          ? data.commissaryNotes.value
          : this.commissaryNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockReplenishmentRequest(')
          ..write('id: $id, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityRequested: $quantityRequested, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('franchiseeNotes: $franchiseeNotes, ')
          ..write('commissaryNotes: $commissaryNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    franchiseeId,
    commissaryId,
    itemId,
    quantityRequested,
    status,
    requestedBy,
    requestedAt,
    reviewedBy,
    reviewedAt,
    deliveryDate,
    franchiseeNotes,
    commissaryNotes,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockReplenishmentRequest &&
          other.id == this.id &&
          other.franchiseeId == this.franchiseeId &&
          other.commissaryId == this.commissaryId &&
          other.itemId == this.itemId &&
          other.quantityRequested == this.quantityRequested &&
          other.status == this.status &&
          other.requestedBy == this.requestedBy &&
          other.requestedAt == this.requestedAt &&
          other.reviewedBy == this.reviewedBy &&
          other.reviewedAt == this.reviewedAt &&
          other.deliveryDate == this.deliveryDate &&
          other.franchiseeNotes == this.franchiseeNotes &&
          other.commissaryNotes == this.commissaryNotes &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class StockReplenishmentRequestsCompanion
    extends UpdateCompanion<StockReplenishmentRequest> {
  final Value<int> id;
  final Value<int> franchiseeId;
  final Value<int> commissaryId;
  final Value<int> itemId;
  final Value<int> quantityRequested;
  final Value<String> status;
  final Value<int> requestedBy;
  final Value<DateTime> requestedAt;
  final Value<int?> reviewedBy;
  final Value<DateTime?> reviewedAt;
  final Value<DateTime?> deliveryDate;
  final Value<String?> franchiseeNotes;
  final Value<String?> commissaryNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const StockReplenishmentRequestsCompanion({
    this.id = const Value.absent(),
    this.franchiseeId = const Value.absent(),
    this.commissaryId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantityRequested = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.franchiseeNotes = const Value.absent(),
    this.commissaryNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  StockReplenishmentRequestsCompanion.insert({
    this.id = const Value.absent(),
    required int franchiseeId,
    required int commissaryId,
    required int itemId,
    required int quantityRequested,
    this.status = const Value.absent(),
    required int requestedBy,
    this.requestedAt = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.franchiseeNotes = const Value.absent(),
    this.commissaryNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : franchiseeId = Value(franchiseeId),
       commissaryId = Value(commissaryId),
       itemId = Value(itemId),
       quantityRequested = Value(quantityRequested),
       requestedBy = Value(requestedBy);
  static Insertable<StockReplenishmentRequest> custom({
    Expression<int>? id,
    Expression<int>? franchiseeId,
    Expression<int>? commissaryId,
    Expression<int>? itemId,
    Expression<int>? quantityRequested,
    Expression<String>? status,
    Expression<int>? requestedBy,
    Expression<DateTime>? requestedAt,
    Expression<int>? reviewedBy,
    Expression<DateTime>? reviewedAt,
    Expression<DateTime>? deliveryDate,
    Expression<String>? franchiseeNotes,
    Expression<String>? commissaryNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (franchiseeId != null) 'franchisee_id': franchiseeId,
      if (commissaryId != null) 'commissary_id': commissaryId,
      if (itemId != null) 'item_id': itemId,
      if (quantityRequested != null) 'quantity_requested': quantityRequested,
      if (status != null) 'status': status,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (franchiseeNotes != null) 'franchisee_notes': franchiseeNotes,
      if (commissaryNotes != null) 'commissary_notes': commissaryNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  StockReplenishmentRequestsCompanion copyWith({
    Value<int>? id,
    Value<int>? franchiseeId,
    Value<int>? commissaryId,
    Value<int>? itemId,
    Value<int>? quantityRequested,
    Value<String>? status,
    Value<int>? requestedBy,
    Value<DateTime>? requestedAt,
    Value<int?>? reviewedBy,
    Value<DateTime?>? reviewedAt,
    Value<DateTime?>? deliveryDate,
    Value<String?>? franchiseeNotes,
    Value<String?>? commissaryNotes,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return StockReplenishmentRequestsCompanion(
      id: id ?? this.id,
      franchiseeId: franchiseeId ?? this.franchiseeId,
      commissaryId: commissaryId ?? this.commissaryId,
      itemId: itemId ?? this.itemId,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      franchiseeNotes: franchiseeNotes ?? this.franchiseeNotes,
      commissaryNotes: commissaryNotes ?? this.commissaryNotes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (franchiseeId.present) {
      map['franchisee_id'] = Variable<int>(franchiseeId.value);
    }
    if (commissaryId.present) {
      map['commissary_id'] = Variable<int>(commissaryId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (quantityRequested.present) {
      map['quantity_requested'] = Variable<int>(quantityRequested.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<int>(requestedBy.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (reviewedBy.present) {
      map['reviewed_by'] = Variable<int>(reviewedBy.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    if (franchiseeNotes.present) {
      map['franchisee_notes'] = Variable<String>(franchiseeNotes.value);
    }
    if (commissaryNotes.present) {
      map['commissary_notes'] = Variable<String>(commissaryNotes.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockReplenishmentRequestsCompanion(')
          ..write('id: $id, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityRequested: $quantityRequested, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('franchiseeNotes: $franchiseeNotes, ')
          ..write('commissaryNotes: $commissaryNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $StockChangeRequestsTable extends StockChangeRequests
    with TableInfo<$StockChangeRequestsTable, StockChangeRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockChangeRequestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _franchiseeIdMeta = const VerificationMeta(
    'franchiseeId',
  );
  @override
  late final GeneratedColumn<int> franchiseeId = GeneratedColumn<int>(
    'franchisee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _changeTypeMeta = const VerificationMeta(
    'changeType',
  );
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
    'change_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<int> requestedBy = GeneratedColumn<int>(
    'requested_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedByMeta = const VerificationMeta(
    'reviewedBy',
  );
  @override
  late final GeneratedColumn<int> reviewedBy = GeneratedColumn<int>(
    'reviewed_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewNotesMeta = const VerificationMeta(
    'reviewNotes',
  );
  @override
  late final GeneratedColumn<String> reviewNotes = GeneratedColumn<String>(
    'review_notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalStockMeta = const VerificationMeta(
    'originalStock',
  );
  @override
  late final GeneratedColumn<int> originalStock = GeneratedColumn<int>(
    'original_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    franchiseeId,
    itemId,
    changeType,
    quantity,
    status,
    requestedBy,
    requestedAt,
    submittedAt,
    reviewedBy,
    reviewedAt,
    reason,
    reviewNotes,
    originalStock,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_change_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockChangeRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('franchisee_id')) {
      context.handle(
        _franchiseeIdMeta,
        franchiseeId.isAcceptableOrUnknown(
          data['franchisee_id']!,
          _franchiseeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_franchiseeIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
        _changeTypeMeta,
        changeType.isAcceptableOrUnknown(data['change_type']!, _changeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByMeta);
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_by')) {
      context.handle(
        _reviewedByMeta,
        reviewedBy.isAcceptableOrUnknown(data['reviewed_by']!, _reviewedByMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('review_notes')) {
      context.handle(
        _reviewNotesMeta,
        reviewNotes.isAcceptableOrUnknown(
          data['review_notes']!,
          _reviewNotesMeta,
        ),
      );
    }
    if (data.containsKey('original_stock')) {
      context.handle(
        _originalStockMeta,
        originalStock.isAcceptableOrUnknown(
          data['original_stock']!,
          _originalStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalStockMeta);
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockChangeRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockChangeRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      franchiseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}franchisee_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      changeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_by'],
      )!,
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
      reviewedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_by'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      reviewNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_notes'],
      ),
      originalStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_stock'],
      )!,
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
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $StockChangeRequestsTable createAlias(String alias) {
    return $StockChangeRequestsTable(attachedDatabase, alias);
  }
}

class StockChangeRequest extends DataClass
    implements Insertable<StockChangeRequest> {
  final int id;
  final int franchiseeId;
  final int itemId;
  final String changeType;
  final int quantity;
  final String status;

  /// ✅ FIXED: Added @ReferenceName to distinguish requester vs reviewer
  final int requestedBy;
  final DateTime requestedAt;
  final DateTime? submittedAt;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final String? reason;
  final String? reviewNotes;
  final int originalStock;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isDeleted;
  final bool isSynced;
  final String? cloudId;
  const StockChangeRequest({
    required this.id,
    required this.franchiseeId,
    required this.itemId,
    required this.changeType,
    required this.quantity,
    required this.status,
    required this.requestedBy,
    required this.requestedAt,
    this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reason,
    this.reviewNotes,
    required this.originalStock,
    required this.createdAt,
    required this.lastUpdated,
    required this.isDeleted,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['franchisee_id'] = Variable<int>(franchiseeId);
    map['item_id'] = Variable<int>(itemId);
    map['change_type'] = Variable<String>(changeType);
    map['quantity'] = Variable<int>(quantity);
    map['status'] = Variable<String>(status);
    map['requested_by'] = Variable<int>(requestedBy);
    map['requested_at'] = Variable<DateTime>(requestedAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    if (!nullToAbsent || reviewedBy != null) {
      map['reviewed_by'] = Variable<int>(reviewedBy);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || reviewNotes != null) {
      map['review_notes'] = Variable<String>(reviewNotes);
    }
    map['original_stock'] = Variable<int>(originalStock);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  StockChangeRequestsCompanion toCompanion(bool nullToAbsent) {
    return StockChangeRequestsCompanion(
      id: Value(id),
      franchiseeId: Value(franchiseeId),
      itemId: Value(itemId),
      changeType: Value(changeType),
      quantity: Value(quantity),
      status: Value(status),
      requestedBy: Value(requestedBy),
      requestedAt: Value(requestedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      reviewedBy: reviewedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedBy),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      reviewNotes: reviewNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewNotes),
      originalStock: Value(originalStock),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory StockChangeRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockChangeRequest(
      id: serializer.fromJson<int>(json['id']),
      franchiseeId: serializer.fromJson<int>(json['franchiseeId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      status: serializer.fromJson<String>(json['status']),
      requestedBy: serializer.fromJson<int>(json['requestedBy']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
      reviewedBy: serializer.fromJson<int?>(json['reviewedBy']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      reason: serializer.fromJson<String?>(json['reason']),
      reviewNotes: serializer.fromJson<String?>(json['reviewNotes']),
      originalStock: serializer.fromJson<int>(json['originalStock']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'franchiseeId': serializer.toJson<int>(franchiseeId),
      'itemId': serializer.toJson<int>(itemId),
      'changeType': serializer.toJson<String>(changeType),
      'quantity': serializer.toJson<int>(quantity),
      'status': serializer.toJson<String>(status),
      'requestedBy': serializer.toJson<int>(requestedBy),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
      'reviewedBy': serializer.toJson<int?>(reviewedBy),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'reason': serializer.toJson<String?>(reason),
      'reviewNotes': serializer.toJson<String?>(reviewNotes),
      'originalStock': serializer.toJson<int>(originalStock),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  StockChangeRequest copyWith({
    int? id,
    int? franchiseeId,
    int? itemId,
    String? changeType,
    int? quantity,
    String? status,
    int? requestedBy,
    DateTime? requestedAt,
    Value<DateTime?> submittedAt = const Value.absent(),
    Value<int?> reviewedBy = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    Value<String?> reviewNotes = const Value.absent(),
    int? originalStock,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isDeleted,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => StockChangeRequest(
    id: id ?? this.id,
    franchiseeId: franchiseeId ?? this.franchiseeId,
    itemId: itemId ?? this.itemId,
    changeType: changeType ?? this.changeType,
    quantity: quantity ?? this.quantity,
    status: status ?? this.status,
    requestedBy: requestedBy ?? this.requestedBy,
    requestedAt: requestedAt ?? this.requestedAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    reviewedBy: reviewedBy.present ? reviewedBy.value : this.reviewedBy,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    reason: reason.present ? reason.value : this.reason,
    reviewNotes: reviewNotes.present ? reviewNotes.value : this.reviewNotes,
    originalStock: originalStock ?? this.originalStock,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  StockChangeRequest copyWithCompanion(StockChangeRequestsCompanion data) {
    return StockChangeRequest(
      id: data.id.present ? data.id.value : this.id,
      franchiseeId: data.franchiseeId.present
          ? data.franchiseeId.value
          : this.franchiseeId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      status: data.status.present ? data.status.value : this.status,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      requestedAt: data.requestedAt.present
          ? data.requestedAt.value
          : this.requestedAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      reviewedBy: data.reviewedBy.present
          ? data.reviewedBy.value
          : this.reviewedBy,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      reviewNotes: data.reviewNotes.present
          ? data.reviewNotes.value
          : this.reviewNotes,
      originalStock: data.originalStock.present
          ? data.originalStock.value
          : this.originalStock,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockChangeRequest(')
          ..write('id: $id, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('itemId: $itemId, ')
          ..write('changeType: $changeType, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('reason: $reason, ')
          ..write('reviewNotes: $reviewNotes, ')
          ..write('originalStock: $originalStock, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    franchiseeId,
    itemId,
    changeType,
    quantity,
    status,
    requestedBy,
    requestedAt,
    submittedAt,
    reviewedBy,
    reviewedAt,
    reason,
    reviewNotes,
    originalStock,
    createdAt,
    lastUpdated,
    isDeleted,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockChangeRequest &&
          other.id == this.id &&
          other.franchiseeId == this.franchiseeId &&
          other.itemId == this.itemId &&
          other.changeType == this.changeType &&
          other.quantity == this.quantity &&
          other.status == this.status &&
          other.requestedBy == this.requestedBy &&
          other.requestedAt == this.requestedAt &&
          other.submittedAt == this.submittedAt &&
          other.reviewedBy == this.reviewedBy &&
          other.reviewedAt == this.reviewedAt &&
          other.reason == this.reason &&
          other.reviewNotes == this.reviewNotes &&
          other.originalStock == this.originalStock &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class StockChangeRequestsCompanion extends UpdateCompanion<StockChangeRequest> {
  final Value<int> id;
  final Value<int> franchiseeId;
  final Value<int> itemId;
  final Value<String> changeType;
  final Value<int> quantity;
  final Value<String> status;
  final Value<int> requestedBy;
  final Value<DateTime> requestedAt;
  final Value<DateTime?> submittedAt;
  final Value<int?> reviewedBy;
  final Value<DateTime?> reviewedAt;
  final Value<String?> reason;
  final Value<String?> reviewNotes;
  final Value<int> originalStock;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const StockChangeRequestsCompanion({
    this.id = const Value.absent(),
    this.franchiseeId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.reviewNotes = const Value.absent(),
    this.originalStock = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  StockChangeRequestsCompanion.insert({
    this.id = const Value.absent(),
    required int franchiseeId,
    required int itemId,
    required String changeType,
    required int quantity,
    this.status = const Value.absent(),
    required int requestedBy,
    this.requestedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.reviewNotes = const Value.absent(),
    required int originalStock,
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : franchiseeId = Value(franchiseeId),
       itemId = Value(itemId),
       changeType = Value(changeType),
       quantity = Value(quantity),
       requestedBy = Value(requestedBy),
       originalStock = Value(originalStock);
  static Insertable<StockChangeRequest> custom({
    Expression<int>? id,
    Expression<int>? franchiseeId,
    Expression<int>? itemId,
    Expression<String>? changeType,
    Expression<int>? quantity,
    Expression<String>? status,
    Expression<int>? requestedBy,
    Expression<DateTime>? requestedAt,
    Expression<DateTime>? submittedAt,
    Expression<int>? reviewedBy,
    Expression<DateTime>? reviewedAt,
    Expression<String>? reason,
    Expression<String>? reviewNotes,
    Expression<int>? originalStock,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (franchiseeId != null) 'franchisee_id': franchiseeId,
      if (itemId != null) 'item_id': itemId,
      if (changeType != null) 'change_type': changeType,
      if (quantity != null) 'quantity': quantity,
      if (status != null) 'status': status,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (reason != null) 'reason': reason,
      if (reviewNotes != null) 'review_notes': reviewNotes,
      if (originalStock != null) 'original_stock': originalStock,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  StockChangeRequestsCompanion copyWith({
    Value<int>? id,
    Value<int>? franchiseeId,
    Value<int>? itemId,
    Value<String>? changeType,
    Value<int>? quantity,
    Value<String>? status,
    Value<int>? requestedBy,
    Value<DateTime>? requestedAt,
    Value<DateTime?>? submittedAt,
    Value<int?>? reviewedBy,
    Value<DateTime?>? reviewedAt,
    Value<String?>? reason,
    Value<String?>? reviewNotes,
    Value<int>? originalStock,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return StockChangeRequestsCompanion(
      id: id ?? this.id,
      franchiseeId: franchiseeId ?? this.franchiseeId,
      itemId: itemId ?? this.itemId,
      changeType: changeType ?? this.changeType,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reason: reason ?? this.reason,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      originalStock: originalStock ?? this.originalStock,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (franchiseeId.present) {
      map['franchisee_id'] = Variable<int>(franchiseeId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<int>(requestedBy.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (reviewedBy.present) {
      map['reviewed_by'] = Variable<int>(reviewedBy.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (reviewNotes.present) {
      map['review_notes'] = Variable<String>(reviewNotes.value);
    }
    if (originalStock.present) {
      map['original_stock'] = Variable<int>(originalStock.value);
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
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockChangeRequestsCompanion(')
          ..write('id: $id, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('itemId: $itemId, ')
          ..write('changeType: $changeType, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('reason: $reason, ')
          ..write('reviewNotes: $reviewNotes, ')
          ..write('originalStock: $originalStock, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

class $DailySalesSummaryTable extends DailySalesSummary
    with TableInfo<$DailySalesSummaryTable, DailySalesSummaryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySalesSummaryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _summaryDateMeta = const VerificationMeta(
    'summaryDate',
  );
  @override
  late final GeneratedColumn<DateTime> summaryDate = GeneratedColumn<DateTime>(
    'summary_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantitySoldMeta = const VerificationMeta(
    'quantitySold',
  );
  @override
  late final GeneratedColumn<int> quantitySold = GeneratedColumn<int>(
    'quantity_sold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quantitySpoiledMeta = const VerificationMeta(
    'quantitySpoiled',
  );
  @override
  late final GeneratedColumn<int> quantitySpoiled = GeneratedColumn<int>(
    'quantity_spoiled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revenueMeta = const VerificationMeta(
    'revenue',
  );
  @override
  late final GeneratedColumn<double> revenue = GeneratedColumn<double>(
    'revenue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _costOfGoodsSoldMeta = const VerificationMeta(
    'costOfGoodsSold',
  );
  @override
  late final GeneratedColumn<double> costOfGoodsSold = GeneratedColumn<double>(
    'cost_of_goods_sold',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _grossProfitMeta = const VerificationMeta(
    'grossProfit',
  );
  @override
  late final GeneratedColumn<double> grossProfit = GeneratedColumn<double>(
    'gross_profit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _transactionCountMeta = const VerificationMeta(
    'transactionCount',
  );
  @override
  late final GeneratedColumn<int> transactionCount = GeneratedColumn<int>(
    'transaction_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _openingStockMeta = const VerificationMeta(
    'openingStock',
  );
  @override
  late final GeneratedColumn<int> openingStock = GeneratedColumn<int>(
    'opening_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closingStockMeta = const VerificationMeta(
    'closingStock',
  );
  @override
  late final GeneratedColumn<int> closingStock = GeneratedColumn<int>(
    'closing_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    itemId,
    summaryDate,
    quantitySold,
    quantitySpoiled,
    revenue,
    costOfGoodsSold,
    grossProfit,
    transactionCount,
    openingStock,
    closingStock,
    createdAt,
    lastUpdated,
    isSynced,
    cloudId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_sales_summary';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySalesSummaryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('summary_date')) {
      context.handle(
        _summaryDateMeta,
        summaryDate.isAcceptableOrUnknown(
          data['summary_date']!,
          _summaryDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryDateMeta);
    }
    if (data.containsKey('quantity_sold')) {
      context.handle(
        _quantitySoldMeta,
        quantitySold.isAcceptableOrUnknown(
          data['quantity_sold']!,
          _quantitySoldMeta,
        ),
      );
    }
    if (data.containsKey('quantity_spoiled')) {
      context.handle(
        _quantitySpoiledMeta,
        quantitySpoiled.isAcceptableOrUnknown(
          data['quantity_spoiled']!,
          _quantitySpoiledMeta,
        ),
      );
    }
    if (data.containsKey('revenue')) {
      context.handle(
        _revenueMeta,
        revenue.isAcceptableOrUnknown(data['revenue']!, _revenueMeta),
      );
    }
    if (data.containsKey('cost_of_goods_sold')) {
      context.handle(
        _costOfGoodsSoldMeta,
        costOfGoodsSold.isAcceptableOrUnknown(
          data['cost_of_goods_sold']!,
          _costOfGoodsSoldMeta,
        ),
      );
    }
    if (data.containsKey('gross_profit')) {
      context.handle(
        _grossProfitMeta,
        grossProfit.isAcceptableOrUnknown(
          data['gross_profit']!,
          _grossProfitMeta,
        ),
      );
    }
    if (data.containsKey('transaction_count')) {
      context.handle(
        _transactionCountMeta,
        transactionCount.isAcceptableOrUnknown(
          data['transaction_count']!,
          _transactionCountMeta,
        ),
      );
    }
    if (data.containsKey('opening_stock')) {
      context.handle(
        _openingStockMeta,
        openingStock.isAcceptableOrUnknown(
          data['opening_stock']!,
          _openingStockMeta,
        ),
      );
    }
    if (data.containsKey('closing_stock')) {
      context.handle(
        _closingStockMeta,
        closingStock.isAcceptableOrUnknown(
          data['closing_stock']!,
          _closingStockMeta,
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {organizationId, itemId, summaryDate},
  ];
  @override
  DailySalesSummaryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySalesSummaryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      summaryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}summary_date'],
      )!,
      quantitySold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_sold'],
      )!,
      quantitySpoiled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_spoiled'],
      )!,
      revenue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}revenue'],
      )!,
      costOfGoodsSold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_of_goods_sold'],
      )!,
      grossProfit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_profit'],
      )!,
      transactionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_count'],
      )!,
      openingStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_stock'],
      ),
      closingStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_stock'],
      ),
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
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
    );
  }

  @override
  $DailySalesSummaryTable createAlias(String alias) {
    return $DailySalesSummaryTable(attachedDatabase, alias);
  }
}

class DailySalesSummaryData extends DataClass
    implements Insertable<DailySalesSummaryData> {
  /// Primary key
  final int id;

  /// Which branch this summary belongs to
  final int organizationId;

  /// Which item was sold
  final int itemId;

  /// The date this summary covers (stored as date only, no time)
  final DateTime summaryDate;

  /// Total quantity sold on this date
  final int quantitySold;

  /// Total quantity spoiled on this date
  final int quantitySpoiled;

  /// Total revenue from sales (quantitySold * price at time of sale)
  final double revenue;

  /// Total cost of goods sold (quantitySold * costPrice)
  /// Used by commissary to track profit margins
  final double costOfGoodsSold;

  /// Gross profit for this day (revenue - costOfGoodsSold)
  final double grossProfit;

  /// Number of transactions that contributed to this summary
  final int transactionCount;

  /// Opening stock at start of day (for reconciliation)
  final int? openingStock;

  /// Closing stock at end of day (for reconciliation)
  final int? closingStock;

  /// Track when summary was created/modified
  final DateTime createdAt;
  final DateTime lastUpdated;

  /// Sync fields for cloud synchronization
  final bool isSynced;
  final String? cloudId;
  const DailySalesSummaryData({
    required this.id,
    required this.organizationId,
    required this.itemId,
    required this.summaryDate,
    required this.quantitySold,
    required this.quantitySpoiled,
    required this.revenue,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.transactionCount,
    this.openingStock,
    this.closingStock,
    required this.createdAt,
    required this.lastUpdated,
    required this.isSynced,
    this.cloudId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['organization_id'] = Variable<int>(organizationId);
    map['item_id'] = Variable<int>(itemId);
    map['summary_date'] = Variable<DateTime>(summaryDate);
    map['quantity_sold'] = Variable<int>(quantitySold);
    map['quantity_spoiled'] = Variable<int>(quantitySpoiled);
    map['revenue'] = Variable<double>(revenue);
    map['cost_of_goods_sold'] = Variable<double>(costOfGoodsSold);
    map['gross_profit'] = Variable<double>(grossProfit);
    map['transaction_count'] = Variable<int>(transactionCount);
    if (!nullToAbsent || openingStock != null) {
      map['opening_stock'] = Variable<int>(openingStock);
    }
    if (!nullToAbsent || closingStock != null) {
      map['closing_stock'] = Variable<int>(closingStock);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    return map;
  }

  DailySalesSummaryCompanion toCompanion(bool nullToAbsent) {
    return DailySalesSummaryCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      itemId: Value(itemId),
      summaryDate: Value(summaryDate),
      quantitySold: Value(quantitySold),
      quantitySpoiled: Value(quantitySpoiled),
      revenue: Value(revenue),
      costOfGoodsSold: Value(costOfGoodsSold),
      grossProfit: Value(grossProfit),
      transactionCount: Value(transactionCount),
      openingStock: openingStock == null && nullToAbsent
          ? const Value.absent()
          : Value(openingStock),
      closingStock: closingStock == null && nullToAbsent
          ? const Value.absent()
          : Value(closingStock),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
    );
  }

  factory DailySalesSummaryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySalesSummaryData(
      id: serializer.fromJson<int>(json['id']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      summaryDate: serializer.fromJson<DateTime>(json['summaryDate']),
      quantitySold: serializer.fromJson<int>(json['quantitySold']),
      quantitySpoiled: serializer.fromJson<int>(json['quantitySpoiled']),
      revenue: serializer.fromJson<double>(json['revenue']),
      costOfGoodsSold: serializer.fromJson<double>(json['costOfGoodsSold']),
      grossProfit: serializer.fromJson<double>(json['grossProfit']),
      transactionCount: serializer.fromJson<int>(json['transactionCount']),
      openingStock: serializer.fromJson<int?>(json['openingStock']),
      closingStock: serializer.fromJson<int?>(json['closingStock']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'organizationId': serializer.toJson<int>(organizationId),
      'itemId': serializer.toJson<int>(itemId),
      'summaryDate': serializer.toJson<DateTime>(summaryDate),
      'quantitySold': serializer.toJson<int>(quantitySold),
      'quantitySpoiled': serializer.toJson<int>(quantitySpoiled),
      'revenue': serializer.toJson<double>(revenue),
      'costOfGoodsSold': serializer.toJson<double>(costOfGoodsSold),
      'grossProfit': serializer.toJson<double>(grossProfit),
      'transactionCount': serializer.toJson<int>(transactionCount),
      'openingStock': serializer.toJson<int?>(openingStock),
      'closingStock': serializer.toJson<int?>(closingStock),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'cloudId': serializer.toJson<String?>(cloudId),
    };
  }

  DailySalesSummaryData copyWith({
    int? id,
    int? organizationId,
    int? itemId,
    DateTime? summaryDate,
    int? quantitySold,
    int? quantitySpoiled,
    double? revenue,
    double? costOfGoodsSold,
    double? grossProfit,
    int? transactionCount,
    Value<int?> openingStock = const Value.absent(),
    Value<int?> closingStock = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isSynced,
    Value<String?> cloudId = const Value.absent(),
  }) => DailySalesSummaryData(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    itemId: itemId ?? this.itemId,
    summaryDate: summaryDate ?? this.summaryDate,
    quantitySold: quantitySold ?? this.quantitySold,
    quantitySpoiled: quantitySpoiled ?? this.quantitySpoiled,
    revenue: revenue ?? this.revenue,
    costOfGoodsSold: costOfGoodsSold ?? this.costOfGoodsSold,
    grossProfit: grossProfit ?? this.grossProfit,
    transactionCount: transactionCount ?? this.transactionCount,
    openingStock: openingStock.present ? openingStock.value : this.openingStock,
    closingStock: closingStock.present ? closingStock.value : this.closingStock,
    createdAt: createdAt ?? this.createdAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isSynced: isSynced ?? this.isSynced,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
  );
  DailySalesSummaryData copyWithCompanion(DailySalesSummaryCompanion data) {
    return DailySalesSummaryData(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      summaryDate: data.summaryDate.present
          ? data.summaryDate.value
          : this.summaryDate,
      quantitySold: data.quantitySold.present
          ? data.quantitySold.value
          : this.quantitySold,
      quantitySpoiled: data.quantitySpoiled.present
          ? data.quantitySpoiled.value
          : this.quantitySpoiled,
      revenue: data.revenue.present ? data.revenue.value : this.revenue,
      costOfGoodsSold: data.costOfGoodsSold.present
          ? data.costOfGoodsSold.value
          : this.costOfGoodsSold,
      grossProfit: data.grossProfit.present
          ? data.grossProfit.value
          : this.grossProfit,
      transactionCount: data.transactionCount.present
          ? data.transactionCount.value
          : this.transactionCount,
      openingStock: data.openingStock.present
          ? data.openingStock.value
          : this.openingStock,
      closingStock: data.closingStock.present
          ? data.closingStock.value
          : this.closingStock,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySalesSummaryData(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('itemId: $itemId, ')
          ..write('summaryDate: $summaryDate, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('quantitySpoiled: $quantitySpoiled, ')
          ..write('revenue: $revenue, ')
          ..write('costOfGoodsSold: $costOfGoodsSold, ')
          ..write('grossProfit: $grossProfit, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('openingStock: $openingStock, ')
          ..write('closingStock: $closingStock, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    itemId,
    summaryDate,
    quantitySold,
    quantitySpoiled,
    revenue,
    costOfGoodsSold,
    grossProfit,
    transactionCount,
    openingStock,
    closingStock,
    createdAt,
    lastUpdated,
    isSynced,
    cloudId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySalesSummaryData &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.itemId == this.itemId &&
          other.summaryDate == this.summaryDate &&
          other.quantitySold == this.quantitySold &&
          other.quantitySpoiled == this.quantitySpoiled &&
          other.revenue == this.revenue &&
          other.costOfGoodsSold == this.costOfGoodsSold &&
          other.grossProfit == this.grossProfit &&
          other.transactionCount == this.transactionCount &&
          other.openingStock == this.openingStock &&
          other.closingStock == this.closingStock &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.cloudId == this.cloudId);
}

class DailySalesSummaryCompanion
    extends UpdateCompanion<DailySalesSummaryData> {
  final Value<int> id;
  final Value<int> organizationId;
  final Value<int> itemId;
  final Value<DateTime> summaryDate;
  final Value<int> quantitySold;
  final Value<int> quantitySpoiled;
  final Value<double> revenue;
  final Value<double> costOfGoodsSold;
  final Value<double> grossProfit;
  final Value<int> transactionCount;
  final Value<int?> openingStock;
  final Value<int?> closingStock;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<String?> cloudId;
  const DailySalesSummaryCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.summaryDate = const Value.absent(),
    this.quantitySold = const Value.absent(),
    this.quantitySpoiled = const Value.absent(),
    this.revenue = const Value.absent(),
    this.costOfGoodsSold = const Value.absent(),
    this.grossProfit = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.openingStock = const Value.absent(),
    this.closingStock = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  });
  DailySalesSummaryCompanion.insert({
    this.id = const Value.absent(),
    required int organizationId,
    required int itemId,
    required DateTime summaryDate,
    this.quantitySold = const Value.absent(),
    this.quantitySpoiled = const Value.absent(),
    this.revenue = const Value.absent(),
    this.costOfGoodsSold = const Value.absent(),
    this.grossProfit = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.openingStock = const Value.absent(),
    this.closingStock = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.cloudId = const Value.absent(),
  }) : organizationId = Value(organizationId),
       itemId = Value(itemId),
       summaryDate = Value(summaryDate);
  static Insertable<DailySalesSummaryData> custom({
    Expression<int>? id,
    Expression<int>? organizationId,
    Expression<int>? itemId,
    Expression<DateTime>? summaryDate,
    Expression<int>? quantitySold,
    Expression<int>? quantitySpoiled,
    Expression<double>? revenue,
    Expression<double>? costOfGoodsSold,
    Expression<double>? grossProfit,
    Expression<int>? transactionCount,
    Expression<int>? openingStock,
    Expression<int>? closingStock,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<String>? cloudId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (itemId != null) 'item_id': itemId,
      if (summaryDate != null) 'summary_date': summaryDate,
      if (quantitySold != null) 'quantity_sold': quantitySold,
      if (quantitySpoiled != null) 'quantity_spoiled': quantitySpoiled,
      if (revenue != null) 'revenue': revenue,
      if (costOfGoodsSold != null) 'cost_of_goods_sold': costOfGoodsSold,
      if (grossProfit != null) 'gross_profit': grossProfit,
      if (transactionCount != null) 'transaction_count': transactionCount,
      if (openingStock != null) 'opening_stock': openingStock,
      if (closingStock != null) 'closing_stock': closingStock,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (cloudId != null) 'cloud_id': cloudId,
    });
  }

  DailySalesSummaryCompanion copyWith({
    Value<int>? id,
    Value<int>? organizationId,
    Value<int>? itemId,
    Value<DateTime>? summaryDate,
    Value<int>? quantitySold,
    Value<int>? quantitySpoiled,
    Value<double>? revenue,
    Value<double>? costOfGoodsSold,
    Value<double>? grossProfit,
    Value<int>? transactionCount,
    Value<int?>? openingStock,
    Value<int?>? closingStock,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastUpdated,
    Value<bool>? isSynced,
    Value<String?>? cloudId,
  }) {
    return DailySalesSummaryCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      itemId: itemId ?? this.itemId,
      summaryDate: summaryDate ?? this.summaryDate,
      quantitySold: quantitySold ?? this.quantitySold,
      quantitySpoiled: quantitySpoiled ?? this.quantitySpoiled,
      revenue: revenue ?? this.revenue,
      costOfGoodsSold: costOfGoodsSold ?? this.costOfGoodsSold,
      grossProfit: grossProfit ?? this.grossProfit,
      transactionCount: transactionCount ?? this.transactionCount,
      openingStock: openingStock ?? this.openingStock,
      closingStock: closingStock ?? this.closingStock,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (summaryDate.present) {
      map['summary_date'] = Variable<DateTime>(summaryDate.value);
    }
    if (quantitySold.present) {
      map['quantity_sold'] = Variable<int>(quantitySold.value);
    }
    if (quantitySpoiled.present) {
      map['quantity_spoiled'] = Variable<int>(quantitySpoiled.value);
    }
    if (revenue.present) {
      map['revenue'] = Variable<double>(revenue.value);
    }
    if (costOfGoodsSold.present) {
      map['cost_of_goods_sold'] = Variable<double>(costOfGoodsSold.value);
    }
    if (grossProfit.present) {
      map['gross_profit'] = Variable<double>(grossProfit.value);
    }
    if (transactionCount.present) {
      map['transaction_count'] = Variable<int>(transactionCount.value);
    }
    if (openingStock.present) {
      map['opening_stock'] = Variable<int>(openingStock.value);
    }
    if (closingStock.present) {
      map['closing_stock'] = Variable<int>(closingStock.value);
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
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySalesSummaryCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('itemId: $itemId, ')
          ..write('summaryDate: $summaryDate, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('quantitySpoiled: $quantitySpoiled, ')
          ..write('revenue: $revenue, ')
          ..write('costOfGoodsSold: $costOfGoodsSold, ')
          ..write('grossProfit: $grossProfit, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('openingStock: $openingStock, ')
          ..write('closingStock: $closingStock, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('cloudId: $cloudId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $BranchIngredientStockTable branchIngredientStock =
      $BranchIngredientStockTable(this);
  late final $BranchItemStockTable branchItemStock = $BranchItemStockTable(
    this,
  );
  late final $StockReplenishmentRequestsTable stockReplenishmentRequests =
      $StockReplenishmentRequestsTable(this);
  late final $StockChangeRequestsTable stockChangeRequests =
      $StockChangeRequestsTable(this);
  late final $DailySalesSummaryTable dailySalesSummary =
      $DailySalesSummaryTable(this);
  late final OrganizationsDao organizationsDao = OrganizationsDao(
    this as AppDatabase,
  );
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final RolesDao rolesDao = RolesDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final IngredientsDao ingredientsDao = IngredientsDao(
    this as AppDatabase,
  );
  late final RecipeIngredientsDao recipeIngredientsDao = RecipeIngredientsDao(
    this as AppDatabase,
  );
  late final BranchIngredientStockDao branchIngredientStockDao =
      BranchIngredientStockDao(this as AppDatabase);
  late final BranchItemStockDao branchItemStockDao = BranchItemStockDao(
    this as AppDatabase,
  );
  late final StockReplenishmentRequestsDao stockReplenishmentRequestsDao =
      StockReplenishmentRequestsDao(this as AppDatabase);
  late final StockChangeRequestsDao stockChangeRequestsDao =
      StockChangeRequestsDao(this as AppDatabase);
  late final DailySalesSummaryDao dailySalesSummaryDao = DailySalesSummaryDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    organizations,
    categories,
    roles,
    users,
    items,
    ingredients,
    recipeIngredients,
    branchIngredientStock,
    branchItemStock,
    stockReplenishmentRequests,
    stockChangeRequests,
    dailySalesSummary,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_ingredients', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ingredients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_ingredients', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$OrganizationsTableCreateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      Value<int?> parentCommissaryId,
      Value<String?> contactPerson,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isActive,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$OrganizationsTableUpdateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<int?> parentCommissaryId,
      Value<String?> contactPerson,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isActive,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$OrganizationsTableReferences
    extends BaseReferences<_$AppDatabase, $OrganizationsTable, Organization> {
  $$OrganizationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _parentCommissaryIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.organizations.parentCommissaryId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager? get parentCommissaryId {
    final $_column = $_itemColumn<int>('parent_commissary_id');
    if ($_column == null) return null;
    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentCommissaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$UsersTable, List<User>> _usersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.users,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.users.organizationId,
    ),
  );

  $$UsersTableProcessedTableManager get usersRefs {
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_usersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemsTable, List<Item>> _itemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.items,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.items.organizationId,
    ),
  );

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IngredientsTable, List<Ingredient>>
  _ingredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ingredients,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.ingredients.commissaryId,
    ),
  );

  $$IngredientsTableProcessedTableManager get ingredientsRefs {
    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.commissaryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ingredientsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BranchIngredientStockTable,
    List<BranchIngredientStockData>
  >
  _branchIngredientStockRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.branchIngredientStock,
        aliasName: $_aliasNameGenerator(
          db.organizations.id,
          db.branchIngredientStock.organizationId,
        ),
      );

  $$BranchIngredientStockTableProcessedTableManager
  get branchIngredientStockRefs {
    final manager = $$BranchIngredientStockTableTableManager(
      $_db,
      $_db.branchIngredientStock,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _branchIngredientStockRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BranchItemStockTable, List<BranchItemStockData>>
  _branchItemStockRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.branchItemStock,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.branchItemStock.organizationId,
    ),
  );

  $$BranchItemStockTableProcessedTableManager get branchItemStockRefs {
    final manager = $$BranchItemStockTableTableManager(
      $_db,
      $_db.branchItemStock,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _branchItemStockRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockReplenishmentRequestsTable,
    List<StockReplenishmentRequest>
  >
  _franchiseeReplenishmentRequestsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockReplenishmentRequests,
        aliasName: $_aliasNameGenerator(
          db.organizations.id,
          db.stockReplenishmentRequests.franchiseeId,
        ),
      );

  $$StockReplenishmentRequestsTableProcessedTableManager
  get franchiseeReplenishmentRequests {
    final manager = $$StockReplenishmentRequestsTableTableManager(
      $_db,
      $_db.stockReplenishmentRequests,
    ).filter((f) => f.franchiseeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _franchiseeReplenishmentRequestsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockReplenishmentRequestsTable,
    List<StockReplenishmentRequest>
  >
  _commissaryReplenishmentRequestsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockReplenishmentRequests,
        aliasName: $_aliasNameGenerator(
          db.organizations.id,
          db.stockReplenishmentRequests.commissaryId,
        ),
      );

  $$StockReplenishmentRequestsTableProcessedTableManager
  get commissaryReplenishmentRequests {
    final manager = $$StockReplenishmentRequestsTableTableManager(
      $_db,
      $_db.stockReplenishmentRequests,
    ).filter((f) => f.commissaryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _commissaryReplenishmentRequestsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockChangeRequestsTable,
    List<StockChangeRequest>
  >
  _stockChangeRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockChangeRequests,
        aliasName: $_aliasNameGenerator(
          db.organizations.id,
          db.stockChangeRequests.franchiseeId,
        ),
      );

  $$StockChangeRequestsTableProcessedTableManager get stockChangeRequestsRefs {
    final manager = $$StockChangeRequestsTableTableManager(
      $_db,
      $_db.stockChangeRequests,
    ).filter((f) => f.franchiseeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockChangeRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DailySalesSummaryTable,
    List<DailySalesSummaryData>
  >
  _dailySalesSummaryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dailySalesSummary,
        aliasName: $_aliasNameGenerator(
          db.organizations.id,
          db.dailySalesSummary.organizationId,
        ),
      );

  $$DailySalesSummaryTableProcessedTableManager get dailySalesSummaryRefs {
    final manager = $$DailySalesSummaryTableTableManager(
      $_db,
      $_db.dailySalesSummary,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailySalesSummaryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get parentCommissaryId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCommissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> usersRefs(
    Expression<bool> Function($$UsersTableFilterComposer f) f,
  ) {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.organizationId,
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

  Expression<bool> itemsRefs(
    Expression<bool> Function($$ItemsTableFilterComposer f) f,
  ) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.organizationId,
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

  Expression<bool> ingredientsRefs(
    Expression<bool> Function($$IngredientsTableFilterComposer f) f,
  ) {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.commissaryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> branchIngredientStockRefs(
    Expression<bool> Function($$BranchIngredientStockTableFilterComposer f) f,
  ) {
    final $$BranchIngredientStockTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.branchIngredientStock,
          getReferencedColumn: (t) => t.organizationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BranchIngredientStockTableFilterComposer(
                $db: $db,
                $table: $db.branchIngredientStock,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> branchItemStockRefs(
    Expression<bool> Function($$BranchItemStockTableFilterComposer f) f,
  ) {
    final $$BranchItemStockTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.branchItemStock,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BranchItemStockTableFilterComposer(
            $db: $db,
            $table: $db.branchItemStock,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> franchiseeReplenishmentRequests(
    Expression<bool> Function($$StockReplenishmentRequestsTableFilterComposer f)
    f,
  ) {
    final $$StockReplenishmentRequestsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.franchiseeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableFilterComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> commissaryReplenishmentRequests(
    Expression<bool> Function($$StockReplenishmentRequestsTableFilterComposer f)
    f,
  ) {
    final $$StockReplenishmentRequestsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.commissaryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableFilterComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> stockChangeRequestsRefs(
    Expression<bool> Function($$StockChangeRequestsTableFilterComposer f) f,
  ) {
    final $$StockChangeRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockChangeRequests,
      getReferencedColumn: (t) => t.franchiseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockChangeRequestsTableFilterComposer(
            $db: $db,
            $table: $db.stockChangeRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailySalesSummaryRefs(
    Expression<bool> Function($$DailySalesSummaryTableFilterComposer f) f,
  ) {
    final $$DailySalesSummaryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailySalesSummary,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySalesSummaryTableFilterComposer(
            $db: $db,
            $table: $db.dailySalesSummary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get parentCommissaryId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCommissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get parentCommissaryId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCommissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> usersRefs<T extends Object>(
    Expression<T> Function($$UsersTableAnnotationComposer a) f,
  ) {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.organizationId,
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

  Expression<T> itemsRefs<T extends Object>(
    Expression<T> Function($$ItemsTableAnnotationComposer a) f,
  ) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.organizationId,
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

  Expression<T> ingredientsRefs<T extends Object>(
    Expression<T> Function($$IngredientsTableAnnotationComposer a) f,
  ) {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.commissaryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> branchIngredientStockRefs<T extends Object>(
    Expression<T> Function($$BranchIngredientStockTableAnnotationComposer a) f,
  ) {
    final $$BranchIngredientStockTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.branchIngredientStock,
          getReferencedColumn: (t) => t.organizationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BranchIngredientStockTableAnnotationComposer(
                $db: $db,
                $table: $db.branchIngredientStock,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> branchItemStockRefs<T extends Object>(
    Expression<T> Function($$BranchItemStockTableAnnotationComposer a) f,
  ) {
    final $$BranchItemStockTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.branchItemStock,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BranchItemStockTableAnnotationComposer(
            $db: $db,
            $table: $db.branchItemStock,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> franchiseeReplenishmentRequests<T extends Object>(
    Expression<T> Function(
      $$StockReplenishmentRequestsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StockReplenishmentRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.franchiseeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> commissaryReplenishmentRequests<T extends Object>(
    Expression<T> Function(
      $$StockReplenishmentRequestsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StockReplenishmentRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.commissaryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> stockChangeRequestsRefs<T extends Object>(
    Expression<T> Function($$StockChangeRequestsTableAnnotationComposer a) f,
  ) {
    final $$StockChangeRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockChangeRequests,
          getReferencedColumn: (t) => t.franchiseeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockChangeRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockChangeRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dailySalesSummaryRefs<T extends Object>(
    Expression<T> Function($$DailySalesSummaryTableAnnotationComposer a) f,
  ) {
    final $$DailySalesSummaryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dailySalesSummary,
          getReferencedColumn: (t) => t.organizationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DailySalesSummaryTableAnnotationComposer(
                $db: $db,
                $table: $db.dailySalesSummary,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OrganizationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrganizationsTable,
          Organization,
          $$OrganizationsTableFilterComposer,
          $$OrganizationsTableOrderingComposer,
          $$OrganizationsTableAnnotationComposer,
          $$OrganizationsTableCreateCompanionBuilder,
          $$OrganizationsTableUpdateCompanionBuilder,
          (Organization, $$OrganizationsTableReferences),
          Organization,
          PrefetchHooks Function({
            bool parentCommissaryId,
            bool usersRefs,
            bool itemsRefs,
            bool ingredientsRefs,
            bool branchIngredientStockRefs,
            bool branchItemStockRefs,
            bool franchiseeReplenishmentRequests,
            bool commissaryReplenishmentRequests,
            bool stockChangeRequestsRefs,
            bool dailySalesSummaryRefs,
          })
        > {
  $$OrganizationsTableTableManager(_$AppDatabase db, $OrganizationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> parentCommissaryId = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => OrganizationsCompanion(
                id: id,
                name: name,
                type: type,
                parentCommissaryId: parentCommissaryId,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isActive: isActive,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<int?> parentCommissaryId = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => OrganizationsCompanion.insert(
                id: id,
                name: name,
                type: type,
                parentCommissaryId: parentCommissaryId,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isActive: isActive,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrganizationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentCommissaryId = false,
                usersRefs = false,
                itemsRefs = false,
                ingredientsRefs = false,
                branchIngredientStockRefs = false,
                branchItemStockRefs = false,
                franchiseeReplenishmentRequests = false,
                commissaryReplenishmentRequests = false,
                stockChangeRequestsRefs = false,
                dailySalesSummaryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (usersRefs) db.users,
                    if (itemsRefs) db.items,
                    if (ingredientsRefs) db.ingredients,
                    if (branchIngredientStockRefs) db.branchIngredientStock,
                    if (branchItemStockRefs) db.branchItemStock,
                    if (franchiseeReplenishmentRequests)
                      db.stockReplenishmentRequests,
                    if (commissaryReplenishmentRequests)
                      db.stockReplenishmentRequests,
                    if (stockChangeRequestsRefs) db.stockChangeRequests,
                    if (dailySalesSummaryRefs) db.dailySalesSummary,
                  ],
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
                        if (parentCommissaryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentCommissaryId,
                                    referencedTable:
                                        $$OrganizationsTableReferences
                                            ._parentCommissaryIdTable(db),
                                    referencedColumn:
                                        $$OrganizationsTableReferences
                                            ._parentCommissaryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (usersRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          User
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._usersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).usersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (itemsRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          Item
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._itemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientsRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          Ingredient
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._ingredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.commissaryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (branchIngredientStockRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          BranchIngredientStockData
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._branchIngredientStockRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).branchIngredientStockRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (branchItemStockRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          BranchItemStockData
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._branchItemStockRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).branchItemStockRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (franchiseeReplenishmentRequests)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          StockReplenishmentRequest
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._franchiseeReplenishmentRequestsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).franchiseeReplenishmentRequests,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.franchiseeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commissaryReplenishmentRequests)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          StockReplenishmentRequest
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._commissaryReplenishmentRequestsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).commissaryReplenishmentRequests,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.commissaryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockChangeRequestsRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          StockChangeRequest
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._stockChangeRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockChangeRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.franchiseeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailySalesSummaryRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          DailySalesSummaryData
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._dailySalesSummaryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailySalesSummaryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrganizationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrganizationsTable,
      Organization,
      $$OrganizationsTableFilterComposer,
      $$OrganizationsTableOrderingComposer,
      $$OrganizationsTableAnnotationComposer,
      $$OrganizationsTableCreateCompanionBuilder,
      $$OrganizationsTableUpdateCompanionBuilder,
      (Organization, $$OrganizationsTableReferences),
      Organization,
      PrefetchHooks Function({
        bool parentCommissaryId,
        bool usersRefs,
        bool itemsRefs,
        bool ingredientsRefs,
        bool branchIngredientStockRefs,
        bool branchItemStockRefs,
        bool franchiseeReplenishmentRequests,
        bool commissaryReplenishmentRequests,
        bool stockChangeRequestsRefs,
        bool dailySalesSummaryRefs,
      })
    >;
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

  static MultiTypedResultKey<$IngredientsTable, List<Ingredient>>
  _ingredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ingredients,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.ingredients.categoryId,
    ),
  );

  $$IngredientsTableProcessedTableManager get ingredientsRefs {
    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ingredientsRefsTable($_db));
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

  Expression<bool> ingredientsRefs(
    Expression<bool> Function($$IngredientsTableFilterComposer f) f,
  ) {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
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

  Expression<T> ingredientsRefs<T extends Object>(
    Expression<T> Function($$IngredientsTableAnnotationComposer a) f,
  ) {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
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
          PrefetchHooks Function({bool itemsRefs, bool ingredientsRefs})
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
          prefetchHooksCallback:
              ({itemsRefs = false, ingredientsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (itemsRefs) db.items,
                    if (ingredientsRefs) db.ingredients,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (itemsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Item
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._itemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).itemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Ingredient
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._ingredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
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
      PrefetchHooks Function({bool itemsRefs, bool ingredientsRefs})
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
      Value<bool> isSynced,
      Value<String?> cloudId,
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
      Value<bool> isSynced,
      Value<String?> cloudId,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
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

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

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
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
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
                isSynced: isSynced,
                cloudId: cloudId,
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
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
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
                isSynced: isSynced,
                cloudId: cloudId,
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
      required String username,
      required String email,
      required String password,
      Value<String?> phone,
      required int organizationId,
      required int roleId,
      Value<String?> fullName,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> email,
      Value<String> password,
      Value<String?> phone,
      Value<int> organizationId,
      Value<int> roleId,
      Value<String?> fullName,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(db.users.organizationId, db.organizations.id),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

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

  static MultiTypedResultKey<
    $StockReplenishmentRequestsTable,
    List<StockReplenishmentRequest>
  >
  _replenishmentRequesterTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockReplenishmentRequests,
        aliasName: $_aliasNameGenerator(
          db.users.id,
          db.stockReplenishmentRequests.requestedBy,
        ),
      );

  $$StockReplenishmentRequestsTableProcessedTableManager
  get replenishmentRequester {
    final manager = $$StockReplenishmentRequestsTableTableManager(
      $_db,
      $_db.stockReplenishmentRequests,
    ).filter((f) => f.requestedBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _replenishmentRequesterTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockReplenishmentRequestsTable,
    List<StockReplenishmentRequest>
  >
  _replenishmentReviewerTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockReplenishmentRequests,
        aliasName: $_aliasNameGenerator(
          db.users.id,
          db.stockReplenishmentRequests.reviewedBy,
        ),
      );

  $$StockReplenishmentRequestsTableProcessedTableManager
  get replenishmentReviewer {
    final manager = $$StockReplenishmentRequestsTableTableManager(
      $_db,
      $_db.stockReplenishmentRequests,
    ).filter((f) => f.reviewedBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _replenishmentReviewerTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockChangeRequestsTable,
    List<StockChangeRequest>
  >
  _changeRequesterTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockChangeRequests,
    aliasName: $_aliasNameGenerator(
      db.users.id,
      db.stockChangeRequests.requestedBy,
    ),
  );

  $$StockChangeRequestsTableProcessedTableManager get changeRequester {
    final manager = $$StockChangeRequestsTableTableManager(
      $_db,
      $_db.stockChangeRequests,
    ).filter((f) => f.requestedBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_changeRequesterTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockChangeRequestsTable,
    List<StockChangeRequest>
  >
  _changeReviewerTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockChangeRequests,
    aliasName: $_aliasNameGenerator(
      db.users.id,
      db.stockChangeRequests.reviewedBy,
    ),
  );

  $$StockChangeRequestsTableProcessedTableManager get changeReviewer {
    final manager = $$StockChangeRequestsTableTableManager(
      $_db,
      $_db.stockChangeRequests,
    ).filter((f) => f.reviewedBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_changeReviewerTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  Expression<bool> replenishmentRequester(
    Expression<bool> Function($$StockReplenishmentRequestsTableFilterComposer f)
    f,
  ) {
    final $$StockReplenishmentRequestsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.requestedBy,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableFilterComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> replenishmentReviewer(
    Expression<bool> Function($$StockReplenishmentRequestsTableFilterComposer f)
    f,
  ) {
    final $$StockReplenishmentRequestsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.reviewedBy,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableFilterComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> changeRequester(
    Expression<bool> Function($$StockChangeRequestsTableFilterComposer f) f,
  ) {
    final $$StockChangeRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockChangeRequests,
      getReferencedColumn: (t) => t.requestedBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockChangeRequestsTableFilterComposer(
            $db: $db,
            $table: $db.stockChangeRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> changeReviewer(
    Expression<bool> Function($$StockChangeRequestsTableFilterComposer f) f,
  ) {
    final $$StockChangeRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockChangeRequests,
      getReferencedColumn: (t) => t.reviewedBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockChangeRequestsTableFilterComposer(
            $db: $db,
            $table: $db.stockChangeRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  Expression<T> replenishmentRequester<T extends Object>(
    Expression<T> Function(
      $$StockReplenishmentRequestsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StockReplenishmentRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.requestedBy,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> replenishmentReviewer<T extends Object>(
    Expression<T> Function(
      $$StockReplenishmentRequestsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StockReplenishmentRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.reviewedBy,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> changeRequester<T extends Object>(
    Expression<T> Function($$StockChangeRequestsTableAnnotationComposer a) f,
  ) {
    final $$StockChangeRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockChangeRequests,
          getReferencedColumn: (t) => t.requestedBy,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockChangeRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockChangeRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> changeReviewer<T extends Object>(
    Expression<T> Function($$StockChangeRequestsTableAnnotationComposer a) f,
  ) {
    final $$StockChangeRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockChangeRequests,
          getReferencedColumn: (t) => t.reviewedBy,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockChangeRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockChangeRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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
          PrefetchHooks Function({
            bool organizationId,
            bool roleId,
            bool replenishmentRequester,
            bool replenishmentReviewer,
            bool changeRequester,
            bool changeReviewer,
          })
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
                Value<String> username = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                email: email,
                password: password,
                phone: phone,
                organizationId: organizationId,
                roleId: roleId,
                fullName: fullName,
                isActive: isActive,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String email,
                required String password,
                Value<String?> phone = const Value.absent(),
                required int organizationId,
                required int roleId,
                Value<String?> fullName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                email: email,
                password: password,
                phone: phone,
                organizationId: organizationId,
                roleId: roleId,
                fullName: fullName,
                isActive: isActive,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                organizationId = false,
                roleId = false,
                replenishmentRequester = false,
                replenishmentReviewer = false,
                changeRequester = false,
                changeReviewer = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (replenishmentRequester) db.stockReplenishmentRequests,
                    if (replenishmentReviewer) db.stockReplenishmentRequests,
                    if (changeRequester) db.stockChangeRequests,
                    if (changeReviewer) db.stockChangeRequests,
                  ],
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
                        if (organizationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.organizationId,
                                    referencedTable: $$UsersTableReferences
                                        ._organizationIdTable(db),
                                    referencedColumn: $$UsersTableReferences
                                        ._organizationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
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
                    return [
                      if (replenishmentRequester)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StockReplenishmentRequest
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._replenishmentRequesterTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).replenishmentRequester,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.requestedBy == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (replenishmentReviewer)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StockReplenishmentRequest
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._replenishmentReviewerTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).replenishmentReviewer,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reviewedBy == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (changeRequester)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StockChangeRequest
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._changeRequesterTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).changeRequester,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.requestedBy == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (changeReviewer)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StockChangeRequest
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._changeReviewerTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).changeReviewer,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reviewedBy == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
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
      PrefetchHooks Function({
        bool organizationId,
        bool roleId,
        bool replenishmentRequester,
        bool replenishmentReviewer,
        bool changeRequester,
        bool changeReviewer,
      })
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> categoryId,
      required int organizationId,
      Value<int?> masterItemId,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<double?> price,
      Value<double?> costPrice,
      Value<String> unit,
      Value<int?> minimumStock,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> categoryId,
      Value<int> organizationId,
      Value<int?> masterItemId,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<double?> price,
      Value<double?> costPrice,
      Value<String> unit,
      Value<int?> minimumStock,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
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

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(db.items.organizationId, db.organizations.id),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _masterItemIdTable(_$AppDatabase db) => db.items
      .createAlias($_aliasNameGenerator(db.items.masterItemId, db.items.id));

  $$ItemsTableProcessedTableManager? get masterItemId {
    final $_column = $_itemColumn<int>('master_item_id');
    if ($_column == null) return null;
    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_masterItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RecipeIngredientsTable, List<RecipeIngredient>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: $_aliasNameGenerator(
          db.items.id,
          db.recipeIngredients.itemId,
        ),
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager = $$RecipeIngredientsTableTableManager(
      $_db,
      $_db.recipeIngredients,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BranchItemStockTable, List<BranchItemStockData>>
  _branchItemStockRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.branchItemStock,
    aliasName: $_aliasNameGenerator(db.items.id, db.branchItemStock.itemId),
  );

  $$BranchItemStockTableProcessedTableManager get branchItemStockRefs {
    final manager = $$BranchItemStockTableTableManager(
      $_db,
      $_db.branchItemStock,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _branchItemStockRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockReplenishmentRequestsTable,
    List<StockReplenishmentRequest>
  >
  _stockReplenishmentRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockReplenishmentRequests,
        aliasName: $_aliasNameGenerator(
          db.items.id,
          db.stockReplenishmentRequests.itemId,
        ),
      );

  $$StockReplenishmentRequestsTableProcessedTableManager
  get stockReplenishmentRequestsRefs {
    final manager = $$StockReplenishmentRequestsTableTableManager(
      $_db,
      $_db.stockReplenishmentRequests,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockReplenishmentRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StockChangeRequestsTable,
    List<StockChangeRequest>
  >
  _stockChangeRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockChangeRequests,
        aliasName: $_aliasNameGenerator(
          db.items.id,
          db.stockChangeRequests.itemId,
        ),
      );

  $$StockChangeRequestsTableProcessedTableManager get stockChangeRequestsRefs {
    final manager = $$StockChangeRequestsTableTableManager(
      $_db,
      $_db.stockChangeRequests,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockChangeRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DailySalesSummaryTable,
    List<DailySalesSummaryData>
  >
  _dailySalesSummaryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dailySalesSummary,
        aliasName: $_aliasNameGenerator(
          db.items.id,
          db.dailySalesSummary.itemId,
        ),
      );

  $$DailySalesSummaryTableProcessedTableManager get dailySalesSummaryRefs {
    final manager = $$DailySalesSummaryTableTableManager(
      $_db,
      $_db.dailySalesSummary,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailySalesSummaryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
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

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get masterItemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.masterItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> branchItemStockRefs(
    Expression<bool> Function($$BranchItemStockTableFilterComposer f) f,
  ) {
    final $$BranchItemStockTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.branchItemStock,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BranchItemStockTableFilterComposer(
            $db: $db,
            $table: $db.branchItemStock,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockReplenishmentRequestsRefs(
    Expression<bool> Function($$StockReplenishmentRequestsTableFilterComposer f)
    f,
  ) {
    final $$StockReplenishmentRequestsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableFilterComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> stockChangeRequestsRefs(
    Expression<bool> Function($$StockChangeRequestsTableFilterComposer f) f,
  ) {
    final $$StockChangeRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockChangeRequests,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockChangeRequestsTableFilterComposer(
            $db: $db,
            $table: $db.stockChangeRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailySalesSummaryRefs(
    Expression<bool> Function($$DailySalesSummaryTableFilterComposer f) f,
  ) {
    final $$DailySalesSummaryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailySalesSummary,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySalesSummaryTableFilterComposer(
            $db: $db,
            $table: $db.dailySalesSummary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
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

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get masterItemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.masterItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
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

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => column,
  );

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

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

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

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get masterItemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.masterItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> branchItemStockRefs<T extends Object>(
    Expression<T> Function($$BranchItemStockTableAnnotationComposer a) f,
  ) {
    final $$BranchItemStockTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.branchItemStock,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BranchItemStockTableAnnotationComposer(
            $db: $db,
            $table: $db.branchItemStock,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockReplenishmentRequestsRefs<T extends Object>(
    Expression<T> Function(
      $$StockReplenishmentRequestsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StockReplenishmentRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockReplenishmentRequests,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockReplenishmentRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> stockChangeRequestsRefs<T extends Object>(
    Expression<T> Function($$StockChangeRequestsTableAnnotationComposer a) f,
  ) {
    final $$StockChangeRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockChangeRequests,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockChangeRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockChangeRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dailySalesSummaryRefs<T extends Object>(
    Expression<T> Function($$DailySalesSummaryTableAnnotationComposer a) f,
  ) {
    final $$DailySalesSummaryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dailySalesSummary,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DailySalesSummaryTableAnnotationComposer(
                $db: $db,
                $table: $db.dailySalesSummary,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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
          PrefetchHooks Function({
            bool categoryId,
            bool organizationId,
            bool masterItemId,
            bool recipeIngredientsRefs,
            bool branchItemStockRefs,
            bool stockReplenishmentRequestsRefs,
            bool stockChangeRequestsRefs,
            bool dailySalesSummaryRefs,
          })
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
                Value<int> organizationId = const Value.absent(),
                Value<int?> masterItemId = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<double?> costPrice = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> minimumStock = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                categoryId: categoryId,
                organizationId: organizationId,
                masterItemId: masterItemId,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                price: price,
                costPrice: costPrice,
                unit: unit,
                minimumStock: minimumStock,
                description: description,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> categoryId = const Value.absent(),
                required int organizationId,
                Value<int?> masterItemId = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<double?> costPrice = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> minimumStock = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                categoryId: categoryId,
                organizationId: organizationId,
                masterItemId: masterItemId,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                price: price,
                costPrice: costPrice,
                unit: unit,
                minimumStock: minimumStock,
                description: description,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ItemsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                organizationId = false,
                masterItemId = false,
                recipeIngredientsRefs = false,
                branchItemStockRefs = false,
                stockReplenishmentRequestsRefs = false,
                stockChangeRequestsRefs = false,
                dailySalesSummaryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeIngredientsRefs) db.recipeIngredients,
                    if (branchItemStockRefs) db.branchItemStock,
                    if (stockReplenishmentRequestsRefs)
                      db.stockReplenishmentRequests,
                    if (stockChangeRequestsRefs) db.stockChangeRequests,
                    if (dailySalesSummaryRefs) db.dailySalesSummary,
                  ],
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
                        if (organizationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.organizationId,
                                    referencedTable: $$ItemsTableReferences
                                        ._organizationIdTable(db),
                                    referencedColumn: $$ItemsTableReferences
                                        ._organizationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (masterItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.masterItemId,
                                    referencedTable: $$ItemsTableReferences
                                        ._masterItemIdTable(db),
                                    referencedColumn: $$ItemsTableReferences
                                        ._masterItemIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          Item,
                          $ItemsTable,
                          RecipeIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (branchItemStockRefs)
                        await $_getPrefetchedData<
                          Item,
                          $ItemsTable,
                          BranchItemStockData
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._branchItemStockRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).branchItemStockRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockReplenishmentRequestsRefs)
                        await $_getPrefetchedData<
                          Item,
                          $ItemsTable,
                          StockReplenishmentRequest
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._stockReplenishmentRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockReplenishmentRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockChangeRequestsRefs)
                        await $_getPrefetchedData<
                          Item,
                          $ItemsTable,
                          StockChangeRequest
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._stockChangeRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockChangeRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailySalesSummaryRefs)
                        await $_getPrefetchedData<
                          Item,
                          $ItemsTable,
                          DailySalesSummaryData
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._dailySalesSummaryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailySalesSummaryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
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
      PrefetchHooks Function({
        bool categoryId,
        bool organizationId,
        bool masterItemId,
        bool recipeIngredientsRefs,
        bool branchItemStockRefs,
        bool stockReplenishmentRequestsRefs,
        bool stockChangeRequestsRefs,
        bool dailySalesSummaryRefs,
      })
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> categoryId,
      required int commissaryId,
      Value<int> stock,
      Value<int> spoilage,
      Value<String> unit,
      Value<int?> minimumStock,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> categoryId,
      Value<int> commissaryId,
      Value<int> stock,
      Value<int> spoilage,
      Value<String> unit,
      Value<int?> minimumStock,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$IngredientsTableReferences
    extends BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient> {
  $$IngredientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.ingredients.categoryId, db.categories.id),
      );

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

  static $OrganizationsTable _commissaryIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(db.ingredients.commissaryId, db.organizations.id),
      );

  $$OrganizationsTableProcessedTableManager get commissaryId {
    final $_column = $_itemColumn<int>('commissary_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commissaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RecipeIngredientsTable, List<RecipeIngredient>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: $_aliasNameGenerator(
          db.ingredients.id,
          db.recipeIngredients.ingredientId,
        ),
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager = $$RecipeIngredientsTableTableManager(
      $_db,
      $_db.recipeIngredients,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BranchIngredientStockTable,
    List<BranchIngredientStockData>
  >
  _branchIngredientStockRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.branchIngredientStock,
        aliasName: $_aliasNameGenerator(
          db.ingredients.id,
          db.branchIngredientStock.ingredientId,
        ),
      );

  $$BranchIngredientStockTableProcessedTableManager
  get branchIngredientStockRefs {
    final manager = $$BranchIngredientStockTableTableManager(
      $_db,
      $_db.branchIngredientStock,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _branchIngredientStockRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
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

  ColumnFilters<int> get spoilage => $composableBuilder(
    column: $table.spoilage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
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

  $$OrganizationsTableFilterComposer get commissaryId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> branchIngredientStockRefs(
    Expression<bool> Function($$BranchIngredientStockTableFilterComposer f) f,
  ) {
    final $$BranchIngredientStockTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.branchIngredientStock,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BranchIngredientStockTableFilterComposer(
                $db: $db,
                $table: $db.branchIngredientStock,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
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

  ColumnOrderings<int> get spoilage => $composableBuilder(
    column: $table.spoilage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
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

  $$OrganizationsTableOrderingComposer get commissaryId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
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

  GeneratedColumn<int> get spoilage =>
      $composableBuilder(column: $table.spoilage, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => column,
  );

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

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

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

  $$OrganizationsTableAnnotationComposer get commissaryId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> branchIngredientStockRefs<T extends Object>(
    Expression<T> Function($$BranchIngredientStockTableAnnotationComposer a) f,
  ) {
    final $$BranchIngredientStockTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.branchIngredientStock,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BranchIngredientStockTableAnnotationComposer(
                $db: $db,
                $table: $db.branchIngredientStock,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (Ingredient, $$IngredientsTableReferences),
          Ingredient,
          PrefetchHooks Function({
            bool categoryId,
            bool commissaryId,
            bool recipeIngredientsRefs,
            bool branchIngredientStockRefs,
          })
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> commissaryId = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> minimumStock = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                name: name,
                categoryId: categoryId,
                commissaryId: commissaryId,
                stock: stock,
                spoilage: spoilage,
                unit: unit,
                minimumStock: minimumStock,
                description: description,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> categoryId = const Value.absent(),
                required int commissaryId,
                Value<int> stock = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> minimumStock = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                name: name,
                categoryId: categoryId,
                commissaryId: commissaryId,
                stock: stock,
                spoilage: spoilage,
                unit: unit,
                minimumStock: minimumStock,
                description: description,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                commissaryId = false,
                recipeIngredientsRefs = false,
                branchIngredientStockRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeIngredientsRefs) db.recipeIngredients,
                    if (branchIngredientStockRefs) db.branchIngredientStock,
                  ],
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
                                    referencedTable:
                                        $$IngredientsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$IngredientsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (commissaryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.commissaryId,
                                    referencedTable:
                                        $$IngredientsTableReferences
                                            ._commissaryIdTable(db),
                                    referencedColumn:
                                        $$IngredientsTableReferences
                                            ._commissaryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          RecipeIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (branchIngredientStockRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          BranchIngredientStockData
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._branchIngredientStockRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).branchIngredientStockRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (Ingredient, $$IngredientsTableReferences),
      Ingredient,
      PrefetchHooks Function({
        bool categoryId,
        bool commissaryId,
        bool recipeIngredientsRefs,
        bool branchIngredientStockRefs,
      })
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required int itemId,
      required int ingredientId,
      required double quantityNeeded,
      required String unit,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<int> ingredientId,
      Value<double> quantityNeeded,
      Value<String> unit,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$RecipeIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        > {
  $$RecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.recipeIngredients.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.recipeIngredients.ingredientId,
          db.ingredients.id,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
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

  ColumnFilters<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
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

  ColumnOrderings<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (RecipeIngredient, $$RecipeIngredientsTableReferences),
          RecipeIngredient,
          PrefetchHooks Function({bool itemId, bool ingredientId})
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> ingredientId = const Value.absent(),
                Value<double> quantityNeeded = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                itemId: itemId,
                ingredientId: ingredientId,
                quantityNeeded: quantityNeeded,
                unit: unit,
                notes: notes,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                required int ingredientId,
                required double quantityNeeded,
                required String unit,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                itemId: itemId,
                ingredientId: ingredientId,
                quantityNeeded: quantityNeeded,
                unit: unit,
                notes: notes,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, ingredientId = false}) {
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
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$RecipeIngredientsTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$RecipeIngredientsTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (ingredientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientId,
                                referencedTable:
                                    $$RecipeIngredientsTableReferences
                                        ._ingredientIdTable(db),
                                referencedColumn:
                                    $$RecipeIngredientsTableReferences
                                        ._ingredientIdTable(db)
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

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (RecipeIngredient, $$RecipeIngredientsTableReferences),
      RecipeIngredient,
      PrefetchHooks Function({bool itemId, bool ingredientId})
    >;
typedef $$BranchIngredientStockTableCreateCompanionBuilder =
    BranchIngredientStockCompanion Function({
      Value<int> id,
      required int organizationId,
      required int ingredientId,
      Value<double> quantity,
      Value<double?> minimumStock,
      Value<DateTime?> lastReceivedAt,
      Value<double?> lastReceivedQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$BranchIngredientStockTableUpdateCompanionBuilder =
    BranchIngredientStockCompanion Function({
      Value<int> id,
      Value<int> organizationId,
      Value<int> ingredientId,
      Value<double> quantity,
      Value<double?> minimumStock,
      Value<DateTime?> lastReceivedAt,
      Value<double?> lastReceivedQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$BranchIngredientStockTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BranchIngredientStockTable,
          BranchIngredientStockData
        > {
  $$BranchIngredientStockTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.branchIngredientStock.organizationId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.branchIngredientStock.ingredientId,
          db.ingredients.id,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BranchIngredientStockTableFilterComposer
    extends Composer<_$AppDatabase, $BranchIngredientStockTable> {
  $$BranchIngredientStockTableFilterComposer({
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

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReceivedAt => $composableBuilder(
    column: $table.lastReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastReceivedQuantity => $composableBuilder(
    column: $table.lastReceivedQuantity,
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchIngredientStockTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchIngredientStockTable> {
  $$BranchIngredientStockTableOrderingComposer({
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

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReceivedAt => $composableBuilder(
    column: $table.lastReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastReceivedQuantity => $composableBuilder(
    column: $table.lastReceivedQuantity,
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchIngredientStockTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchIngredientStockTable> {
  $$BranchIngredientStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReceivedAt => $composableBuilder(
    column: $table.lastReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastReceivedQuantity => $composableBuilder(
    column: $table.lastReceivedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchIngredientStockTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchIngredientStockTable,
          BranchIngredientStockData,
          $$BranchIngredientStockTableFilterComposer,
          $$BranchIngredientStockTableOrderingComposer,
          $$BranchIngredientStockTableAnnotationComposer,
          $$BranchIngredientStockTableCreateCompanionBuilder,
          $$BranchIngredientStockTableUpdateCompanionBuilder,
          (BranchIngredientStockData, $$BranchIngredientStockTableReferences),
          BranchIngredientStockData,
          PrefetchHooks Function({bool organizationId, bool ingredientId})
        > {
  $$BranchIngredientStockTableTableManager(
    _$AppDatabase db,
    $BranchIngredientStockTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchIngredientStockTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BranchIngredientStockTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BranchIngredientStockTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
                Value<int> ingredientId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> minimumStock = const Value.absent(),
                Value<DateTime?> lastReceivedAt = const Value.absent(),
                Value<double?> lastReceivedQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => BranchIngredientStockCompanion(
                id: id,
                organizationId: organizationId,
                ingredientId: ingredientId,
                quantity: quantity,
                minimumStock: minimumStock,
                lastReceivedAt: lastReceivedAt,
                lastReceivedQuantity: lastReceivedQuantity,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int organizationId,
                required int ingredientId,
                Value<double> quantity = const Value.absent(),
                Value<double?> minimumStock = const Value.absent(),
                Value<DateTime?> lastReceivedAt = const Value.absent(),
                Value<double?> lastReceivedQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => BranchIngredientStockCompanion.insert(
                id: id,
                organizationId: organizationId,
                ingredientId: ingredientId,
                quantity: quantity,
                minimumStock: minimumStock,
                lastReceivedAt: lastReceivedAt,
                lastReceivedQuantity: lastReceivedQuantity,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BranchIngredientStockTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({organizationId = false, ingredientId = false}) {
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
                        if (organizationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.organizationId,
                                    referencedTable:
                                        $$BranchIngredientStockTableReferences
                                            ._organizationIdTable(db),
                                    referencedColumn:
                                        $$BranchIngredientStockTableReferences
                                            ._organizationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (ingredientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ingredientId,
                                    referencedTable:
                                        $$BranchIngredientStockTableReferences
                                            ._ingredientIdTable(db),
                                    referencedColumn:
                                        $$BranchIngredientStockTableReferences
                                            ._ingredientIdTable(db)
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

typedef $$BranchIngredientStockTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchIngredientStockTable,
      BranchIngredientStockData,
      $$BranchIngredientStockTableFilterComposer,
      $$BranchIngredientStockTableOrderingComposer,
      $$BranchIngredientStockTableAnnotationComposer,
      $$BranchIngredientStockTableCreateCompanionBuilder,
      $$BranchIngredientStockTableUpdateCompanionBuilder,
      (BranchIngredientStockData, $$BranchIngredientStockTableReferences),
      BranchIngredientStockData,
      PrefetchHooks Function({bool organizationId, bool ingredientId})
    >;
typedef $$BranchItemStockTableCreateCompanionBuilder =
    BranchItemStockCompanion Function({
      Value<int> id,
      required int organizationId,
      required int itemId,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<double?> price,
      Value<double?> costPrice,
      Value<int?> minimumStock,
      Value<DateTime?> lastReceivedAt,
      Value<int?> lastReceivedQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$BranchItemStockTableUpdateCompanionBuilder =
    BranchItemStockCompanion Function({
      Value<int> id,
      Value<int> organizationId,
      Value<int> itemId,
      Value<int> stock,
      Value<int> sold,
      Value<int> spoilage,
      Value<double?> price,
      Value<double?> costPrice,
      Value<int?> minimumStock,
      Value<DateTime?> lastReceivedAt,
      Value<int?> lastReceivedQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$BranchItemStockTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BranchItemStockTable,
          BranchItemStockData
        > {
  $$BranchItemStockTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.branchItemStock.organizationId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.branchItemStock.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BranchItemStockTableFilterComposer
    extends Composer<_$AppDatabase, $BranchItemStockTable> {
  $$BranchItemStockTableFilterComposer({
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

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReceivedAt => $composableBuilder(
    column: $table.lastReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReceivedQuantity => $composableBuilder(
    column: $table.lastReceivedQuantity,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BranchItemStockTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchItemStockTable> {
  $$BranchItemStockTableOrderingComposer({
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

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReceivedAt => $composableBuilder(
    column: $table.lastReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReceivedQuantity => $composableBuilder(
    column: $table.lastReceivedQuantity,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchItemStockTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchItemStockTable> {
  $$BranchItemStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get sold =>
      $composableBuilder(column: $table.sold, builder: (column) => column);

  GeneratedColumn<int> get spoilage =>
      $composableBuilder(column: $table.spoilage, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReceivedAt => $composableBuilder(
    column: $table.lastReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReceivedQuantity => $composableBuilder(
    column: $table.lastReceivedQuantity,
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

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BranchItemStockTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchItemStockTable,
          BranchItemStockData,
          $$BranchItemStockTableFilterComposer,
          $$BranchItemStockTableOrderingComposer,
          $$BranchItemStockTableAnnotationComposer,
          $$BranchItemStockTableCreateCompanionBuilder,
          $$BranchItemStockTableUpdateCompanionBuilder,
          (BranchItemStockData, $$BranchItemStockTableReferences),
          BranchItemStockData,
          PrefetchHooks Function({bool organizationId, bool itemId})
        > {
  $$BranchItemStockTableTableManager(
    _$AppDatabase db,
    $BranchItemStockTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchItemStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchItemStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchItemStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<double?> costPrice = const Value.absent(),
                Value<int?> minimumStock = const Value.absent(),
                Value<DateTime?> lastReceivedAt = const Value.absent(),
                Value<int?> lastReceivedQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => BranchItemStockCompanion(
                id: id,
                organizationId: organizationId,
                itemId: itemId,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                price: price,
                costPrice: costPrice,
                minimumStock: minimumStock,
                lastReceivedAt: lastReceivedAt,
                lastReceivedQuantity: lastReceivedQuantity,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int organizationId,
                required int itemId,
                Value<int> stock = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<double?> costPrice = const Value.absent(),
                Value<int?> minimumStock = const Value.absent(),
                Value<DateTime?> lastReceivedAt = const Value.absent(),
                Value<int?> lastReceivedQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => BranchItemStockCompanion.insert(
                id: id,
                organizationId: organizationId,
                itemId: itemId,
                stock: stock,
                sold: sold,
                spoilage: spoilage,
                price: price,
                costPrice: costPrice,
                minimumStock: minimumStock,
                lastReceivedAt: lastReceivedAt,
                lastReceivedQuantity: lastReceivedQuantity,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BranchItemStockTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({organizationId = false, itemId = false}) {
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
                    if (organizationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.organizationId,
                                referencedTable:
                                    $$BranchItemStockTableReferences
                                        ._organizationIdTable(db),
                                referencedColumn:
                                    $$BranchItemStockTableReferences
                                        ._organizationIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$BranchItemStockTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$BranchItemStockTableReferences
                                        ._itemIdTable(db)
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

typedef $$BranchItemStockTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchItemStockTable,
      BranchItemStockData,
      $$BranchItemStockTableFilterComposer,
      $$BranchItemStockTableOrderingComposer,
      $$BranchItemStockTableAnnotationComposer,
      $$BranchItemStockTableCreateCompanionBuilder,
      $$BranchItemStockTableUpdateCompanionBuilder,
      (BranchItemStockData, $$BranchItemStockTableReferences),
      BranchItemStockData,
      PrefetchHooks Function({bool organizationId, bool itemId})
    >;
typedef $$StockReplenishmentRequestsTableCreateCompanionBuilder =
    StockReplenishmentRequestsCompanion Function({
      Value<int> id,
      required int franchiseeId,
      required int commissaryId,
      required int itemId,
      required int quantityRequested,
      Value<String> status,
      required int requestedBy,
      Value<DateTime> requestedAt,
      Value<int?> reviewedBy,
      Value<DateTime?> reviewedAt,
      Value<DateTime?> deliveryDate,
      Value<String?> franchiseeNotes,
      Value<String?> commissaryNotes,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$StockReplenishmentRequestsTableUpdateCompanionBuilder =
    StockReplenishmentRequestsCompanion Function({
      Value<int> id,
      Value<int> franchiseeId,
      Value<int> commissaryId,
      Value<int> itemId,
      Value<int> quantityRequested,
      Value<String> status,
      Value<int> requestedBy,
      Value<DateTime> requestedAt,
      Value<int?> reviewedBy,
      Value<DateTime?> reviewedAt,
      Value<DateTime?> deliveryDate,
      Value<String?> franchiseeNotes,
      Value<String?> commissaryNotes,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$StockReplenishmentRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StockReplenishmentRequestsTable,
          StockReplenishmentRequest
        > {
  $$StockReplenishmentRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _franchiseeIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.stockReplenishmentRequests.franchiseeId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get franchiseeId {
    final $_column = $_itemColumn<int>('franchisee_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_franchiseeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrganizationsTable _commissaryIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.stockReplenishmentRequests.commissaryId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get commissaryId {
    final $_column = $_itemColumn<int>('commissary_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commissaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.stockReplenishmentRequests.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _requestedByTable(_$AppDatabase db) =>
      db.users.createAlias(
        $_aliasNameGenerator(
          db.stockReplenishmentRequests.requestedBy,
          db.users.id,
        ),
      );

  $$UsersTableProcessedTableManager get requestedBy {
    final $_column = $_itemColumn<int>('requested_by')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_requestedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _reviewedByTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.stockReplenishmentRequests.reviewedBy, db.users.id),
  );

  $$UsersTableProcessedTableManager? get reviewedBy {
    final $_column = $_itemColumn<int>('reviewed_by');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reviewedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockReplenishmentRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $StockReplenishmentRequestsTable> {
  $$StockReplenishmentRequestsTableFilterComposer({
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

  ColumnFilters<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get franchiseeNotes => $composableBuilder(
    column: $table.franchiseeNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commissaryNotes => $composableBuilder(
    column: $table.commissaryNotes,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get franchiseeId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseeId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableFilterComposer get commissaryId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableFilterComposer get requestedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableFilterComposer get reviewedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$StockReplenishmentRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockReplenishmentRequestsTable> {
  $$StockReplenishmentRequestsTableOrderingComposer({
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

  ColumnOrderings<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get franchiseeNotes => $composableBuilder(
    column: $table.franchiseeNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commissaryNotes => $composableBuilder(
    column: $table.commissaryNotes,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get franchiseeId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseeId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableOrderingComposer get commissaryId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get requestedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get reviewedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockReplenishmentRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockReplenishmentRequestsTable> {
  $$StockReplenishmentRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get franchiseeNotes => $composableBuilder(
    column: $table.franchiseeNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commissaryNotes => $composableBuilder(
    column: $table.commissaryNotes,
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

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get franchiseeId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseeId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableAnnotationComposer get commissaryId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commissaryId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableAnnotationComposer get requestedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableAnnotationComposer get reviewedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$StockReplenishmentRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockReplenishmentRequestsTable,
          StockReplenishmentRequest,
          $$StockReplenishmentRequestsTableFilterComposer,
          $$StockReplenishmentRequestsTableOrderingComposer,
          $$StockReplenishmentRequestsTableAnnotationComposer,
          $$StockReplenishmentRequestsTableCreateCompanionBuilder,
          $$StockReplenishmentRequestsTableUpdateCompanionBuilder,
          (
            StockReplenishmentRequest,
            $$StockReplenishmentRequestsTableReferences,
          ),
          StockReplenishmentRequest,
          PrefetchHooks Function({
            bool franchiseeId,
            bool commissaryId,
            bool itemId,
            bool requestedBy,
            bool reviewedBy,
          })
        > {
  $$StockReplenishmentRequestsTableTableManager(
    _$AppDatabase db,
    $StockReplenishmentRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockReplenishmentRequestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StockReplenishmentRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> franchiseeId = const Value.absent(),
                Value<int> commissaryId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> quantityRequested = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> requestedBy = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
                Value<int?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<DateTime?> deliveryDate = const Value.absent(),
                Value<String?> franchiseeNotes = const Value.absent(),
                Value<String?> commissaryNotes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => StockReplenishmentRequestsCompanion(
                id: id,
                franchiseeId: franchiseeId,
                commissaryId: commissaryId,
                itemId: itemId,
                quantityRequested: quantityRequested,
                status: status,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                reviewedBy: reviewedBy,
                reviewedAt: reviewedAt,
                deliveryDate: deliveryDate,
                franchiseeNotes: franchiseeNotes,
                commissaryNotes: commissaryNotes,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int franchiseeId,
                required int commissaryId,
                required int itemId,
                required int quantityRequested,
                Value<String> status = const Value.absent(),
                required int requestedBy,
                Value<DateTime> requestedAt = const Value.absent(),
                Value<int?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<DateTime?> deliveryDate = const Value.absent(),
                Value<String?> franchiseeNotes = const Value.absent(),
                Value<String?> commissaryNotes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => StockReplenishmentRequestsCompanion.insert(
                id: id,
                franchiseeId: franchiseeId,
                commissaryId: commissaryId,
                itemId: itemId,
                quantityRequested: quantityRequested,
                status: status,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                reviewedBy: reviewedBy,
                reviewedAt: reviewedAt,
                deliveryDate: deliveryDate,
                franchiseeNotes: franchiseeNotes,
                commissaryNotes: commissaryNotes,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockReplenishmentRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                franchiseeId = false,
                commissaryId = false,
                itemId = false,
                requestedBy = false,
                reviewedBy = false,
              }) {
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
                        if (franchiseeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.franchiseeId,
                                    referencedTable:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._franchiseeIdTable(db),
                                    referencedColumn:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._franchiseeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (commissaryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.commissaryId,
                                    referencedTable:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._commissaryIdTable(db),
                                    referencedColumn:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._commissaryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._itemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (requestedBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.requestedBy,
                                    referencedTable:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._requestedByTable(db),
                                    referencedColumn:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._requestedByTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (reviewedBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reviewedBy,
                                    referencedTable:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._reviewedByTable(db),
                                    referencedColumn:
                                        $$StockReplenishmentRequestsTableReferences
                                            ._reviewedByTable(db)
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

typedef $$StockReplenishmentRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockReplenishmentRequestsTable,
      StockReplenishmentRequest,
      $$StockReplenishmentRequestsTableFilterComposer,
      $$StockReplenishmentRequestsTableOrderingComposer,
      $$StockReplenishmentRequestsTableAnnotationComposer,
      $$StockReplenishmentRequestsTableCreateCompanionBuilder,
      $$StockReplenishmentRequestsTableUpdateCompanionBuilder,
      (StockReplenishmentRequest, $$StockReplenishmentRequestsTableReferences),
      StockReplenishmentRequest,
      PrefetchHooks Function({
        bool franchiseeId,
        bool commissaryId,
        bool itemId,
        bool requestedBy,
        bool reviewedBy,
      })
    >;
typedef $$StockChangeRequestsTableCreateCompanionBuilder =
    StockChangeRequestsCompanion Function({
      Value<int> id,
      required int franchiseeId,
      required int itemId,
      required String changeType,
      required int quantity,
      Value<String> status,
      required int requestedBy,
      Value<DateTime> requestedAt,
      Value<DateTime?> submittedAt,
      Value<int?> reviewedBy,
      Value<DateTime?> reviewedAt,
      Value<String?> reason,
      Value<String?> reviewNotes,
      required int originalStock,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$StockChangeRequestsTableUpdateCompanionBuilder =
    StockChangeRequestsCompanion Function({
      Value<int> id,
      Value<int> franchiseeId,
      Value<int> itemId,
      Value<String> changeType,
      Value<int> quantity,
      Value<String> status,
      Value<int> requestedBy,
      Value<DateTime> requestedAt,
      Value<DateTime?> submittedAt,
      Value<int?> reviewedBy,
      Value<DateTime?> reviewedAt,
      Value<String?> reason,
      Value<String?> reviewNotes,
      Value<int> originalStock,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$StockChangeRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StockChangeRequestsTable,
          StockChangeRequest
        > {
  $$StockChangeRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _franchiseeIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.stockChangeRequests.franchiseeId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get franchiseeId {
    final $_column = $_itemColumn<int>('franchisee_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_franchiseeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.stockChangeRequests.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _requestedByTable(_$AppDatabase db) =>
      db.users.createAlias(
        $_aliasNameGenerator(db.stockChangeRequests.requestedBy, db.users.id),
      );

  $$UsersTableProcessedTableManager get requestedBy {
    final $_column = $_itemColumn<int>('requested_by')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_requestedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _reviewedByTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.stockChangeRequests.reviewedBy, db.users.id),
  );

  $$UsersTableProcessedTableManager? get reviewedBy {
    final $_column = $_itemColumn<int>('reviewed_by');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reviewedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockChangeRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $StockChangeRequestsTable> {
  $$StockChangeRequestsTableFilterComposer({
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

  ColumnFilters<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewNotes => $composableBuilder(
    column: $table.reviewNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalStock => $composableBuilder(
    column: $table.originalStock,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get franchiseeId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseeId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableFilterComposer get requestedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableFilterComposer get reviewedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$StockChangeRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockChangeRequestsTable> {
  $$StockChangeRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewNotes => $composableBuilder(
    column: $table.reviewNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalStock => $composableBuilder(
    column: $table.originalStock,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get franchiseeId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseeId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get requestedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get reviewedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockChangeRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockChangeRequestsTable> {
  $$StockChangeRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get reviewNotes => $composableBuilder(
    column: $table.reviewNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalStock => $composableBuilder(
    column: $table.originalStock,
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

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get franchiseeId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseeId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableAnnotationComposer get requestedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$UsersTableAnnotationComposer get reviewedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$StockChangeRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockChangeRequestsTable,
          StockChangeRequest,
          $$StockChangeRequestsTableFilterComposer,
          $$StockChangeRequestsTableOrderingComposer,
          $$StockChangeRequestsTableAnnotationComposer,
          $$StockChangeRequestsTableCreateCompanionBuilder,
          $$StockChangeRequestsTableUpdateCompanionBuilder,
          (StockChangeRequest, $$StockChangeRequestsTableReferences),
          StockChangeRequest,
          PrefetchHooks Function({
            bool franchiseeId,
            bool itemId,
            bool requestedBy,
            bool reviewedBy,
          })
        > {
  $$StockChangeRequestsTableTableManager(
    _$AppDatabase db,
    $StockChangeRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockChangeRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockChangeRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StockChangeRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> franchiseeId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> changeType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> requestedBy = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> reviewNotes = const Value.absent(),
                Value<int> originalStock = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => StockChangeRequestsCompanion(
                id: id,
                franchiseeId: franchiseeId,
                itemId: itemId,
                changeType: changeType,
                quantity: quantity,
                status: status,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                submittedAt: submittedAt,
                reviewedBy: reviewedBy,
                reviewedAt: reviewedAt,
                reason: reason,
                reviewNotes: reviewNotes,
                originalStock: originalStock,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int franchiseeId,
                required int itemId,
                required String changeType,
                required int quantity,
                Value<String> status = const Value.absent(),
                required int requestedBy,
                Value<DateTime> requestedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> reviewNotes = const Value.absent(),
                required int originalStock,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => StockChangeRequestsCompanion.insert(
                id: id,
                franchiseeId: franchiseeId,
                itemId: itemId,
                changeType: changeType,
                quantity: quantity,
                status: status,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                submittedAt: submittedAt,
                reviewedBy: reviewedBy,
                reviewedAt: reviewedAt,
                reason: reason,
                reviewNotes: reviewNotes,
                originalStock: originalStock,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isDeleted: isDeleted,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockChangeRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                franchiseeId = false,
                itemId = false,
                requestedBy = false,
                reviewedBy = false,
              }) {
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
                        if (franchiseeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.franchiseeId,
                                    referencedTable:
                                        $$StockChangeRequestsTableReferences
                                            ._franchiseeIdTable(db),
                                    referencedColumn:
                                        $$StockChangeRequestsTableReferences
                                            ._franchiseeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$StockChangeRequestsTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$StockChangeRequestsTableReferences
                                            ._itemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (requestedBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.requestedBy,
                                    referencedTable:
                                        $$StockChangeRequestsTableReferences
                                            ._requestedByTable(db),
                                    referencedColumn:
                                        $$StockChangeRequestsTableReferences
                                            ._requestedByTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (reviewedBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reviewedBy,
                                    referencedTable:
                                        $$StockChangeRequestsTableReferences
                                            ._reviewedByTable(db),
                                    referencedColumn:
                                        $$StockChangeRequestsTableReferences
                                            ._reviewedByTable(db)
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

typedef $$StockChangeRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockChangeRequestsTable,
      StockChangeRequest,
      $$StockChangeRequestsTableFilterComposer,
      $$StockChangeRequestsTableOrderingComposer,
      $$StockChangeRequestsTableAnnotationComposer,
      $$StockChangeRequestsTableCreateCompanionBuilder,
      $$StockChangeRequestsTableUpdateCompanionBuilder,
      (StockChangeRequest, $$StockChangeRequestsTableReferences),
      StockChangeRequest,
      PrefetchHooks Function({
        bool franchiseeId,
        bool itemId,
        bool requestedBy,
        bool reviewedBy,
      })
    >;
typedef $$DailySalesSummaryTableCreateCompanionBuilder =
    DailySalesSummaryCompanion Function({
      Value<int> id,
      required int organizationId,
      required int itemId,
      required DateTime summaryDate,
      Value<int> quantitySold,
      Value<int> quantitySpoiled,
      Value<double> revenue,
      Value<double> costOfGoodsSold,
      Value<double> grossProfit,
      Value<int> transactionCount,
      Value<int?> openingStock,
      Value<int?> closingStock,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });
typedef $$DailySalesSummaryTableUpdateCompanionBuilder =
    DailySalesSummaryCompanion Function({
      Value<int> id,
      Value<int> organizationId,
      Value<int> itemId,
      Value<DateTime> summaryDate,
      Value<int> quantitySold,
      Value<int> quantitySpoiled,
      Value<double> revenue,
      Value<double> costOfGoodsSold,
      Value<double> grossProfit,
      Value<int> transactionCount,
      Value<int?> openingStock,
      Value<int?> closingStock,
      Value<DateTime> createdAt,
      Value<DateTime> lastUpdated,
      Value<bool> isSynced,
      Value<String?> cloudId,
    });

final class $$DailySalesSummaryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DailySalesSummaryTable,
          DailySalesSummaryData
        > {
  $$DailySalesSummaryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.dailySalesSummary.organizationId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.dailySalesSummary.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailySalesSummaryTableFilterComposer
    extends Composer<_$AppDatabase, $DailySalesSummaryTable> {
  $$DailySalesSummaryTableFilterComposer({
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

  ColumnFilters<DateTime> get summaryDate => $composableBuilder(
    column: $table.summaryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantitySpoiled => $composableBuilder(
    column: $table.quantitySpoiled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costOfGoodsSold => $composableBuilder(
    column: $table.costOfGoodsSold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossProfit => $composableBuilder(
    column: $table.grossProfit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingStock => $composableBuilder(
    column: $table.openingStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingStock => $composableBuilder(
    column: $table.closingStock,
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$DailySalesSummaryTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySalesSummaryTable> {
  $$DailySalesSummaryTableOrderingComposer({
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

  ColumnOrderings<DateTime> get summaryDate => $composableBuilder(
    column: $table.summaryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantitySpoiled => $composableBuilder(
    column: $table.quantitySpoiled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costOfGoodsSold => $composableBuilder(
    column: $table.costOfGoodsSold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossProfit => $composableBuilder(
    column: $table.grossProfit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingStock => $composableBuilder(
    column: $table.openingStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingStock => $composableBuilder(
    column: $table.closingStock,
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailySalesSummaryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySalesSummaryTable> {
  $$DailySalesSummaryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get summaryDate => $composableBuilder(
    column: $table.summaryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantitySpoiled => $composableBuilder(
    column: $table.quantitySpoiled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get revenue =>
      $composableBuilder(column: $table.revenue, builder: (column) => column);

  GeneratedColumn<double> get costOfGoodsSold => $composableBuilder(
    column: $table.costOfGoodsSold,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grossProfit => $composableBuilder(
    column: $table.grossProfit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openingStock => $composableBuilder(
    column: $table.openingStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingStock => $composableBuilder(
    column: $table.closingStock,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$DailySalesSummaryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySalesSummaryTable,
          DailySalesSummaryData,
          $$DailySalesSummaryTableFilterComposer,
          $$DailySalesSummaryTableOrderingComposer,
          $$DailySalesSummaryTableAnnotationComposer,
          $$DailySalesSummaryTableCreateCompanionBuilder,
          $$DailySalesSummaryTableUpdateCompanionBuilder,
          (DailySalesSummaryData, $$DailySalesSummaryTableReferences),
          DailySalesSummaryData,
          PrefetchHooks Function({bool organizationId, bool itemId})
        > {
  $$DailySalesSummaryTableTableManager(
    _$AppDatabase db,
    $DailySalesSummaryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySalesSummaryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySalesSummaryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySalesSummaryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<DateTime> summaryDate = const Value.absent(),
                Value<int> quantitySold = const Value.absent(),
                Value<int> quantitySpoiled = const Value.absent(),
                Value<double> revenue = const Value.absent(),
                Value<double> costOfGoodsSold = const Value.absent(),
                Value<double> grossProfit = const Value.absent(),
                Value<int> transactionCount = const Value.absent(),
                Value<int?> openingStock = const Value.absent(),
                Value<int?> closingStock = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => DailySalesSummaryCompanion(
                id: id,
                organizationId: organizationId,
                itemId: itemId,
                summaryDate: summaryDate,
                quantitySold: quantitySold,
                quantitySpoiled: quantitySpoiled,
                revenue: revenue,
                costOfGoodsSold: costOfGoodsSold,
                grossProfit: grossProfit,
                transactionCount: transactionCount,
                openingStock: openingStock,
                closingStock: closingStock,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int organizationId,
                required int itemId,
                required DateTime summaryDate,
                Value<int> quantitySold = const Value.absent(),
                Value<int> quantitySpoiled = const Value.absent(),
                Value<double> revenue = const Value.absent(),
                Value<double> costOfGoodsSold = const Value.absent(),
                Value<double> grossProfit = const Value.absent(),
                Value<int> transactionCount = const Value.absent(),
                Value<int?> openingStock = const Value.absent(),
                Value<int?> closingStock = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
              }) => DailySalesSummaryCompanion.insert(
                id: id,
                organizationId: organizationId,
                itemId: itemId,
                summaryDate: summaryDate,
                quantitySold: quantitySold,
                quantitySpoiled: quantitySpoiled,
                revenue: revenue,
                costOfGoodsSold: costOfGoodsSold,
                grossProfit: grossProfit,
                transactionCount: transactionCount,
                openingStock: openingStock,
                closingStock: closingStock,
                createdAt: createdAt,
                lastUpdated: lastUpdated,
                isSynced: isSynced,
                cloudId: cloudId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailySalesSummaryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({organizationId = false, itemId = false}) {
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
                    if (organizationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.organizationId,
                                referencedTable:
                                    $$DailySalesSummaryTableReferences
                                        ._organizationIdTable(db),
                                referencedColumn:
                                    $$DailySalesSummaryTableReferences
                                        ._organizationIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$DailySalesSummaryTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$DailySalesSummaryTableReferences
                                        ._itemIdTable(db)
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

typedef $$DailySalesSummaryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySalesSummaryTable,
      DailySalesSummaryData,
      $$DailySalesSummaryTableFilterComposer,
      $$DailySalesSummaryTableOrderingComposer,
      $$DailySalesSummaryTableAnnotationComposer,
      $$DailySalesSummaryTableCreateCompanionBuilder,
      $$DailySalesSummaryTableUpdateCompanionBuilder,
      (DailySalesSummaryData, $$DailySalesSummaryTableReferences),
      DailySalesSummaryData,
      PrefetchHooks Function({bool organizationId, bool itemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$BranchIngredientStockTableTableManager get branchIngredientStock =>
      $$BranchIngredientStockTableTableManager(_db, _db.branchIngredientStock);
  $$BranchItemStockTableTableManager get branchItemStock =>
      $$BranchItemStockTableTableManager(_db, _db.branchItemStock);
  $$StockReplenishmentRequestsTableTableManager
  get stockReplenishmentRequests =>
      $$StockReplenishmentRequestsTableTableManager(
        _db,
        _db.stockReplenishmentRequests,
      );
  $$StockChangeRequestsTableTableManager get stockChangeRequests =>
      $$StockChangeRequestsTableTableManager(_db, _db.stockChangeRequests);
  $$DailySalesSummaryTableTableManager get dailySalesSummary =>
      $$DailySalesSummaryTableTableManager(_db, _db.dailySalesSummary);
}
