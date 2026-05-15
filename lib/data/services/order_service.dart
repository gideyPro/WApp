import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class Order {
  final int id;
  final String type;
  final String listingType;
  final String? holdingType;
  final String? facingDirection;
  final double? minBudget;
  final double? maxBudget;
  final double? minArea;
  final double? maxArea;
  final String description;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? kebele;

  Order({
    required this.id,
    required this.type,
    required this.listingType,
    this.holdingType,
    this.facingDirection,
    this.minBudget,
    this.maxBudget,
    this.minArea,
    this.maxArea,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.kebele,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'house',
      listingType: json['listing_type'] ?? 'buy',
      holdingType: json['holding_type'],
      facingDirection: json['facing_direction'],
      minBudget: _parseDouble(json['min_budget']),
      maxBudget: _parseDouble(json['max_budget']),
      minArea: _parseDouble(json['min_area']),
      maxArea: _parseDouble(json['max_area']),
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      kebele: json['kebele'],
    );
  }

  String get locationDisplay {
    if (kebele == null) return '';
    final parts = <String>[
      kebele!['region'] ?? '',
      kebele!['zone'] ?? '',
      kebele!['woreda'] ?? '',
      kebele!['kebele'] ?? '',
    ];
    return parts.where((p) => p.isNotEmpty).join(' > ');
  }

  bool get isActive => status == 'active';
  bool get isFulfilled => status == 'fulfilled';
  bool get isCancelled => status == 'cancelled';
}

class OrderResponse {
  final bool success;
  final String message;
  final List<Order> orders;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const OrderResponse({
    required this.success,
    this.message = '',
    this.orders = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

class OrderService {
  final ApiClient _apiClient;
  static const String _basePath = '${ApiConstants.apiBase}/orders';

  OrderService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<OrderResponse> getOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        _basePath,
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        List<Order> orders = [];
        int currentPage = page;
        int totalPages = 1;
        int total = 0;

        if (data is Map) {
          if (data['data'] is List) {
            orders = (data['data'] as List)
                .map((j) => Order.fromJson(j as Map<String, dynamic>))
                .toList();
          }
          currentPage = _safeInt(data['current_page']);
          totalPages = _safeInt(data['last_page']);
          total = _safeInt(data['total']);
        } else if (data is List) {
          orders = data
              .map((j) => Order.fromJson(j as Map<String, dynamic>))
              .toList();
          total = orders.length;
        }

        return OrderResponse(
          success: true,
          orders: orders,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return OrderResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to fetch orders',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<OrderResponse> getOrder(int id) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return OrderResponse(
          success: true,
          orders: [Order.fromJson(data is Map ? data as Map<String, dynamic> : {})],
        );
      }
      return OrderResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to fetch order',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<OrderResponse> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(_basePath, data: data);
      if (response.statusCode == 201) {
        final orderData = response.data['data'] ?? response.data;
        return OrderResponse(
          success: true,
          message: response.data['message'] ?? 'Order created',
          orders: [Order.fromJson(orderData is Map ? orderData as Map<String, dynamic> : {})],
        );
      }
      return OrderResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to create order',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<OrderResponse> cancelOrder(int id) async {
    try {
      final response = await _apiClient.dio.delete('$_basePath/$id');
      if (response.statusCode == 200) {
        return OrderResponse(
          success: true,
          message: response.data['message'] ?? 'Order cancelled',
        );
      }
      return OrderResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to cancel order',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<OrderResponse> updateOrder(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('$_basePath/$id', data: data);
      if (response.statusCode == 200) {
        return OrderResponse(
          success: true,
          message: response.data['message'] ?? 'Order updated',
        );
      }
      return OrderResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to update order',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  // Allow passing a custom Dio instance or base URL override for tests
  factory OrderService.withClient(ApiClient client) => OrderService(apiClient: client);
}
