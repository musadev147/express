import 'package:rxdart/rxdart.dart';
import 'model/auth_model.dart';
import 'model/call_model.dart';
import 'model/common_model.dart';
import 'model/invoice_model.dart';
import 'model/location_model.dart';
import 'model/product_model.dart';
import 'model/search_demand_model.dart';
import 'model/vendor_model.dart';
import 'rx/auth_rx.dart';
import 'rx/call_rx.dart';
import 'rx/customer_rx.dart';
import 'rx/invoice_rx.dart';
import 'rx/location_rx.dart';
import 'rx/vendor_rx.dart';

// Auth Rx
LoginRx loginRx = LoginRx(
  empty: ApiResponse<AuthResponseData>(),
  dataFetcher: BehaviorSubject<ApiResponse<AuthResponseData>>(),
);

RegisterCustomerRx registerCustomerRx = RegisterCustomerRx(
  empty: ApiResponse<AuthResponseData>(),
  dataFetcher: BehaviorSubject<ApiResponse<AuthResponseData>>(),
);

RegisterVendorRx registerVendorRx = RegisterVendorRx(
  empty: ApiResponse<AuthResponseData>(),
  dataFetcher: BehaviorSubject<ApiResponse<AuthResponseData>>(),
);

GetMeRx getMeRx = GetMeRx(
  empty: ApiResponse<UserProfileResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<UserProfileResponse>>(),
);

UpdateProfileRx updateProfileRx = UpdateProfileRx(
  empty: ApiResponse<UserProfileResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<UserProfileResponse>>(),
);

// Location Rx
LocationHierarchyRx locationHierarchyRx = LocationHierarchyRx(
  empty: ApiResponse<LocationHierarchyResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<LocationHierarchyResponse>>(),
);

ReverseGeocodeRx reverseGeocodeRx = ReverseGeocodeRx(
  empty: ApiResponse<ReverseGeocodeResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<ReverseGeocodeResponse>>(),
);

// Customer Rx
GetVendorsRx getVendorsRx = GetVendorsRx(
  empty: ApiResponse<List<VendorMarketplaceItem>>(),
  dataFetcher: BehaviorSubject<ApiResponse<List<VendorMarketplaceItem>>>(),
);

GetVendorProductsRx getVendorProductsRx = GetVendorProductsRx(
  empty: ApiResponse<List<ProductResponse>>(),
  dataFetcher: BehaviorSubject<ApiResponse<List<ProductResponse>>>(),
);

SearchProductsRx searchProductsRx = SearchProductsRx(
  empty: ApiResponse<List<ProductResponse>>(),
  dataFetcher: BehaviorSubject<ApiResponse<List<ProductResponse>>>(),
);

CreateSearchDemandRx createSearchDemandRx = CreateSearchDemandRx(
  empty: ApiResponse<SearchDemandCreateResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<SearchDemandCreateResponse>>(),
);

// Vendor Rx
VendorDashboardSummaryRx vendorDashboardSummaryRx = VendorDashboardSummaryRx(
  empty: ApiResponse<DashboardSummaryModel>(),
  dataFetcher: BehaviorSubject<ApiResponse<DashboardSummaryModel>>(),
);

VendorProductsRx vendorProductsRx = VendorProductsRx(
  empty: ApiResponse<List<ProductResponse>>(),
  dataFetcher: BehaviorSubject<ApiResponse<List<ProductResponse>>>(),
);

AddProductRx addProductRx = AddProductRx(
  empty: ApiResponse<ProductResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<ProductResponse>>(),
);

UpdateProductRx updateProductRx = UpdateProductRx(
  empty: ApiResponse<ProductResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<ProductResponse>>(),
);

ToggleStockRx toggleStockRx = ToggleStockRx(
  empty: ApiResponse<ProductResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<ProductResponse>>(),
);

DeleteProductRx deleteProductRx = DeleteProductRx(
  empty: ApiResponse<dynamic>(),
  dataFetcher: BehaviorSubject<ApiResponse<dynamic>>(),
);

VendorSearchRequestsRx vendorSearchRequestsRx = VendorSearchRequestsRx(
  empty: ApiResponse<List<SearchDemandItem>>(),
  dataFetcher: BehaviorSubject<ApiResponse<List<SearchDemandItem>>>(),
);

// Invoices Rx
CreateInvoiceRx createInvoiceRx = CreateInvoiceRx(
  empty: ApiResponse<InvoiceResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<InvoiceResponse>>(),
);

GetInvoicesRx getInvoicesRx = GetInvoicesRx(
  empty: ApiResponse<List<InvoiceResponse>>(),
  dataFetcher: BehaviorSubject<ApiResponse<List<InvoiceResponse>>>(),
);

GetInvoiceByIdRx getInvoiceByIdRx = GetInvoiceByIdRx(
  empty: ApiResponse<InvoiceResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<InvoiceResponse>>(),
);

// Call Rx
InitiateCallRx initiateCallRx = InitiateCallRx(
  empty: ApiResponse<CallInitiateResponse>(),
  dataFetcher: BehaviorSubject<ApiResponse<CallInitiateResponse>>(),
);

EndCallRx endCallRx = EndCallRx(
  empty: ApiResponse<dynamic>(),
  dataFetcher: BehaviorSubject<ApiResponse<dynamic>>(),
);
