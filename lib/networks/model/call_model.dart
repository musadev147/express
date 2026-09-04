class CallInitiateRequest {
  final String receiverPhone;
  final String? receiverName;
  final String? receiverShopName;
  final String? receiverArea;
  final String? productName;

  CallInitiateRequest({
    required this.receiverPhone,
    this.receiverName,
    this.receiverShopName,
    this.receiverArea,
    this.productName,
  });

  Map<String, dynamic> toJson() => {
        'receiverPhone': receiverPhone,
        if (receiverName != null) 'receiverName': receiverName,
        if (receiverShopName != null) 'receiverShopName': receiverShopName,
        if (receiverArea != null) 'receiverArea': receiverArea,
        if (productName != null) 'productName': productName,
      };
}

class CallInitiateResponse {
  final String callId;
  final String status;
  final String callerPhone;
  final String receiverPhone;
  final String? productName;

  CallInitiateResponse({
    required this.callId,
    required this.status,
    required this.callerPhone,
    required this.receiverPhone,
    this.productName,
  });

  factory CallInitiateResponse.fromJson(Map<String, dynamic> json) {
    return CallInitiateResponse(
      callId: json['callId'] ?? '',
      status: json['status'] ?? 'dialing',
      callerPhone: json['callerPhone'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      productName: json['productName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'callId': callId,
        'status': status,
        'callerPhone': callerPhone,
        'receiverPhone': receiverPhone,
        'productName': productName,
      };
}

class CallEndRequest {
  final int durationSeconds;
  final String status;
  final String? invoiceId;

  CallEndRequest({
    this.durationSeconds = 0,
    this.status = 'completed',
    this.invoiceId,
  });

  Map<String, dynamic> toJson() => {
        'durationSeconds': durationSeconds,
        'status': status,
        if (invoiceId != null) 'invoiceId': invoiceId,
      };
}
