import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

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
  bool _isLaunching = false;
  bool _isLaunched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _launchJitsi();
  }

  Future<void> _launchJitsi() async {
    if (_isLaunched) return;

    setState(() {
      _isLaunching = true;
      _errorMessage = null;
    });

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
        await launchUrl(url, mode: LaunchMode.externalApplication);
        setState(() => _isLaunched = true);
      } else {
        setState(() {
          _errorMessage = 'Cannot open Jitsi meeting link';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to open Jitsi: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLaunching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.navy950,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.jitsiCallTitle,
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLaunching)
                const CircularProgressIndicator(color: Colors.white)
              else if (_errorMessage != null) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _launchJitsi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.wave600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.commonRetry),
                ),
              ] else ...[
                const Icon(
                  Icons.videocam,
                  size: 64,
                  color: AppColors.emerald600,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.jitsiOpening,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Meeting URL:',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.jitsiUrl,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isLaunched)
                Text(
                  l10n.jitsiOpenedExternal,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  l10n.jitsiCloseToJoin,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
