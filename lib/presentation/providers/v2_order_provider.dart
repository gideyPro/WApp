import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/buyer_order.dart';
import '../../data/services/v2/order_service.dart';
import 'v2_providers.dart';

/// Cursor-paginated buyer requests for the v2 orders screen.
final ordersV2Provider =
    StateNotifierProvider<OrdersV2Notifier, OrdersV2State>((ref) {
  return OrdersV2Notifier(ref.watch(orderV2ServiceProvider));
});

class OrdersV2Notifier extends StateNotifier<OrdersV2State> {
  final OrderServiceV2 _service;

  OrdersV2Notifier(this._service) : super(const OrdersV2State.initial());

  Future<void> loadOrders({BuyerOrderStatus? status}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _service.fetch(status: status);
      state = OrdersV2State.loaded(
        orders: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load your orders',
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;

    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _service.fetch(cursor: cursor);
      state = state.copyWith(
        orders: [...state.orders, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more orders',
      );
    }
  }

  /// Cancel an active request and replace the row with the server state.
  /// Returns the updated order, or null when the call failed.
  Future<BuyerOrder?> cancel(int orderId) async {
    try {
      final updated = await _service.cancel(orderId);
      state = state.copyWith(
        orders: state.orders
            .map((order) => order.id == orderId ? updated : order)
            .toList(),
      );
      return updated;
    } on ApiV2Exception catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return null;
    } catch (_) {
      return null;
    }
  }
}

class OrdersV2State {
  final bool isLoading;
  final bool isLoadingMore;
  final List<BuyerOrder> orders;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  const OrdersV2State({
    required this.isLoading,
    this.isLoadingMore = false,
    this.orders = const [],
    this.nextCursor,
    this.hasMore = false,
    this.errorMessage,
  });

  const OrdersV2State.initial()
      : isLoading = true,
        isLoadingMore = false,
        orders = const [],
        nextCursor = null,
        hasMore = false,
        errorMessage = null;

  const OrdersV2State.loaded({
    required this.orders,
    this.nextCursor,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  /// Cursor pages load incrementally, so this is the number of rows fetched
  /// so far rather than a server-side total.
  int get total => orders.length;

  OrdersV2State copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<BuyerOrder>? orders,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
  }) {
    return OrdersV2State(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      orders: orders ?? this.orders,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}
