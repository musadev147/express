import 'package:dio/dio.dart';
import '../dio/dio.dart';
import '../endpoints.dart';
import '../model/common_model.dart';
import '../model/product_model.dart';
import '../model/search_demand_model.dart';
import '../model/vendor_model.dart';

class CustomerApi {
  static Future<ApiResponse<List<VendorMarketplaceItem>>> getVendors({
    String? area,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    Response response = await getHttp(
      Endpoints.customerVendors(area: area, category: category, page: page, limit: limit),
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => VendorMarketplaceItem.fromJson(e)).toList(),
    );
  }

  static Future<ApiResponse<List<ProductResponse>>> getVendorProducts(int vendorId) async {
    Response response = await getHttp(Endpoints.vendorProducts(vendorId));
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => ProductResponse.fromJson(e)).toList(),
    );
  }

  static Future<ApiResponse<List<ProductResponse>>> searchProducts({
    required String query,
    String? area,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    Response response = await getHttp(
      Endpoints.searchProducts(query: query, area: area, category: category, page: page, limit: limit),
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => ProductResponse.fromJson(e)).toList(),
    );
  }

  static Future<ApiResponse<SearchDemandCreateResponse>> createSearchDemand(
    SearchDemandCreateRequest request,
  ) async {
    Response response = await postHttp(Endpoints.customerSearchRequests(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => SearchDemandCreateResponse.fromJson(data),
    );
  }
}
