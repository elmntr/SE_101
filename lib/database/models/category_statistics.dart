/// Category statistics
class CategoryStatistics {
  final int totalItems;
  final int totalStock;
  final int totalSold;
  final int totalSpoilage;
  final double avgStock;

  CategoryStatistics({
    required this.totalItems,
    required this.totalStock,
    required this.totalSold,
    required this.totalSpoilage,
    required this.avgStock,
  });
}