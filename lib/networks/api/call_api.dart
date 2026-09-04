import 'package:dio/dio.dart';
import '../dio/dio.dart';
import '../endpoints.dart';
import '../model/call_model.dart';
import '../model/common_model.dart';

class CallApi {
  static Future<ApiResponse<CallInitiateResponse>> initiateCall(
    CallInitiateRequest request,
  ) async {
    Response response = await postHttp(Endpoints.callsInitiate(), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => CallInitiateResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<dynamic>> endCall(
    String callId,
    CallEndRequest request,
  ) async {
    Response response = await postHttp(Endpoints.callsEnd(callId), request.toJson());
    return ApiResponse.fromJson(
      response.data,
      (data) => data,
    );
  }
}
