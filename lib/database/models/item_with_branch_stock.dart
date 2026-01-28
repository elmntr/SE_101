// lib/database/models/item_with_branch_stock.dart
import '../app_database.dart';

/// Model class combining Item (master product info) with BranchItemStock (branch-specific quantities)
///
/// This enables the multi-branch inventory architecture where:
/// - Master item info (name, description, category) comes from Items table
/// - Branch-specific quantities (stock, sold, spoilage, price) come from BranchItemStock
///
/// Usage:
/// - Franchisees see their branch's stock levels
/// - Each branch has independent inventory
/// - Commissary can see network-wide view
class ItemWithBranchStock {
  /// Master item info (name, description, category, unit, etc.)
  final Item item;

  /// Branch-specific stock data (may be null if branch hasn't received this item yet)
  final BranchItemStockData? branchStock;

  /// Optional category info
  final Category? category;

  ItemWithBranchStock({
    required this.item,
    this.branchStock,
    this.category,
  });

  // ============================================================================
  // CONVENIENCE GETTERS
  // ============================================================================

  /// Item ID (from master item)
  int get id => item.id;

  /// Item name (from master item)
  String get name => item.name;

  /// Item description (from master item)
  String? get description => item.description;

  /// Unit of measurement (from master item)
  String get unit => item.unit;

  /// Category name
  String get categoryName => category?.name ?? 'Uncategorized';

  /// Category ID
  int? get categoryId => item.categoryId;

  // ============================================================================
  // BRANCH-SPECIFIC DATA (defaults to 0 if no branch stock record exists)
  // ============================================================================

  /// Current stock at this branch (0 if no record)
  int get stock => branchStock?.stock ?? 0;

  /// Total sold at this branch (0 if no record)
  int get sold => branchStock?.sold ?? 0;

  /// Total spoilage at this branch (0 if no record)
  int get spoilage => branchStock?.spoilage ?? 0;

  /// Branch's selling price (falls back to master item price if not set)
  double? get price => branchStock?.price ?? item.price;

  /// Branch's cost price (what they pay commissary)
  double? get costPrice => branchStock?.costPrice ?? item.costPrice;

  /// Minimum stock level for alerts
  int? get minimumStock => branchStock?.minimumStock ?? item.minimumStock;

  /// Last time this branch received a delivery
  DateTime? get lastReceivedAt => branchStock?.lastReceivedAt;

  /// Quantity from last delivery
  int? get lastReceivedQuantity => branchStock?.lastReceivedQuantity;

  /// Branch stock record ID (null if no record exists)
  int? get branchStockId => branchStock?.id;

  /// Whether this branch has a stock record (vs showing default 0)
  bool get hasBranchStock => branchStock != null;

  /// Cloud ID for the master item
  String? get itemCloudId => item.cloudId;

  /// Cloud ID for the branch stock record
  String? get branchStockCloudId => branchStock?.cloudId;

  // ============================================================================
  // STATUS HELPERS
  // ============================================================================

  /// Whether stock is below minimum threshold
  bool get isLowStock {
    final minStock = minimumStock;
    if (minStock == null) return false;
    return stock <= minStock;
  }

  /// Whether item is out of stock
  bool get isOutOfStock => stock <= 0;

  /// Gross revenue (price × sold) - only meaningful if price is set
  double get grossRevenue => (price ?? 0) * sold;

  /// Spoilage cost (cost price × spoilage)
  double get spoilageCost => (costPrice ?? 0) * spoilage;

  /// Last updated timestamp (from branch stock or master item)
  DateTime get lastUpdated => branchStock?.lastUpdated ?? item.lastUpdated;

  @override
  String toString() {
    return 'ItemWithBranchStock(name: $name, stock: $stock, sold: $sold, spoilage: $spoilage, hasBranchStock: $hasBranchStock)';
  }
}

/// Model for commissary network-wide view showing all branches' stock for an item
class ItemWithAllBranchesStock {
  /// Master item info
  final Item item;

  /// Stock data from all branches
  final List<BranchStockSummary> branchStocks;

  /// Optional category info
  final Category? category;

  ItemWithAllBranchesStock({
    required this.item,
    required this.branchStocks,
    this.category,
  });

  /// Total stock across all branches
  int get totalStock => branchStocks.fold(0, (sum, b) => sum + b.stock);

  /// Total sold across all branches
  int get totalSold => branchStocks.fold(0, (sum, b) => sum + b.sold);

  /// Total spoilage across all branches
  int get totalSpoilage => branchStocks.fold(0, (sum, b) => sum + b.spoilage);

  /// Number of branches that have this item
  int get branchCount => branchStocks.length;

  /// Item name
  String get name => item.name;

  /// Category name
  String get categoryName => category?.name ?? 'Uncategorized';
}

/// Summary of a single branch's stock for network-wide view
class BranchStockSummary {
  final int organizationId;
  final String branchName;
  final int stock;
  final int sold;
  final int spoilage;
  final double? price;

  BranchStockSummary({
    required this.organizationId,
    required this.branchName,
    required this.stock,
    required this.sold,
    required this.spoilage,
    this.price,
  });
}
