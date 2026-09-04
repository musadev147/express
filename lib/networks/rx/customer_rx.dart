import '../api/customer_api.dart';
import '../model/common_model.dart';
import '../model/product_model.dart';
import '../model/search_demand_model.dart';
import '../model/vendor_model.dart';
import '../rx_base.dart';

class GetVendorsRx extends RxResponseInt<ApiResponse<List<VendorMarketplaceItem>>> {
  GetVendorsRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<List<VendorMarketplaceItem>>> fetchVendors({
    String? area,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      ApiResponse<List<VendorMarketplaceItem>> response = await CustomerApi.getVendors(
        area: area,
        category: category,
        page: page,
        limit: limit,
      );
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class GetVendorProductsRx extends RxResponseInt<ApiResponse<List<ProductResponse>>> {
  GetVendorProductsRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<List<ProductResponse>>> fetchVendorProducts(int vendorId) async {
    try {
      ApiResponse<List<ProductResponse>> response = await CustomerApi.getVendorProducts(vendorId);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class SearchProductsRx extends RxResponseInt<ApiResponse<List<ProductResponse>>> {
  SearchProductsRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<List<ProductResponse>>> searchProducts({
    required String query,
    String? area,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      ApiResponse<List<ProductResponse>> response = await CustomerApi.searchProducts(
        query: query,
        area: area,
        category: category,
        page: page,
        limit: limit,
      );
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class CreateSearchDemandRx extends RxResponseInt<ApiResponse<SearchDemandCreateResponse>> {
  CreateSearchDemandRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<SearchDemandCreateResponse>> createSearchDemand(
    SearchDemandCreateRequest request,
  ) async {
    try {
      ApiResponse<SearchDemandCreateResponse> response =
          await CustomerApi.createSearchDemand(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}
