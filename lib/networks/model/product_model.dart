class ProductResponse {
  final int id;
  final int vendorId;
  final String name;
  final String category;
  final int? categoryId;
  final double commissionRate;
  final String? description;
  final double price;
  final int stock;
  final String unit;
  final bool isAvailable;
  final List<String> tags;
  final String? imageUrl;

  ProductResponse({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    this.categoryId,
    this.commissionRate = 2.0,
    this.description,
    required this.price,
    required this.stock,
    required this.unit,
    required this.isAvailable,
    this.tags = const [],
    this.imageUrl,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      vendorId: json['vendorId'] is int
          ? json['vendorId']
          : int.tryParse(json['vendorId']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      categoryId: json['categoryId'] is int ? json['categoryId'] : null,
      commissionRate: json['commissionRate'] != null
          ? (json['commissionRate'] as num).toDouble()
          : 2.0,
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      unit: json['unit'] ?? 'pcs',
      isAvailable: json['isAvailable'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendorId': vendorId,
        'name': name,
        'category': category,
        if (categoryId != null) 'categoryId': categoryId,
        'commissionRate': commissionRate,
        'description': description,
        'price': price,
        'stock': stock,
        'unit': unit,
        'isAvailable': isAvailable,
        'tags': tags,
        'imageUrl': imageUrl,
      };
}

class ProductCreateRequest {
  final String name;
  final String category;
  final int? categoryId;
  final String? description;
  final double price;
  final int stock;
  final String unit;
  final bool isAvailable;
  final List<String> tags;
  final String? imageUrl;

  ProductCreateRequest({
    required this.name,
    this.category = 'Electronics',
    this.categoryId,
    this.description,
    required this.price,
    this.stock = 0,
    this.unit = 'pcs',
    this.isAvailable = true,
    this.tags = const [],
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        if (categoryId != null) 'categoryId': categoryId,
        if (description != null) 'description': description,
        'price': price,
        'stock': stock,
        'unit': unit,
        'isAvailable': isAvailable,
        'tags': tags,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

class ProductUpdateRequest {
  final String? name;
  final String? category;
  final int? categoryId;
  final String? description;
  final double? price;
  final int? stock;
  final String? unit;
  final bool? isAvailable;
  final List<String>? tags;
  final String? imageUrl;

  ProductUpdateRequest({
    this.name,
    this.category,
    this.categoryId,
    this.description,
    this.price,
    this.stock,
    this.unit,
    this.isAvailable,
    this.tags,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (categoryId != null) 'categoryId': categoryId,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (stock != null) 'stock': stock,
        if (unit != null) 'unit': unit,
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (tags != null) 'tags': tags,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
