// ignore_for_file: constant_identifier_names

String? url = 'http://localhost:8000/api/v1';

final class NetworkConstants {
  NetworkConstants._();
  static const ACCEPT = "Accept";
  static const APP_KEY = "App-Key";
  static const ACCEPT_LANGUAGE = "Accept-Language";
  static const ACCEPT_LANGUAGE_VALUE = "en";
  static const APP_KEY_VALUE = String.fromEnvironment("APP_KEY_VALUE");
  static const ACCEPT_TYPE = "application/json";
  static const AUTHORIZATION = "Authorization";
  static const CONTENT_TYPE = "content-Type";
}

final class Endpoints {
  Endpoints._();

  // Authentication & Profile Endpoints
  static String login() => "/auth/login";
  static String registerCustomer() => "/auth/register-customer";
  static String registerVendor() => "/auth/register-vendor";
  static String getMe() => "/auth/me";
  static String updateProfile() => "/auth/profile";

  // Location & Geofencing Endpoints
  static String locationHierarchy() => "/locations/hierarchy";
  static String reverseGeocode() => "/locations/reverse-geocode";

  // Customer Marketplace & Discovery Endpoints
  static String customerVendors({String? area, String? category, int page = 1, int limit = 20}) {
    List<String> params = [];
    if (area != null && area.isNotEmpty) params.add("area=${Uri.encodeComponent(area)}");
    if (category != null && category.isNotEmpty) params.add("category=${Uri.encodeComponent(category)}");
    params.add("page=$page");
    params.add("limit=$limit");
    return "/customer/vendors?${params.join('&')}";
  }

  static String vendorProducts(int vendorId) => "/customer/vendors/$vendorId/products";

  static String searchProducts({required String query, String? area, String? category, int page = 1, int limit = 20}) {
    List<String> params = ["query=${Uri.encodeComponent(query)}"];
    if (area != null && area.isNotEmpty) params.add("area=${Uri.encodeComponent(area)}");
    if (category != null && category.isNotEmpty) params.add("category=${Uri.encodeComponent(category)}");
    params.add("page=$page");
    params.add("limit=$limit");
    return "/customer/products/search?${params.join('&')}";
  }

  static String customerSearchRequests() => "/customer/search-requests";

  // Vendor Shop & Inventory Endpoints
  static String vendorDashboardSummary() => "/vendor/dashboard-summary";
  static String vendorProductsList() => "/vendor/products";
  static String vendorProductDetail(int id) => "/vendor/products/$id";
  static String vendorProductToggleStock(int id) => "/vendor/products/$id/toggle-stock";
  static String vendorSearchRequests() => "/vendor/search-requests";

  // Invoices & Billing Endpoints
  static String createInvoice() => "/invoices/create";
  static String getInvoices() => "/invoices";
  static String getInvoiceDetail(String id) => "/invoices/$id";
  static String getInvoicePdf(String id) => "/invoices/$id/pdf";

  // Real-time Voice Call & CTI Endpoints
  static String callsInitiate() => "/calls/initiate";
  static String callsEnd(String callId) => "/calls/$callId/end";

  // Web CRM Administration Endpoints
  static String crmAnalyticsOverview() => "/crm/analytics/overview";
  static String crmDemandHeatmap() => "/crm/analytics/demand-heatmap";
  static String crmCategories() => "/crm/categories";
  static String crmCategoryCommission(int id) => "/crm/categories/$id/commission";
  static String crmFinanceCommissionReport() => "/crm/finance/category-commission-report";
  static String crmVendors() => "/crm/vendors";
  static String crmVendor360(int id) => "/crm/vendors/$id";
  static String crmVendorVerifyKyc(int id) => "/crm/vendors/$id/verify-kyc";
  static String crmVendorStatus(int id) => "/crm/vendors/$id/status";
  static String crmCustomers() => "/crm/customers";
  static String crmCustomer360(int id) => "/crm/customers/$id";
  static String crmTickets() => "/crm/tickets";
  static String crmTicketReply(int id) => "/crm/tickets/$id/reply";
  static String crmTicketStatus(int id) => "/crm/tickets/$id/status";
  static String crmPayouts() => "/crm/payouts";
  static String crmPayoutApprove(int id) => "/crm/payouts/$id/approve";
  static String crmDivision() => "/crm/locations/division";
  static String crmDistrict() => "/crm/locations/district";
  static String crmUpazila() => "/crm/locations/upazila";
  static String crmArea() => "/crm/locations/area";
}
