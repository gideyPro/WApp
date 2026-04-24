import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/conference_service.dart';

class JitsiCallScreen extends ConsumerStatefulWidget {
  final String? jitsiUrl;
  final String? jitsiToken;
  final int conferenceId;

  const JitsiCallScreen({
    super.key,
    this.jitsiUrl,
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
    final urlString = widget.jitsiUrl;
    if (urlString == null || urlString.isEmpty) {
      setState(() {
        _errorMessage = 'No meeting URL provided';
        _isConnecting = false;
      });
      return;
    }

    try {
      var meetingUrl = urlString;

      // Append JWT token as query parameter if provided
      final token = widget.jitsiToken;
      if (token != null && token.isNotEmpty) {
        final parsedUri = Uri.parse(meetingUrl);
        final queryParams = Map<String, String>.from(parsedUri.queryParameters);
        queryParams['jwt'] = token;
        meetingUrl = parsedUri.replace(queryParameters: queryParams).toString();
      }

      final uri = Uri.parse(meetingUrl);

      if (await canLaunchUrl(uri)) {
        // Try in-app first, fall back to external
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );

        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }

        if (context.mounted) {
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
        _errorMessage = 'Failed to connect: $e';
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.wave500),
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
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
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
