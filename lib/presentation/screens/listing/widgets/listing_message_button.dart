import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/message_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';

/// Starts an in-app conversation for a listing.
///
/// Used on vehicle and job details where the WaveMart options section exposes
/// only the message action. Property details keep their full icon row.
class ListingMessageButton extends ConsumerStatefulWidget {
  final int listingId;

  const ListingMessageButton({super.key, required this.listingId});

  @override
  ConsumerState<ListingMessageButton> createState() =>
      _ListingMessageButtonState();
}

class _ListingMessageButtonState extends ConsumerState<ListingMessageButton> {
  bool _isStarting = false;

  Future<void> _startChat() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }

    if (_isStarting) return;
    setState(() => _isStarting = true);

    try {
      final l10n = AppLocalizations.of(context);
      final result = await MessageService().startConversationFromListing(
        listingId: widget.listingId,
      );

      if (!mounted) return;

      if (result.success && result.conversation != null) {
        context.push(
          '/chat/${result.conversation!.id}',
          extra: result.conversation,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty ? result.message : l10n.commonError,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isStarting ? null : _startChat,
        icon: _isStarting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.message_outlined, size: 18),
        label: Text(l10n.listingMessageSeller),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
