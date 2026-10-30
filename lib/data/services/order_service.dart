import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../../l10n/app_localizations.dart';
import '../models/address.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/order_service.dart';

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
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
    switch (facingDirection) {
      case 'north':
        return l10n.listingNorth;
      case 'south':
        return l10n.listingSouth;
      case 'east':
        return l10n.listingEast;
      case 'west':
        return l10n.listingWest;
      case 'north_east':
        return l10n.listingNorthEast;
      case 'north_west':
        return l10n.listingNorthWest;
      case 'south_east':
        return l10n.listingSouthEast;
      case 'south_west':
        return l10n.listingSouthWest;
      case 'facing_3_directions':
        return l10n.listingFacing3Directions;
      case 'facing_all_directions':
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

/// Service for managing buyer orders backed by V2 API.
class OrderService {
  final OrderServiceV2 _v2;

  OrderService({ApiClient? apiClient, OrderServiceV2? v2Service})
      : _v2 = v2Service ?? OrderServiceV2();

  Future<OrderResponse> getOrders({int page = 1, int perPage = 20}) async {
    try {
      final result = await _v2.fetch(limit: perPage);
      final orders = result.items.map((o) => o.toLegacyOrder()).toList();

      return OrderResponse(
        success: true,
        orders: orders,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: orders.length,
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
      final order = await _v2.fetchOrder(id);
      return OrderResponse(
        success: true,
        orders: [order.toLegacyOrder()],
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
      final random = Random();
      final suffix = random.nextInt(0x7fffffff).toRadixString(36);
      final subKey = data['submission_key']?.toString() ??
          'ord-${DateTime.now().microsecondsSinceEpoch}-$suffix';

      final payload = <String, dynamic>{
        'submission_key': subKey,
        'type': data['type'] ?? 'house',
        'listing_type': data['listing_type'] ?? 'sale',
        if (data['address_id'] != null) 'address_id': data['address_id'],
        'attributes': {
          if (data['holding_type'] != null)
            'holding_type': data['holding_type'],
          if (data['facing_direction'] != null)
            'facing_direction': data['facing_direction'],
        },
        'budget': {
          if (data['min_budget'] != null) 'min': data['min_budget'],
          if (data['max_budget'] != null) 'max': data['max_budget'],
        },
        'area': {
          if (data['min_area'] != null) 'min': data['min_area'],
          if (data['max_area'] != null) 'max': data['max_area'],
        },
        'description': data['description'] ?? '',
      };

      final created = await _v2.create(payload);

      return OrderResponse(
        success: true,
        message: 'Order created',
        orders: [created.toLegacyOrder()],
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return OrderResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<bool> cancelOrder(int id) async {
    try {
      await _v2.cancel(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
