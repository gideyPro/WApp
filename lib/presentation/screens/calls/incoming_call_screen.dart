import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../../data/services/conference_service.dart';
import 'jitsi_call_screen.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  final int conferenceId;
  final String callerName;
  final String? callerAvatar;
  final String? callerInitials;
  final String? listingTitle;

  const IncomingCallScreen({
    super.key,
    required this.conferenceId,
    required this.callerName,
    this.callerAvatar,
    this.callerInitials,
    this.listingTitle,
  });

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isConnecting = false;
  Timer? _vibrationTimer;
  bool _isRinging = false;

  @override
  void initState() {
    super.initState();
    _startRinging();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _stopRinging();
    _controller.dispose();
    super.dispose();
  }

  void _startRinging() {
    _isRinging = true;

    // Play system alert sound
    SystemSound.play(SystemSoundType.alert);

    HapticFeedback.heavyImpact();

    _vibrationTimer = Timer.periodic(
      const Duration(milliseconds: 800),
      (timer) {
        if (!_isRinging || !mounted) {
          timer.cancel();
          return;
        }
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_isRinging && mounted) {
            HapticFeedback.heavyImpact();
          }
        });

        if (timer.tick % 5 == 0) {
          SystemSound.play(SystemSoundType.alert);
        }
      },
    );
  }

  void _stopRinging() {
    _isRinging = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  Future<void> _acceptCall() async {
    if (_isConnecting) return;

    _stopRinging();
    setState(() => _isConnecting = true);

    try {
      final service = ConferenceService();
      final response = await service.joinConference(widget.conferenceId);

      if (response.success && mounted) {
        if (response.jitsiRoomUrl != null) {
          _navigateToJitsi(response);
          ref.read(incomingCallProvider.notifier).clearIncomingCall();
        } else {
          ref.read(incomingCallProvider.notifier).clearIncomingCall();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message.isNotEmpty
                    ? response.message
                    : 'Failed to get meeting link'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isConnecting = false);
          _startRinging();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isConnecting = false);
        _startRinging();
      }
    }
  }

  void _navigateToJitsi(ConferenceResponse response) {
    final url = response.jitsiRoomUrl;
    if (url != null && url.isNotEmpty && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => JitsiCallScreen(
            jitsiUrl: url,
            jitsiToken: response.jitsiToken,
            conferenceId: widget.conferenceId,
          ),
        ),
      );
    }
  }

  Future<void> _declineCall() async {
    _stopRinging();

    ref.read(incomingCallProvider.notifier).markDeclined(widget.conferenceId);

    try {
      final service = ConferenceService();
      await service.updateConferenceStatus(
        conferenceId: widget.conferenceId,
        status: 'cancelled',
      );
    } catch (_) {}

    if (mounted) {
      ref.read(incomingCallProvider.notifier).clearIncomingCall();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.navy950,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildCallerAvatar(),
              ),
              const SizedBox(height: 32),
              Text(
                widget.callerName,
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.white,
                ),
              ),
              if (widget.listingTitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.listingTitle!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.callIncoming,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wave400,
                ),
              ),
              const Spacer(),
              _buildActionButtons(l10n),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallerAvatar() {
    final initials = widget.callerInitials ?? '??';

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.wave600,
        boxShadow: [
          BoxShadow(
            color: AppColors.wave600.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.headline1.copyWith(
            color: Colors.white,
            fontSize: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDeclineButton(l10n),
          _buildAcceptButton(l10n),
        ],
      ),
    );
  }

  Widget _buildDeclineButton(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error,
          ),
          child: IconButton(
            onPressed: _declineCall,
            icon: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.callDecline,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.emerald600,
          ),
          child: _isConnecting
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : IconButton(
                  onPressed: _acceptCall,
                  icon: const Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.callAccept,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
