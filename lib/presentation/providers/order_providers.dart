import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/order_service.dart';

/// Order Provider
final orderServiceProvider =
    Provider<OrderService>((ref) => OrderService());
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.watch(orderServiceProvider));
});

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderService _orderService;
  OrdersNotifier(this._orderService)
      : super(const OrdersState.initial());

  Future<void> loadOrders({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _orderService.getOrders(page: page);
    if (response.success) {
      state = OrdersState.loaded(
        orders: response.orders,
        total: response.total ?? 0,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    final response = await _orderService.cancelOrder(orderId);
    if (response.success) {
      await loadOrders();
    }
    return response.success;
  }
}

class OrdersState {
  final bool isLoading;
  final List<Order> orders;
  final int total;
  final String? errorMessage;
  const OrdersState(
      {required this.isLoading,
      this.orders = const [],
      this.total = 0,
      this.errorMessage});
  const OrdersState.initial()
      : isLoading = true,
        orders = const [],
        total = 0,
        errorMessage = null;
  const OrdersState.loaded({required this.orders, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  OrdersState copyWith(
      {bool? isLoading,
      List<Order>? orders,
      int? total,
      String? errorMessage}) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }
}
