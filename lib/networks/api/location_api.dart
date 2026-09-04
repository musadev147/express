import 'package:dio/dio.dart';
import '../dio/dio.dart';
import '../endpoints.dart';
import '../model/common_model.dart';
import '../model/location_model.dart';

class LocationApi {
  static Future<ApiResponse<LocationHierarchyResponse>> getLocationHierarchy() async {
    Response response = await getHttp(Endpoints.locationHierarchy());
    return ApiResponse.fromJson(
      response.data,
      (data) => LocationHierarchyResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<ReverseGeocodeResponse>> reverseGeocode(ReverseGeocodeRequest request) async {
    Response response = await postHttp(Endpoints.reverseGeocode(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => ReverseGeocodeResponse.fromJson(data),
    );
  }
}
