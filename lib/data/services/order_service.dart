import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../../l10n/app_localizations.dart';
import '../models/address.dart';

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
  final Address? address;

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
    this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'house',
      listingType: json['listing_type'] ?? 'sale',
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
      address: json['address'] is Map
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isFulfilled => status == 'fulfilled';
  bool get isCancelled => status == 'cancelled';

  String getLocalizedHoldingType(BuildContext context) {
    if (holdingType == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (holdingType) {
      case 'Free Hold':
        return l10n.listingFreeHold;
      case 'Lease Hold':
        return l10n.listingLeaseHold;
      case 'Cooperative':
        return l10n.listingCooperative;
      default:
        return holdingType!;
    }
  }

  String getLocalizedFacingDirection(BuildContext context) {
    if (facingDirection == null) return '';
    final l10n = AppLocalizations.of(context);
    final normalized = facingDirection!
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    switch (normalized) {
      case 'North':
        return l10n.listingNorth;
      case 'South':
        return l10n.listingSouth;
      case 'East':
        return l10n.listingEast;
      case 'West':
        return l10n.listingWest;
      case 'North East':
        return l10n.listingNorthEast;
      case 'North West':
        return l10n.listingNorthWest;
      case 'South East':
        return l10n.listingSouthEast;
      case 'South West':
        return l10n.listingSouthWest;
      case 'Facing 3 Directions':
        return l10n.listingFacing3Directions;
      case 'Facing All Directions':
        return l10n.listingFacingAllDirections;
      default:
        return facingDirection!;
    }
  }
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
        final data = response.data;
        final dataMap = (data is Map) ? data : {};
        
        final dataList = _extractList(data);
        final orders = dataList
            .whereType<Map>()
            .map((j) => Order.fromJson(j as Map<String, dynamic>))
            .toList();

        // Safely parse pagination fields
        final paginationData = dataMap['data'] is Map ? dataMap['data'] : dataMap;
        int currentPage = _safeInt(paginationData['current_page']) > 0 
            ? _safeInt(paginationData['current_page']) 
            : page;
        int totalPages = _safeInt(paginationData['last_page']) > 0 
            ? _safeInt(paginationData['last_page']) 
            : 1;
        int total = _safeInt(paginationData['total']);

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
        message: _extractMessage(response.data, 'Failed to fetch orders'),
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
        final data = response.data;
        final orderData = (data is Map) ? (data['data'] ?? data) : {};
        
        return OrderResponse(
          success: true,
          orders: [Order.fromJson(orderData is Map ? orderData as Map<String, dynamic> : {})],
        );
      }
      return OrderResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch order'),
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
        final responseData = response.data;
        final orderData = (responseData is Map) ? (responseData['data'] ?? responseData) : {};
        
        return OrderResponse(
          success: true,
          message: _extractMessage(responseData, 'Order created'),
          orders: [Order.fromJson(orderData is Map ? orderData as Map<String, dynamic> : {})],
        );
      }
      return OrderResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to create order'),
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
          message: _extractMessage(response.data, 'Order cancelled'),
        );
      }
      return OrderResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to cancel order'),
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
          message: _extractMessage(response.data, 'Order updated'),
        );
      }
      return OrderResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to update order'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Helper to extract list from dynamic response
  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'] ?? raw['orders'];
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
    }
    return [];
  }

  /// Helper to extract message from dynamic response
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map && raw['message'] != null) {
      return raw['message'].toString();
    }
    return defaultMessage;
  }

  // Allow passing a custom Dio instance or base URL override for tests
  factory OrderService.withClient(ApiClient client) => OrderService(apiClient: client);
}
