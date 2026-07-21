class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
}

class SaleModel {
  final String id;
  final List<SaleItemModel> items;
  final double subtotal;
  final double discount;
  final double total;
  final String? customerId;
  final String? customerName;
  final String workerId;
  final String? branchId;
  final DateTime createdAt;
  final String paymentMethod;

  const SaleModel({
    required this.id,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    this.customerId,
    this.customerName,
    required this.workerId,
    this.branchId,
    required this.createdAt,
    this.paymentMethod = 'cash',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'customerId': customerId,
        'customerName': customerName,
        'workerId': workerId,
        'branchId': branchId,
        'createdAt': createdAt.toIso8601String(),
        'paymentMethod': paymentMethod,
      };
}
