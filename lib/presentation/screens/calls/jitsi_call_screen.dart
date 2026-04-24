import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/services/conference_service.dart';

class JitsiCallScreen extends ConsumerStatefulWidget {
  final String jitsiUrl;
  final String? jitsiToken;
  final int conferenceId;

  const JitsiCallScreen({
    super.key,
    required this.jitsiUrl,
    this.jitsiToken,
    required this.conferenceId,
  });

  @override
  ConsumerState<JitsiCallScreen> createState() => _JitsiCallScreenState();
}

class _JitsiCallScreenState extends ConsumerState<JitsiCallScreen> {
  bool _isConnecting = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _connectToCall();
  }

  Future<void> _connectToCall() async {
    try {
      String meetingUrl = widget.jitsiUrl;

      // Append JWT token as query parameter if provided
      if (widget.jitsiToken != null && widget.jitsiToken!.isNotEmpty) {
        final uri = Uri.parse(meetingUrl);
        final queryParams = Map<String, String>.from(uri.queryParameters);
        queryParams['jwt'] = widget.jitsiToken!;
        meetingUrl = uri.replace(queryParameters: queryParams).toString();
      }

      final url = Uri.parse(meetingUrl);

      if (await canLaunchUrl(url)) {
        // Try in-app first, fall back to external
        final launched = await launchUrl(
          url, 
          mode: LaunchMode.inAppWebView,
        );
        
        if (!launched) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = 'Cannot open meeting link';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect';
        _isConnecting = false;
      });
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });
    await _connectToCall();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.navy900 : Colors.white,
        title: const Text('Video Call'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final service = ConferenceService();
            service.updateConferenceStatus(
              conferenceId: widget.conferenceId,
              status: 'left',
            );
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: _isConnecting 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.wave500),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Connecting to call...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark ? Colors.white : AppColors.navy900,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Failed to connect',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _retryConnection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
      ),
    );
  }
}