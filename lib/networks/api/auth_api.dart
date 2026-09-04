import 'package:dio/dio.dart';
import '../dio/dio.dart';
import '../endpoints.dart';
import '../model/auth_model.dart';
import '../model/common_model.dart';

class AuthApi {
  static Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    Response response = await postHttp(Endpoints.login(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => AuthResponseData.fromJson(data),
    );
  }

  static Future<ApiResponse<AuthResponseData>> registerCustomer(RegisterCustomerRequest request) async {
    Response response = await postHttp(Endpoints.registerCustomer(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => AuthResponseData.fromJson(data),
    );
  }

  static Future<ApiResponse<AuthResponseData>> registerVendor(RegisterVendorRequest request) async {
    Response response = await postHttp(Endpoints.registerVendor(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => AuthResponseData.fromJson(data),
    );
  }

  static Future<ApiResponse<UserProfileResponse>> getMe() async {
    Response response = await getHttp(Endpoints.getMe());
    return ApiResponse.fromJson(
      response.data,
      (data) => UserProfileResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<UserProfileResponse>> updateProfile(ProfileUpdateRequest request) async {
    Response response = await putHttp(Endpoints.updateProfile(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => UserProfileResponse.fromJson(data),
    );
  }
}
