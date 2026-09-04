class SearchDemandCreateRequest {
  final String query;
  final String area;
  final String? upazila;
  final String? district;
  final String? division;

  SearchDemandCreateRequest({
    required this.query,
    required this.area,
    this.upazila,
    this.district,
    this.division,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'area': area,
        if (upazila != null) 'upazila': upazila,
        if (district != null) 'district': district,
        if (division != null) 'division': division,
      };
}

class SearchDemandCreateResponse {
  final String requestId;
  final int vendorsNotifiedCount;

  SearchDemandCreateResponse({
    required this.requestId,
    required this.vendorsNotifiedCount,
  });

  factory SearchDemandCreateResponse.fromJson(Map<String, dynamic> json) {
    return SearchDemandCreateResponse(
      requestId: json['requestId'] ?? '',
      vendorsNotifiedCount: json['vendorsNotifiedCount'] is int
          ? json['vendorsNotifiedCount']
          : int.tryParse(json['vendorsNotifiedCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'vendorsNotifiedCount': vendorsNotifiedCount,
      };
}

class SearchDemandItem {
  final String id;
  final String product;
  final String area;
  final String? customerPhone;
  final String time;
  final String status;

  SearchDemandItem({
    required this.id,
    required this.product,
    required this.area,
    this.customerPhone,
    required this.time,
    required this.status,
  });

  factory SearchDemandItem.fromJson(Map<String, dynamic> json) {
    return SearchDemandItem(
      id: json['id']?.toString() ?? '',
      product: json['product'] ?? json['queryText'] ?? '',
      area: json['area'] ?? json['areaName'] ?? '',
      customerPhone: json['customerPhone'],
      time: json['time'] ?? json['createdAt'] ?? '',
      status: json['status'] ?? 'unfulfilled',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product,
        'area': area,
        'customerPhone': customerPhone,
        'time': time,
        'status': status,
      };
}
