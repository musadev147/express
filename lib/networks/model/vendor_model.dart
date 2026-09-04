class VendorMarketplaceItem {
  final int id;
  final String name;
  final String shopName;
  final String phone;
  final String category;
  final String area;
  final String address;
  final double distanceKm;
  final int productCount;
  final double rating;
  final double? walletBalance;
  final bool isVerified;

  VendorMarketplaceItem({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.category,
    required this.area,
    required this.address,
    this.distanceKm = 0.8,
    this.productCount = 0,
    this.rating = 4.8,
    this.walletBalance,
    this.isVerified = false,
  });

  factory VendorMarketplaceItem.fromJson(Map<String, dynamic> json) {
    return VendorMarketplaceItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      shopName: json['shopName'] ?? '',
      phone: json['phone'] ?? '',
      category: json['category'] ?? 'General',
      area: json['area'] ?? '',
      address: json['address'] ?? '',
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : 0.8,
      productCount: json['productCount'] is int
          ? json['productCount']
          : int.tryParse(json['productCount']?.toString() ?? '0') ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 4.8,
      walletBalance: json['walletBalance'] != null ? (json['walletBalance'] as num).toDouble() : null,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shopName': shopName,
        'phone': phone,
        'category': category,
        'area': area,
        'address': address,
        'distanceKm': distanceKm,
        'productCount': productCount,
        'rating': rating,
        'walletBalance': walletBalance,
        'isVerified': isVerified,
      };
}

class DashboardSummaryModel {
  final double todaySales;
  final int totalInvoices;
  final int totalProducts;
  final int unfulfilledSearchRequests;
  final double walletBalance;

  DashboardSummaryModel({
    this.todaySales = 0.0,
    this.totalInvoices = 0,
    this.totalProducts = 0,
    this.unfulfilledSearchRequests = 0,
    this.walletBalance = 0.0,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      todaySales: json['todaySales'] != null ? (json['todaySales'] as num).toDouble() : 0.0,
      totalInvoices: json['totalInvoices'] is int
          ? json['totalInvoices']
          : int.tryParse(json['totalInvoices']?.toString() ?? '0') ?? 0,
      totalProducts: json['totalProducts'] is int
          ? json['totalProducts']
          : int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0,
      unfulfilledSearchRequests: json['unfulfilledSearchRequests'] is int
          ? json['unfulfilledSearchRequests']
          : int.tryParse(json['unfulfilledSearchRequests']?.toString() ?? '0') ?? 0,
      walletBalance: json['walletBalance'] != null ? (json['walletBalance'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'todaySales': todaySales,
        'totalInvoices': totalInvoices,
        'totalProducts': totalProducts,
        'unfulfilledSearchRequests': unfulfilledSearchRequests,
        'walletBalance': walletBalance,
      };
}
