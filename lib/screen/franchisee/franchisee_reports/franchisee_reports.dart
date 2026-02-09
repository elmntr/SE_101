import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'franchisee_reports_mobile.dart';
import 'franchisee_reports_desktop.dart';
import 'franchisee_reports_controller.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => ReportsPageState();
}

class ReportsPageState extends State<ReportsPage> {
  late AppDatabase db;
  late FranchiseeReportsController controller;

  // Expose controller properties for UI access
  int? get selectedItemId => controller.selectedItemId;
  set selectedItemId(int? value) => controller.selectedItemId = value;

  String get selectedPeriod => controller.selectedPeriod;
  set selectedPeriod(String value) => controller.selectedPeriod = value;

  DateTime get currentDate => controller.currentDate;
  set currentDate(DateTime value) => controller.currentDate = value;

  DateTime? get selectedSpecificDate => controller.selectedSpecificDate;
  set selectedSpecificDate(DateTime? value) =>
      controller.selectedSpecificDate = value;

  String get selectedMetric => controller.selectedMetric;
  set selectedMetric(String value) => controller.selectedMetric = value;

  DateTime? get customRangeStart => controller.customRangeStart;
  set customRangeStart(DateTime? value) => controller.customRangeStart = value;

  DateTime? get customRangeEnd => controller.customRangeEnd;
  set customRangeEnd(DateTime? value) => controller.customRangeEnd = value;

  bool get useCustomRange => controller.useCustomRange;
  set useCustomRange(bool value) => controller.useCustomRange = value;

  List<Item> get allItems => controller.allItems;
  int? get currentOrganizationId => controller.currentOrganizationId;
  Map<String, List<double>> get chartData => controller.chartData;
  double get totalSold => controller.totalSold;
  double get totalSpoilage => controller.totalSpoilage;
  double get allTimeTotalSold => controller.allTimeTotalSold;
  double get allTimeTotalSpoilage => controller.allTimeTotalSpoilage;
  double get selectedDateSold => controller.selectedDateSold;
  double get selectedDateSpoilage => controller.selectedDateSpoilage;
  bool get isLoading => controller.isLoading;

  List<String> get periods => controller.periods;

  double get displayTotalSold => controller.displayTotalSold;
  double get displayTotalSpoilage => controller.displayTotalSpoilage;
  bool get hasSpecificDateSelected => controller.hasSpecificDateSelected;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = FranchiseeReportsController(
      db: db,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    controller.loadData();
  }

  Future<void> loadData() async {
    await controller.loadData();
  }

  Future<void> calculateChartData() async {
    await controller.calculateChartData();
  }

  String getDateRangeText() {
    return controller.getDateRangeText();
  }

  void clearDateSelection() {
    controller.clearDateSelection();
  }

  String formatDate(DateTime date) {
    return controller.formatDate(date);
  }

  String formatMonthYear(DateTime date) {
    return controller.formatMonthYear(date);
  }

  List<String> getChartLabels() {
    return controller.getChartLabels();
  }

  Future<void> navigateDate(bool forward) async {
    await controller.navigateDate(forward);
  }

  Future<void> openPeriodPicker(BuildContext context) async {
    await controller.openPeriodPicker(context);
  }

  String getSelectedItemName() {
    return controller.getSelectedItemName();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (AppLayout.isDesktop(context) == false) {
      return ReportsPageMobile(state: this);
    }
    return ReportsPageDesktop(state: this);
  }
}
