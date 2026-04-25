import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/conference_service.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_client.dart';

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
    try {
      // 1. Request native microphone permission
      final micStatus = await Permission.microphone.request();

      if (!micStatus.isGranted) {
        setState(() {
          _errorMessage = 'Microphone permission is required to join the call.';
          _isConnecting = false;
        });
        return;
      }

      // 2. Build the managed web URL
      // Use the web-based join route: /conferences/{id}/join
      final baseUrl = ApiConstants.baseUrl;
      final conferenceId = widget.conferenceId;
      
      // Get the current token for the "magic link" bridge
      final apiClient = ApiClient();
      final token = await apiClient.getAuthToken();
      
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found.';
          _isConnecting = false;
        });
        return;
      }

      // Construct the URL with the token for the TokenToSession middleware
      final webJoinUrl = Uri.parse('$baseUrl/conferences/$conferenceId/join').replace(
        queryParameters: {
          'token': token,
        },
      );

      if (await canLaunchUrl(webJoinUrl)) {
        final launched = await launchUrl(
          webJoinUrl,
          mode: LaunchMode.inAppBrowserView,
        );

        if (launched && context.mounted) {
          // Immediately pop since the browser view is an overlay
          Navigator.of(context).pop();
        } else if (!launched) {
          setState(() {
            _errorMessage = 'Could not launch the call room.';
            _isConnecting = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Cannot open the meeting room link.';
          _isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect: $e';
          _isConnecting = false;
        });
      }
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
        title: const Text('Audio Call'),
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
                      'Connecting to audio call...',
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
