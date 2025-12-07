// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:chickenjoo_inventory/database/seeders/admin_seeder.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Inventory');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1920, 1080));
  }
  
  //await DatabaseConnection.deleteOldDatabase();
  //await DatabaseConnection.deleteDatabase();
  await AdminSeeder.seed(AppDatabase()); // Important for Testing admin@commissary.com ; admin123

  runApp(const MyApp());
}