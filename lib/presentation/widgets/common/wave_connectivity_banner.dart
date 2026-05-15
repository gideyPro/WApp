import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';

class WaveConnectivityBanner extends ConsumerStatefulWidget {
  const WaveConnectivityBanner({super.key});

  @override
  ConsumerState<WaveConnectivityBanner> createState() => _WaveConnectivityBannerState();
}

class _WaveConnectivityBannerState extends ConsumerState<WaveConnectivityBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = false;
  ConnectivityStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
      _controller.forward();
    }
  }

  void _hide() {
    if (_isVisible) {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _isVisible = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(connectivityStatusProvider);
    
    // Logic to show/hide based on status transitions
    if (status == ConnectivityStatus.offline) {
      _show();
    } else if (status == ConnectivityStatus.online && _lastStatus == ConnectivityStatus.offline) {
      // Transitioned back to online
      _show();
      // Auto-hide after 3 seconds of "Back Online"
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && ref.read(connectivityStatusProvider) == ConnectivityStatus.online) {
          _hide();
        }
      });
    } else if (status == ConnectivityStatus.online && !_isVisible) {
      // Stay hidden if already online and stable
      // But we might need to hide if it was showing
    }

    _lastStatus = status;

    if (!_isVisible) return const SizedBox.shrink();

    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 12,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(status),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(status),
              const SizedBox(width: 12),
              Text(
                _getMessage(status),
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.offline:
        return AppColors.zinc800;
      case ConnectivityStatus.connecting:
        return AppColors.warning;
      case ConnectivityStatus.online:
        return AppColors.emerald600;
    }
  }

  Widget _buildIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.offline:
        return const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20);
      case ConnectivityStatus.connecting:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case ConnectivityStatus.online:
        return const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20);
    }
  }

  String _getMessage(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.offline:
        return 'No internet connection';
      case ConnectivityStatus.connecting:
        return 'Connecting...';
      case ConnectivityStatus.online:
        return 'Back Online';
    }
  }
}
