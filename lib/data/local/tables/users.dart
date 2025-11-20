import 'package:drift/drift.dart';

// ADDED: Defines the local `Users` table to persist login credentials and roles.
class Users extends Table {
  // ADDED: Surrogate primary key so each account row has a unique identifier.
  IntColumn get id => integer().autoIncrement()();

  // ADDED: Email is required and must be unique to avoid duplicate accounts.
  TextColumn get email => text().withLength(min: 3, max: 100).unique()();

  // ADDED: Optional display name for account listings.
  TextColumn get name => text().nullable()();

  // ADDED: Optional phone number contact info.
  TextColumn get phone => text().nullable().withLength(min: 0, max: 20)();

  // ADDED: Password stored as plain text for demo purposes; replace with hashing in production.
  TextColumn get password => text().withLength(min: 4, max: 128)();

  // ADDED: Role controls which parts of the UI can be accessed.
  TextColumn get role => text().withLength(min: 3, max: 50)();
}

