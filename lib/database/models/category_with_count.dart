/// Category with item count
class CategoryWithCount {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final int itemCount;

  CategoryWithCount({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastUpdated,
    required this.itemCount,
  });
}
