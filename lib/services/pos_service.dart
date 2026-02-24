// lib/services/pos_service.dart
//
// POS Service - Handles atomic sale and spoilage transactions
// Updates both BranchItemStock and DailySalesSummary in a single atomic operation

import '../database/app_database.dart';
import '../database/models/item_with_branch_stock.dart';

/// Transaction types for POS operations
enum TransactionType { sale, spoilage }

/// Result of a POS transaction
class TransactionResult {
  final bool success;
  final String? errorMessage;
  final int? newStock;
  final int quantityChanged;
  final TransactionType type;

  TransactionResult({
    required this.success,
    this.errorMessage,
    this.newStock,
    required this.quantityChanged,
    required this.type,
  });

  factory TransactionResult.success({
    required int newStock,
    required int quantityChanged,
    required TransactionType type,
  }) {
    return TransactionResult(
      success: true,
      newStock: newStock,
      quantityChanged: quantityChanged,
      type: type,
    );
  }

  factory TransactionResult.failure(String error, TransactionType type) {
    return TransactionResult(
      success: false,
      errorMessage: error,
      quantityChanged: 0,
      type: type,
    );
  }
}

/// POS Service for recording sales and spoilage transactions
///
/// This service ensures that both stock levels and financial summaries
/// are updated atomically to maintain data integrity.
class PosService {
  final AppDatabase db;

  PosService({required this.db});

  /// Record a sale transaction
  ///
  /// This method:
  /// 1. Validates stock is sufficient
  /// 2. Updates BranchItemStock (decreases stock, increases sold)
  /// 3. Updates DailySalesSummary (records revenue and profit)
  /// 4. Optionally creates an audit trail via StockChangeRequests
  Future<TransactionResult> recordSale({
    required ItemWithBranchStock item,
    required int quantity,
    required int organizationId,
    int? requestedByUserId,
    bool createAuditRecord = true,
  }) async {
    try {
      // Validate
      if (quantity <= 0) {
        return TransactionResult.failure(
          'Quantity must be greater than 0',
          TransactionType.sale,
        );
      }

      if (!item.hasBranchStock) {
        return TransactionResult.failure(
          'No stock record exists for this item at this branch',
          TransactionType.sale,
        );
      }

      if (item.stock < quantity) {
        return TransactionResult.failure(
          'Insufficient stock. Available: ${item.stock}, Requested: $quantity',
          TransactionType.sale,
        );
      }

      final branchStockId = item.branchStockId!;
      final currentStock = item.stock;
      final newStock = currentStock - quantity;

      // Get price and cost for financial calculations
      final unitPrice = item.price ?? 0.0;
      final unitCost = item.costPrice ?? 0.0;

      //print('💰 Recording sale: ${item.name} x $quantity @ ₱$unitPrice');
      //print('   Stock: $currentStock → $newStock');

      // 1. Update BranchItemStock (stock decreases, sold increases)
      final stockSuccess = await db.branchItemStockDao.recordSale(
        branchStockId,
        quantity,
      );

      if (!stockSuccess) {
        return TransactionResult.failure(
          'Failed to update stock record',
          TransactionType.sale,
        );
      }

      // 2. Update DailySalesSummary (financial record)
      await db.dailySalesSummaryDao.recordSale(
        organizationId: organizationId,
        itemId: item.id,
        quantity: quantity,
        unitPrice: unitPrice,
        unitCost: unitCost,
        currentStock: newStock,
      );

      //print('   ✅ Sale recorded in DailySalesSummary');

      // 3. Create audit trail (optional)
      if (createAuditRecord && requestedByUserId != null) {
        final requestId = await db.stockChangeRequestsDao.createChangeRequest(
          franchiseeId: organizationId,
          itemId: item.id,
          changeType: 'sold',
          quantity: quantity,
          requestedBy: requestedByUserId,
          originalStock: currentStock,
          reason: 'POS Sale',
        );
        await db.stockChangeRequestsDao.submitChangeRequest(requestId);
        //print('   📋 Audit record created: $requestId');
      }

      return TransactionResult.success(
        newStock: newStock,
        quantityChanged: quantity,
        type: TransactionType.sale,
      );
    } catch (e) {
      //print('❌ Error recording sale: $e');
      return TransactionResult.failure(
        'Error recording sale: $e',
        TransactionType.sale,
      );
    }
  }

  /// Record a spoilage transaction
  ///
  /// This method:
  /// 1. Validates stock is sufficient
  /// 2. Updates BranchItemStock (decreases stock, increases spoilage)
  /// 3. Updates DailySalesSummary (records loss)
  /// 4. Optionally creates an audit trail via StockChangeRequests
  Future<TransactionResult> recordSpoilage({
    required ItemWithBranchStock item,
    required int quantity,
    required int organizationId,
    int? requestedByUserId,
    bool createAuditRecord = true,
  }) async {
    try {
      // Validate
      if (quantity <= 0) {
        return TransactionResult.failure(
          'Quantity must be greater than 0',
          TransactionType.spoilage,
        );
      }

      if (!item.hasBranchStock) {
        return TransactionResult.failure(
          'No stock record exists for this item at this branch',
          TransactionType.spoilage,
        );
      }

      if (item.stock < quantity) {
        return TransactionResult.failure(
          'Insufficient stock. Available: ${item.stock}, Requested: $quantity',
          TransactionType.spoilage,
        );
      }

      final branchStockId = item.branchStockId!;
      final currentStock = item.stock;
      final newStock = currentStock - quantity;

      //print('🗑️ Recording spoilage: ${item.name} x $quantity');
      //print('   Stock: $currentStock → $newStock');

      // 1. Update BranchItemStock (stock decreases, spoilage increases)
      final stockSuccess = await db.branchItemStockDao.recordSpoilage(
        branchStockId,
        quantity,
      );

      if (!stockSuccess) {
        return TransactionResult.failure(
          'Failed to update stock record',
          TransactionType.spoilage,
        );
      }

      // 2. Update DailySalesSummary (financial record - loss)
      await db.dailySalesSummaryDao.recordSpoilage(
        organizationId: organizationId,
        itemId: item.id,
        quantity: quantity,
        currentStock: newStock,
      );

      //print('   ✅ Spoilage recorded in DailySalesSummary');

      // 3. Create audit trail (optional)
      if (createAuditRecord && requestedByUserId != null) {
        final requestId = await db.stockChangeRequestsDao.createChangeRequest(
          franchiseeId: organizationId,
          itemId: item.id,
          changeType: 'spoiled',
          quantity: quantity,
          requestedBy: requestedByUserId,
          originalStock: currentStock,
          reason: 'POS Spoilage',
        );
        await db.stockChangeRequestsDao.submitChangeRequest(requestId);
        //print('   📋 Audit record created: $requestId');
      }

      return TransactionResult.success(
        newStock: newStock,
        quantityChanged: quantity,
        type: TransactionType.spoilage,
      );
    } catch (e) {
      //print('❌ Error recording spoilage: $e');
      return TransactionResult.failure(
        'Error recording spoilage: $e',
        TransactionType.spoilage,
      );
    }
  }

  /// Record a transaction (sale or spoilage)
  ///
  /// Convenience method that routes to recordSale or recordSpoilage
  Future<TransactionResult> recordTransaction({
    required ItemWithBranchStock item,
    required int quantity,
    required TransactionType type,
    required int organizationId,
    int? requestedByUserId,
    bool createAuditRecord = true,
  }) async {
    switch (type) {
      case TransactionType.sale:
        return recordSale(
          item: item,
          quantity: quantity,
          organizationId: organizationId,
          requestedByUserId: requestedByUserId,
          createAuditRecord: createAuditRecord,
        );
      case TransactionType.spoilage:
        return recordSpoilage(
          item: item,
          quantity: quantity,
          organizationId: organizationId,
          requestedByUserId: requestedByUserId,
          createAuditRecord: createAuditRecord,
        );
    }
  }
}
