import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/subscription_service.dart';
import 'payment_providers.dart';

class PendingTransaction {
  final int planId;
  final String? txRef;
  final DateTime createdAt;
  final String type;

  const PendingTransaction({
    required this.planId,
    this.txRef,
    required this.createdAt,
    this.type = 'subscription',
  });
}

class TransactionTracker extends StateNotifier<List<PendingTransaction>> {
  final SubscriptionServiceApi _subscriptionService;

  TransactionTracker(this._subscriptionService) : super([]);

  void track(int planId, {String? txRef}) {
    state = [
      ...state,
      PendingTransaction(
        planId: planId,
        txRef: txRef,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void resolve(int planId, {String? txRef}) {
    state = state.where((t) {
      if (txRef != null && t.txRef == txRef) return false;
      if (t.planId == planId && txRef == null) return false;
      return true;
    }).toList();
  }

  Future<String?> checkLatestStatus() async {
    if (state.isEmpty) return null;
    final latest = state.last;
    if (latest.txRef != null) {
      return _subscriptionService.checkPaymentStatus(latest.txRef!);
    }
    return null;
  }

  void clear() => state = [];
}

final transactionTrackerProvider = StateNotifierProvider<TransactionTracker, List<PendingTransaction>>((ref) {
  return TransactionTracker(ref.watch(subscriptionServiceProvider));
});
