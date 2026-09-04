class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final Meta? meta;
  final List<ErrorDetail>? errors;

  ApiResponse({
    this.success = true,
    this.statusCode = 200,
    this.message = "Operation executed successfully",
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      errors: json['errors'] != null
          ? (json['errors'] as List).map((e) => ErrorDetail.fromJson(e)).toList()
          : null,
    );
  }
}

class Meta {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  Meta({this.page, this.limit, this.total, this.totalPages});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      };
}

class ErrorDetail {
  final String? field;
  final String message;

  ErrorDetail({this.field, required this.message});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      field: json['field'],
      message: json['message'] ?? 'An error occurred',
    );
  }

  Map<String, dynamic> toJson() => {
        'field': field,
        'message': message,
      };
}
