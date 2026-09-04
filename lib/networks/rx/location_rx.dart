import '../api/location_api.dart';
import '../model/common_model.dart';
import '../model/location_model.dart';
import '../rx_base.dart';

class LocationHierarchyRx extends RxResponseInt<ApiResponse<LocationHierarchyResponse>> {
  LocationHierarchyRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<LocationHierarchyResponse>> fetchHierarchy() async {
    try {
      ApiResponse<LocationHierarchyResponse> response = await LocationApi.getLocationHierarchy();
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class ReverseGeocodeRx extends RxResponseInt<ApiResponse<ReverseGeocodeResponse>> {
  ReverseGeocodeRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<ReverseGeocodeResponse>> reverseGeocode(ReverseGeocodeRequest request) async {
    try {
      ApiResponse<ReverseGeocodeResponse> response = await LocationApi.reverseGeocode(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}
