class LoginRequest {
  final String phone;
  final String password;
  final String? role;

  LoginRequest({
    required this.phone,
    required this.password,
    this.role,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
        if (role != null) 'role': role,
      };
}

class RegisterCustomerRequest {
  final String name;
  final String phone;
  final String password;
  final String division;
  final String district;
  final String upazila;
  final String area;

  RegisterCustomerRequest({
    required this.name,
    required this.phone,
    required this.password,
    this.division = 'Dhaka',
    this.district = 'Gazipur',
    this.upazila = 'Kaliganj',
    this.area = 'Kaliganj Bazar',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
        'division': division,
        'district': district,
        'upazila': upazila,
        'area': area,
      };
}

class RegisterVendorRequest {
  final String name;
  final String shopName;
  final String phone;
  final String? email;
  final String password;
  final String category;
  final String division;
  final String district;
  final String upazila;
  final String area;
  final String address;

  RegisterVendorRequest({
    required this.name,
    required this.shopName,
    required this.phone,
    this.email,
    required this.password,
    this.category = 'Electronics',
    this.division = 'Dhaka',
    this.district = 'Gazipur',
    this.upazila = 'Kaliganj',
    this.area = 'Kaliganj Bazar',
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'shopName': shopName,
        'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        'category': category,
        'division': division,
        'district': district,
        'upazila': upazila,
        'area': area,
        'address': address,
      };
}

class UserProfileResponse {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String status;
  final String? avatarUrl;
  final String? shopName;
  final String? category;
  final String? division;
  final String? district;
  final String? upazila;
  final String? area;
  final String? address;
  final double? walletBalance;
  final bool? isVerified;

  UserProfileResponse({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.shopName,
    this.category,
    this.division,
    this.district,
    this.upazila,
    this.area,
    this.address,
    this.walletBalance,
    this.isVerified,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'customer',
      status: json['status'] ?? 'active',
      avatarUrl: json['avatarUrl'],
      shopName: json['shopName'],
      category: json['category'],
      division: json['division'],
      district: json['district'],
      upazila: json['upazila'],
      area: json['area'],
      address: json['address'],
      walletBalance: json['walletBalance'] != null ? (json['walletBalance'] as num).toDouble() : null,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'status': status,
        'avatarUrl': avatarUrl,
        'shopName': shopName,
        'category': category,
        'division': division,
        'district': district,
        'upazila': upazila,
        'area': area,
        'address': address,
        'walletBalance': walletBalance,
        'isVerified': isVerified,
      };
}

class AuthResponseData {
  final String token;
  final String refreshToken;
  final UserProfileResponse user;

  AuthResponseData({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: json['user'] != null
          ? UserProfileResponse.fromJson(json['user'])
          : UserProfileResponse(id: 0, name: '', phone: '', role: 'customer', status: 'active'),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };
}

class ProfileUpdateRequest {
  final String? name;
  final String? shopName;
  final String? email;
  final String? address;
  final String? avatarUrl;
  final String? fcmToken;

  ProfileUpdateRequest({
    this.name,
    this.shopName,
    this.email,
    this.address,
    this.avatarUrl,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (shopName != null) 'shopName': shopName,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}
