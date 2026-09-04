import '../api/call_api.dart';
import '../model/call_model.dart';
import '../model/common_model.dart';
import '../rx_base.dart';

class InitiateCallRx extends RxResponseInt<ApiResponse<CallInitiateResponse>> {
  InitiateCallRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<CallInitiateResponse>> initiateCall(CallInitiateRequest request) async {
    try {
      ApiResponse<CallInitiateResponse> response = await CallApi.initiateCall(request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}

class EndCallRx extends RxResponseInt<ApiResponse<dynamic>> {
  EndCallRx({required super.empty, required super.dataFetcher});

  Future<ApiResponse<dynamic>> endCall(String callId, CallEndRequest request) async {
    try {
      ApiResponse<dynamic> response = await CallApi.endCall(callId, request);
      return handleSuccessWithReturn(response);
    } catch (e) {
      return handleErrorWithReturn(e);
    }
  }
}
