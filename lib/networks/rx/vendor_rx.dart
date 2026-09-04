import '../api/vendor_api.dart';
import '../model/common_model.dart';
import '../model/product_model.dart';
import '../model/search_demand_model.dart';
import '../model/vendor_model.dart';
import '../rx_base.dart';

class VendorDashboardSummaryRx extends RxResponseInt<ApiResponse<DashboardSummaryModel>> {
  VendorDashboardSummaryRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<DashboardSummaryModel>> fetchDashboardSummary() async {
    try {
      ApiResponse<DashboardSummaryModel> response = await VendorApi.getDashboardSummary();
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class VendorProductsRx extends RxResponseInt<ApiResponse<List<ProductResponse>>> {
  VendorProductsRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<List<ProductResponse>>> fetchCatalog() async {
    try {
      ApiResponse<List<ProductResponse>> response = await VendorApi.getVendorCatalog();
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class AddProductRx extends RxResponseInt<ApiResponse<ProductResponse>> {
  AddProductRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<ProductResponse>> addProduct(ProductCreateRequest request) async {
    try {
      ApiResponse<ProductResponse> response = await VendorApi.addProduct(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class UpdateProductRx extends RxResponseInt<ApiResponse<ProductResponse>> {
  UpdateProductRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<ProductResponse>> updateProduct(
    int id,
    ProductUpdateRequest request,
  ) async {
    try {
      ApiResponse<ProductResponse> response = await VendorApi.updateProduct(id, request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class ToggleStockRx extends RxResponseInt<ApiResponse<ProductResponse>> {
  ToggleStockRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<ProductResponse>> toggleStock(int id, bool isAvailable) async {
    try {
      ApiResponse<ProductResponse> response = await VendorApi.toggleStock(id, isAvailable);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class DeleteProductRx extends RxResponseInt<ApiResponse<dynamic>> {
  DeleteProductRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<dynamic>> deleteProduct(int id) async {
    try {
      ApiResponse<dynamic> response = await VendorApi.deleteProduct(id);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class VendorSearchRequestsRx extends RxResponseInt<ApiResponse<List<SearchDemandItem>>> {
  VendorSearchRequestsRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<List<SearchDemandItem>>> fetchAreaSearchRequests() async {
    try {
      ApiResponse<List<SearchDemandItem>> response = await VendorApi.getAreaSearchRequests();
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}
