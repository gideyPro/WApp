import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/v2/payment_service.dart';
import 'v2_providers.dart';

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
  final PaymentServiceV2 _paymentService;

  TransactionTracker(this._paymentService) : super([]);

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
    state = state.where((tx) {
      if (txRef != null && tx.txRef != null) {
        return tx.txRef != txRef;
      }
      return tx.planId != planId;
    }).toList();
  }

  Future<String?> checkLatestStatus() async {
    if (state.isEmpty) return null;
    final latest = state.last;
    if (latest.txRef != null) {
      try {
        final payment = await _paymentService.fetchOne(latest.txRef!);
        return payment.status.wireValue;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void clear() => state = [];
}

final transactionTrackerProvider =
    StateNotifierProvider<TransactionTracker, List<PendingTransaction>>((ref) {
  return TransactionTracker(ref.watch(paymentV2ServiceProvider));
});
