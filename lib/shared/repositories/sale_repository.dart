import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/product_model.dart';
import '../../shared/models/sale_model.dart';
import 'product_repository.dart';
import 'repository_exceptions.dart';

class SaleRepository {
  final AppDatabase _db = AppDatabase.instance;
  final ProductRepository _products = ProductRepository();

  Future<SaleModel> createSale({
    required List<ProductModel> items,
    required double discount,
    required String workerId,
    String? customerId,
    String? customerName,
    String? branchId,
    String paymentMethod = 'cash',
  }) async {
    if (items.isEmpty) {
      throw ValidationException('Add at least one product to complete the sale.');
    }
    if (discount < 0) {
      throw ValidationException('Discount cannot be negative.');
    }

    try {
      final subtotal = items.fold<double>(0, (sum, item) => sum + (item.sellingPrice * item.quantity));
      final total = (subtotal - discount).clamp(0, double.infinity).toDouble();

      final saleId = Uuid().v4();
      final now = DateTime.now();

      await _db.transaction(() async {
        await _db.into(_db.sales).insert(SalesCompanion(
          id: Value(saleId),
          subtotal: Value(subtotal),
          discount: Value(discount),
          total: Value(total),
          customerId: Value(customerId),
          customerName: Value(customerName),
          workerId: Value(workerId),
          branchId: Value(branchId),
          createdAt: Value(now),
          paymentMethod: Value(paymentMethod),
        ));

        for (final item in items) {
          final quantity = item.quantity;
          if (quantity <= 0) {
            throw ValidationException('Quantity must be greater than zero.');
          }

          final product = await (_db.select(_db.products)
                ..where((tbl) => tbl.id.equals(item.id)))
              .getSingleOrNull();
          if (product == null) {
            throw ValidationException('Product "${item.name}" not found.');
          }
          if (product.quantity < quantity) {
            throw ValidationException(
                'Insufficient stock for "${item.name}". Available: ${product.quantity}, Requested: $quantity.');
          }

          await _db.into(_db.saleItems).insert(SaleItemsCompanion(
            id: Value(Uuid().v4()),
            saleId: Value(saleId),
            productId: Value(item.id),
            productName: Value(item.name),
            quantity: Value(quantity),
            unitPrice: Value(item.sellingPrice),
            totalPrice: Value(item.sellingPrice * quantity),
          ));

          await (_db.update(_db.products)
                ..where((tbl) => tbl.id.equals(item.id)))
              .write(ProductsCompanion(
            quantity: Value(product.quantity - quantity),
            updatedAt: Value(now),
          ));
        }
      });

      return SaleModel(
        id: saleId,
        items: items.map((p) => SaleItemModel(
              productId: p.id,
              productName: p.name,
              quantity: p.quantity,
              unitPrice: p.sellingPrice,
              totalPrice: p.sellingPrice * p.quantity,
            )).toList(),
        subtotal: subtotal,
        discount: discount,
        total: total,
        customerId: customerId,
        customerName: customerName,
        workerId: workerId,
        branchId: branchId,
        createdAt: now,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Unable to create sale: $e');
    }
  }

  /// Watches the most recent [limit] sales as a reactive stream.
  ///
  /// Emits a new list automatically whenever the sales table changes,
  /// so the UI refreshes without manual reloads.
  Stream<List<SaleModel>> watchRecentSales({int limit = 50}) {
    return (_db.select(_db.sales)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch()
        .asyncMap((rows) async {
      final result = <SaleModel>[];
      for (final row in rows) {
        final saleItems = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        result.add(SaleModel(
          id: row.id,
          items: saleItems
              .map((item) => SaleItemModel(
                    productId: item.productId,
                    productName: item.productName,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    totalPrice: item.totalPrice,
                  ))
              .toList(),
          subtotal: row.subtotal,
          discount: row.discount,
          total: row.total,
          customerId: row.customerId,
          customerName: row.customerName,
          workerId: row.workerId,
          branchId: row.branchId,
          createdAt: row.createdAt,
          paymentMethod: row.paymentMethod,
        ));
      }
      return result;
    });
  }

  Future<List<SaleModel>> getRecentSales() async {
    try {
      final rows = await (_db.select(_db.sales)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(10))
          .get();
      final items = <SaleModel>[];
      for (final row in rows) {
        final saleItems = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        items.add(SaleModel(
          id: row.id,
          items: saleItems.map((item) => SaleItemModel(
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalPrice,
              )).toList(),
          subtotal: row.subtotal,
          discount: row.discount,
          total: row.total,
          customerId: row.customerId,
          customerName: row.customerName,
          workerId: row.workerId,
          branchId: row.branchId,
          createdAt: row.createdAt,
          paymentMethod: row.paymentMethod,
        ));
      }
      return items;
    } catch (e) {
      throw DatabaseException('Unable to load sales: $e');
    }
  }

  Future<double> getTodayRevenue() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));
      final rows = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(start, end)))
          .get();
      return rows.fold<double>(0, (sum, row) => sum + row.total);
    } catch (e) {
      throw DatabaseException('Unable to load today revenue: $e');
    }
  }

  Future<double> getTodayProfit() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));
      final rows = await (_db.select(_db.sales)
            ..where((tbl) => tbl.createdAt.isBetweenValues(start, end)))
          .get();
      double profit = 0;
      for (final row in rows) {
        final items = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        for (final item in items) {
          final product = await _products.getProductById(item.productId);
          if (product != null) {
            profit += item.totalPrice - (product.purchasePrice * item.quantity);
          }
        }
      }
      return profit;
    } catch (e) {
      throw DatabaseException('Unable to load today profit: $e');
    }
  }

  /// Watches daily revenue and profit for the last [days] days (including today).
  ///
  /// Returns a list of [DailyRevenueProfit] ordered oldest-first, one entry
  /// per day. The UI can map each entry to a chart spot.
  Stream<List<DailyRevenueProfit>> watchDailyRevenueProfit({int days = 7}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    return (_db.select(_db.sales)
          ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(start)))
        .watch()
        .asyncMap((rows) async {
      final byDay = <DateTime, _DayBucket>{};
      for (var i = 0; i < days; i++) {
        final day = start.add(Duration(days: i));
        byDay[day] = _DayBucket();
      }

      for (final row in rows) {
        final dayKey = DateTime(row.createdAt.year, row.createdAt.month, row.createdAt.day);
        final bucket = byDay[dayKey];
        if (bucket == null) continue;
        bucket.revenue += row.total;

        final items = await (_db.select(_db.saleItems)
              ..where((tbl) => tbl.saleId.equals(row.id)))
            .get();
        for (final item in items) {
          final product = await _products.getProductById(item.productId);
          if (product != null) {
            bucket.profit += item.totalPrice - (product.purchasePrice * item.quantity);
          }
        }
      }

      return byDay.entries.map((e) => DailyRevenueProfit(
        date: e.key,
        revenue: e.value.revenue,
        profit: e.value.profit,
      )).toList();
    });
  }

  /// Watches the top [limit] best-selling products by total revenue within the
  /// last [days] days (including today).
  Stream<List<BestSellerEntry>> watchBestSellers({int days = 7, int limit = 5}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    return (_db.select(_db.saleItems)
          ..where((tbl) => tbl.totalPrice.isBiggerOrEqualValue(0)))
        .watch()
        .asyncMap((rows) async {
      // Filter sale items by sale date
      final productAgg = <String, _ProductAgg>{};
      for (final item in rows) {
        final sale = await (_db.select(_db.sales)
              ..where((tbl) => tbl.id.equals(item.saleId)))
            .getSingleOrNull();
        if (sale == null) continue;
        if (sale.createdAt.isBefore(start)) continue;

        final agg = productAgg.putIfAbsent(
          item.productId,
          () => _ProductAgg(name: item.productName),
        );
        agg.units += item.quantity;
        agg.revenue += item.totalPrice;
      }

      final sorted = productAgg.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
      return sorted.take(limit).map((a) => BestSellerEntry(
        productName: a.name,
        units: a.units,
        revenue: a.revenue,
      )).toList();
    });
  }

  /// Watches the percentage breakdown of sales revenue by product category
  /// within the last [days] days (including today).
  Stream<List<CategoryShare>> watchCategoryBreakdown({int days = 7}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    return (_db.select(_db.saleItems))
        .watch()
        .asyncMap((rows) async {
      final categoryRevenue = <String, double>{};
      double totalRevenue = 0;

      for (final item in rows) {
        final sale = await (_db.select(_db.sales)
              ..where((tbl) => tbl.id.equals(item.saleId)))
            .getSingleOrNull();
        if (sale == null) continue;
        if (sale.createdAt.isBefore(start)) continue;

        final product = await _products.getProductById(item.productId);
        final category = product?.category ?? 'Other';
        categoryRevenue[category] = (categoryRevenue[category] ?? 0) + item.totalPrice;
        totalRevenue += item.totalPrice;
      }

      if (totalRevenue == 0) return [];

      return categoryRevenue.entries.map((e) => CategoryShare(
        category: e.key,
        revenue: e.value,
        percentage: (e.value / totalRevenue) * 100,
      )).toList();
    });
  }
}

/// One day's aggregated revenue and profit, used for the analytics chart.
class DailyRevenueProfit {
  final DateTime date;
  final double revenue;
  final double profit;

  const DailyRevenueProfit({
    required this.date,
    required this.revenue,
    required this.profit,
  });
}

/// A single product's aggregated sales, used for the best-sellers list.
class BestSellerEntry {
  final String productName;
  final int units;
  final double revenue;

  const BestSellerEntry({
    required this.productName,
    required this.units,
    required this.revenue,
  });
}

/// A category's share of total sales revenue, used for the pie chart.
class CategoryShare {
  final String category;
  final double revenue;
  final double percentage;

  const CategoryShare({
    required this.category,
    required this.revenue,
    required this.percentage,
  });
}

class _DayBucket {
  double revenue = 0;
  double profit = 0;
}

class _ProductAgg {
  final String name;
  int units = 0;
  double revenue = 0;

  _ProductAgg({required this.name});
}
