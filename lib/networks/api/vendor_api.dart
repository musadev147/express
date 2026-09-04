import 'package:dio/dio.dart';
import '../dio/dio.dart';
import '../endpoints.dart';
import '../model/common_model.dart';
import '../model/product_model.dart';
import '../model/search_demand_model.dart';
import '../model/vendor_model.dart';

class VendorApi {
  static Future<ApiResponse<DashboardSummaryModel>> getDashboardSummary() async {
    Response response = await getHttp(Endpoints.vendorDashboardSummary());
    return ApiResponse.fromJson(
      response.data,
      (data) => DashboardSummaryModel.fromJson(data),
    );
  }

  static Future<ApiResponse<List<ProductResponse>>> getVendorCatalog() async {
    Response response = await getHttp(Endpoints.vendorProductsList());
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => ProductResponse.fromJson(e)).toList(),
    );
  }

  static Future<ApiResponse<ProductResponse>> addProduct(ProductCreateRequest request) async {
    Response response = await postHttp(Endpoints.vendorProductsList(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => ProductResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<ProductResponse>> updateProduct(
    int id,
    ProductUpdateRequest request,
  ) async {
    Response response = await putHttp(Endpoints.vendorProductDetail(id), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => ProductResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<ProductResponse>> toggleStock(int id, bool isAvailable) async {
    Response response = await patchHttp(
      Endpoints.vendorProductToggleStock(id),
      {'isAvailable': isAvailable},
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => ProductResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<dynamic>> deleteProduct(int id) async {
    Response response = await deleteHttp(Endpoints.vendorProductDetail(id));
    return ApiResponse.fromJson(
      response.data,
      (data) => data,
    );
  }

  static Future<ApiResponse<List<SearchDemandItem>>> getAreaSearchRequests() async {
    Response response = await getHttp(Endpoints.vendorSearchRequests());
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => SearchDemandItem.fromJson(e)).toList(),
    );
  }
}
