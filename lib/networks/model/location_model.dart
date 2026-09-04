class AreaItem {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  AreaItem({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory AreaItem.fromJson(Map<String, dynamic> json) {
    return AreaItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class UpazilaItem {
  final int id;
  final String name;
  final List<AreaItem> areas;

  UpazilaItem({
    required this.id,
    required this.name,
    this.areas = const [],
  });

  factory UpazilaItem.fromJson(Map<String, dynamic> json) {
    return UpazilaItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      areas: json['areas'] != null
          ? (json['areas'] as List).map((e) => AreaItem.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'areas': areas.map((e) => e.toJson()).toList(),
      };
}

class DistrictItem {
  final int id;
  final String name;
  final List<UpazilaItem> upazilas;

  DistrictItem({
    required this.id,
    required this.name,
    this.upazilas = const [],
  });

  factory DistrictItem.fromJson(Map<String, dynamic> json) {
    return DistrictItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      upazilas: json['upazilas'] != null
          ? (json['upazilas'] as List).map((e) => UpazilaItem.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'upazilas': upazilas.map((e) => e.toJson()).toList(),
      };
}

class DivisionItem {
  final int id;
  final String name;
  final List<DistrictItem> districts;

  DivisionItem({
    required this.id,
    required this.name,
    this.districts = const [],
  });

  factory DivisionItem.fromJson(Map<String, dynamic> json) {
    return DivisionItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      districts: json['districts'] != null
          ? (json['districts'] as List).map((e) => DistrictItem.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'districts': districts.map((e) => e.toJson()).toList(),
      };
}

class LocationHierarchyResponse {
  final List<DivisionItem> divisions;

  LocationHierarchyResponse({this.divisions = const []});

  factory LocationHierarchyResponse.fromJson(Map<String, dynamic> json) {
    return LocationHierarchyResponse(
      divisions: json['divisions'] != null
          ? (json['divisions'] as List).map((e) => DivisionItem.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'divisions': divisions.map((e) => e.toJson()).toList(),
      };
}

class ReverseGeocodeRequest {
  final double latitude;
  final double longitude;

  ReverseGeocodeRequest({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class ReverseGeocodeResponse {
  final String division;
  final String district;
  final String upazila;
  final String area;
  final double distanceKm;

  ReverseGeocodeResponse({
    required this.division,
    required this.district,
    required this.upazila,
    required this.area,
    this.distanceKm = 0.0,
  });

  factory ReverseGeocodeResponse.fromJson(Map<String, dynamic> json) {
    return ReverseGeocodeResponse(
      division: json['division'] ?? '',
      district: json['district'] ?? '',
      upazila: json['upazila'] ?? '',
      area: json['area'] ?? '',
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'division': division,
        'district': district,
        'upazila': upazila,
        'area': area,
        'distanceKm': distanceKm,
      };
}
