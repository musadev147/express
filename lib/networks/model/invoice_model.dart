class OrderItemInput {
  final int? productId;
  final String? name;
  final double? price;
  final int qty;

  OrderItemInput({
    this.productId,
    this.name,
    this.price,
    this.qty = 1,
  });

  Map<String, dynamic> toJson() => {
        if (productId != null) 'productId': productId,
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        'qty': qty,
      };

  factory OrderItemInput.fromJson(Map<String, dynamic> json) {
    return OrderItemInput(
      productId: json['productId'] is int
          ? json['productId']
          : int.tryParse(json['productId']?.toString() ?? json['id']?.toString() ?? '') ,
      name: json['name'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      qty: json['qty'] is int
          ? json['qty']
          : int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
    );
  }
}

class InvoiceItemDetail {
  final int? id;
  final int? productId;
  final String name;
  final String category;
  final double price;
  final int qty;
  final double lineTotal;
  final double commissionRate;
  final double commissionAmount;

  InvoiceItemDetail({
    this.id,
    this.productId,
    required this.name,
    this.category = 'General',
    required this.price,
    required this.qty,
    required this.lineTotal,
    this.commissionRate = 2.0,
    this.commissionAmount = 0.0,
  });

  factory InvoiceItemDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceItemDetail(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      productId: json['productId'] is int
          ? json['productId']
          : int.tryParse(json['productId']?.toString() ?? ''),
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      qty: json['qty'] is int
          ? json['qty']
          : int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      lineTotal: json['lineTotal'] != null
          ? (json['lineTotal'] as num).toDouble()
          : (json['price'] != null && json['qty'] != null ? (json['price'] as num).toDouble() * (json['qty'] as num).toInt() : 0.0),
      commissionRate: json['commissionRate'] != null
          ? (json['commissionRate'] as num).toDouble()
          : 2.0,
      commissionAmount: json['commissionAmount'] != null
          ? (json['commissionAmount'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'name': name,
        'category': category,
        'price': price,
        'qty': qty,
        'lineTotal': lineTotal,
        'commissionRate': commissionRate,
        'commissionAmount': commissionAmount,
      };
}

class InvoiceCreateRequest {
  final String customerPhone;
  final String customerName;
  final String? vendorPhone;
  final String? vendorShopName;
  final String? vendorArea;
  final int? vendorId;
  final List<OrderItemInput> items;
  final double discount;
  final String paymentMethod;
  final String? callId;

  InvoiceCreateRequest({
    required this.customerPhone,
    required this.customerName,
    this.vendorPhone,
    this.vendorShopName,
    this.vendorArea,
    this.vendorId,
    required this.items,
    this.discount = 0.0,
    this.paymentMethod = 'Cash on Delivery',
    this.callId,
  });

  Map<String, dynamic> toJson() => {
        'customerPhone': customerPhone,
        'customerName': customerName,
        if (vendorPhone != null) 'vendorPhone': vendorPhone,
        if (vendorShopName != null) 'vendorShopName': vendorShopName,
        if (vendorArea != null) 'vendorArea': vendorArea,
        if (vendorId != null) 'vendorId': vendorId,
        'items': items.map((e) => e.toJson()).toList(),
        'discount': discount,
        'paymentMethod': paymentMethod,
        if (callId != null) 'callId': callId,
      };
}

class InvoiceResponse {
  final String id;
  final String customerPhone;
  final String customerName;
  final String vendorPhone;
  final String vendorShopName;
  final String vendorArea;
  final List<InvoiceItemDetail> items;
  final double subtotal;
  final double discount;
  final double commissionAmount;
  final double total;
  final String status;
  final String paymentMethod;
  final String? callId;
  final String dateTime;
  final String? pdfDownloadUrl;
  final double? vendorWalletDeduction;
  final double? vendorUpdatedWalletBalance;

  InvoiceResponse({
    required this.id,
    required this.customerPhone,
    required this.customerName,
    required this.vendorPhone,
    required this.vendorShopName,
    required this.vendorArea,
    this.items = const [],
    required this.subtotal,
    this.discount = 0.0,
    this.commissionAmount = 0.0,
    required this.total,
    this.status = 'completed',
    this.paymentMethod = 'Cash on Delivery',
    this.callId,
    required this.dateTime,
    this.pdfDownloadUrl,
    this.vendorWalletDeduction,
    this.vendorUpdatedWalletBalance,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      id: json['id']?.toString() ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerName: json['customerName'] ?? '',
      vendorPhone: json['vendorPhone'] ?? '',
      vendorShopName: json['vendorShopName'] ?? '',
      vendorArea: json['vendorArea'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List).map((e) => InvoiceItemDetail.fromJson(e)).toList()
          : [],
      subtotal: json['subtotal'] != null ? (json['subtotal'] as num).toDouble() : 0.0,
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
      commissionAmount: json['commissionAmount'] != null ? (json['commissionAmount'] as num).toDouble() : 0.0,
      total: json['total'] != null ? (json['total'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'completed',
      paymentMethod: json['paymentMethod'] ?? 'Cash on Delivery',
      callId: json['callId'],
      dateTime: json['dateTime'] ?? json['createdAt'] ?? '',
      pdfDownloadUrl: json['pdfDownloadUrl'],
      vendorWalletDeduction: json['vendorWalletDeduction'] != null
          ? (json['vendorWalletDeduction'] as num).toDouble()
          : null,
      vendorUpdatedWalletBalance: json['vendorUpdatedWalletBalance'] != null
          ? (json['vendorUpdatedWalletBalance'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerPhone': customerPhone,
        'customerName': customerName,
        'vendorPhone': vendorPhone,
        'vendorShopName': vendorShopName,
        'vendorArea': vendorArea,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'commissionAmount': commissionAmount,
        'total': total,
        'status': status,
        'paymentMethod': paymentMethod,
        'callId': callId,
        'dateTime': dateTime,
        'pdfDownloadUrl': pdfDownloadUrl,
        'vendorWalletDeduction': vendorWalletDeduction,
        'vendorUpdatedWalletBalance': vendorUpdatedWalletBalance,
      };
}
