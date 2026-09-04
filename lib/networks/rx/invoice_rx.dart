import '../api/invoice_api.dart';
import '../model/common_model.dart';
import '../model/invoice_model.dart';
import '../rx_base.dart';

class CreateInvoiceRx extends RxResponseInt<ApiResponse<InvoiceResponse>> {
  CreateInvoiceRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<InvoiceResponse>> createInvoice(InvoiceCreateRequest request) async {
    try {
      ApiResponse<InvoiceResponse> response = await InvoiceApi.createInvoice(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class GetInvoicesRx extends RxResponseInt<ApiResponse<List<InvoiceResponse>>> {
  GetInvoicesRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<List<InvoiceResponse>>> fetchInvoices() async {
    try {
      ApiResponse<List<InvoiceResponse>> response = await InvoiceApi.getInvoices();
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class GetInvoiceByIdRx extends RxResponseInt<ApiResponse<InvoiceResponse>> {
  GetInvoiceByIdRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<InvoiceResponse>> fetchInvoiceById(String id) async {
    try {
      ApiResponse<InvoiceResponse> response = await InvoiceApi.getInvoiceById(id);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}
