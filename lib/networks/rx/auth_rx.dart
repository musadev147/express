import '../api/auth_api.dart';
import '../model/auth_model.dart';
import '../model/common_model.dart';
import '../rx_base.dart';

class LoginRx extends RxResponseInt<ApiResponse<AuthResponseData>> {
  LoginRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    try {
      ApiResponse<AuthResponseData> response = await AuthApi.login(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class RegisterCustomerRx extends RxResponseInt<ApiResponse<AuthResponseData>> {
  RegisterCustomerRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<AuthResponseData>> registerCustomer(RegisterCustomerRequest request) async {
    try {
      ApiResponse<AuthResponseData> response = await AuthApi.registerCustomer(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class RegisterVendorRx extends RxResponseInt<ApiResponse<AuthResponseData>> {
  RegisterVendorRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<AuthResponseData>> registerVendor(RegisterVendorRequest request) async {
    try {
      ApiResponse<AuthResponseData> response = await AuthApi.registerVendor(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class GetMeRx extends RxResponseInt<ApiResponse<UserProfileResponse>> {
  GetMeRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<UserProfileResponse>> getMe() async {
    try {
      ApiResponse<UserProfileResponse> response = await AuthApi.getMe();
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class UpdateProfileRx extends RxResponseInt<ApiResponse<UserProfileResponse>> {
  UpdateProfileRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<UserProfileResponse>> updateProfile(ProfileUpdateRequest request) async {
    try {
      ApiResponse<UserProfileResponse> response = await AuthApi.updateProfile(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}
