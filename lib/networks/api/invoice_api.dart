import 'package:dio/dio.dart';
import '../dio/dio.dart';
import '../endpoints.dart';
import '../model/common_model.dart';
import '../model/invoice_model.dart';

class InvoiceApi {
  static Future<ApiResponse<InvoiceResponse>> createInvoice(InvoiceCreateRequest request) async {
    Response response = await postHttp(Endpoints.createInvoice(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => InvoiceResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<List<InvoiceResponse>>> getInvoices() async {
    Response response = await getHttp(Endpoints.getInvoices());
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => InvoiceResponse.fromJson(e)).toList(),
    );
  }

  static Future<ApiResponse<InvoiceResponse>> getInvoiceById(String id) async {
    Response response = await getHttp(Endpoints.getInvoiceDetail(id));
    return ApiResponse.fromJson(
      response.data,
      (data) => InvoiceResponse.fromJson(data),
    );
  }
}
