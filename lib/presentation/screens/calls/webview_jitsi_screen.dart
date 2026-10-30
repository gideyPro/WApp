import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../providers/app_providers.dart';

/// WebView-based Jitsi call screen that properly handles authentication
/// by pre-injecting session cookies to avoid login page redirect
class WebViewJitsiScreen extends ConsumerStatefulWidget {
  final String? jitsiUrl;
  final String? jitsiToken;
  final int conferenceId;
  final bool isVideo;

  const WebViewJitsiScreen({
    super.key,
    this.jitsiUrl,
    this.jitsiToken,
    required this.conferenceId,
    this.isVideo = false,
  });

  @override
  ConsumerState<WebViewJitsiScreen> createState() => _WebViewJitsiScreenState();
}

class _WebViewJitsiScreenState extends ConsumerState<WebViewJitsiScreen> {
  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _conferenceUrl;
  bool _hasLeft = false;
  final CookieManager _cookieManager = CookieManager.instance();
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  @override
  void dispose() {
    _webViewController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCall() async {
    try {
      // 1. Request microphone permission
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Microphone permission is required to join the call.';
          _isLoading = false;
        });
        return;
      }

      // 2. Get auth token
      final apiClient = ref.read(apiClientProvider);
      final token = await apiClient.getAuthToken();
      if (token == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication token not found.';
          _isLoading = false;
        });
        return;
      }

      // 3. Call web-session/cookie endpoint to get session cookie info
      try {
        final dio = apiClient.dio;
        final sessionResponse = await dio.post(
          '${ApiConstants.apiBase}/web-session/cookie',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );

        if (sessionResponse.statusCode == 200 &&
            sessionResponse.data['success']) {
          final cookieData = sessionResponse.data['data'];
          await _injectSessionCookie(cookieData);
        }
      } catch (_) {
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize call: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _injectSessionCookie(Map<String, dynamic> cookieData) async {
    try {
      final cookieName = cookieData['cookie_name'] ?? 'wavemart-session';
      final cookieValue = cookieData['cookie_value'] ?? '';

      // Always derive domain from ApiConstants.baseUrl to avoid mismatch
      // (e.g. backend may return "localhost" if APP_URL is misconfigured)
      final correctDomain = _extractDomain(ApiConstants.baseUrl);
      final backendDomain = cookieData['domain'] as String?;
      final domain = (backendDomain != null &&
              backendDomain != 'localhost' &&
              backendDomain.isNotEmpty)
          ? backendDomain
          : correctDomain;

      final path = cookieData['path'] ?? '/';

      // Force secure=true for HTTPS sites — the backend config may not
      // reflect the actual deployment scheme
      final baseUrlIsHttps =
          Uri.parse(ApiConstants.baseUrl).scheme == 'https';
      final isSecure = baseUrlIsHttps || (cookieData['secure'] == true);

      await _cookieManager.setCookie(
        url: WebUri(ApiConstants.baseUrl),
        name: cookieName,
        value: cookieValue,
        domain: domain,
        path: path,
        isSecure: isSecure,
        isHttpOnly: cookieData['http_only'] ?? true,
      );

    } catch (_) {
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'wavemart.et';
    }
  }

  Future<String> _getConferenceUrl() async {
    final apiClient = ref.read(apiClientProvider);
    final token = await apiClient.getAuthToken();
    final uri =
        Uri.parse('${ApiConstants.baseUrl}/conferences/${widget.conferenceId}/join');
    final url = uri
        .replace(queryParameters: {
          'token': token ?? '',
        })
        .toString();
    _conferenceUrl = url;
    return url;
  }

  bool _isConferenceUrl(String? url) {
    if (url == null || _conferenceUrl == null) return false;
    try {
      final incoming = Uri.parse(url);
      final conference = Uri.parse(_conferenceUrl!);
      
      // We strictly only allow the exact conference join path on our domain.
      // If Jitsi redirects to / (home) or any other path after the call, 
      // this will return false and trigger the screen to close.
      return incoming.host == conference.host && incoming.path == conference.path;
    } catch (_) {
      return false;
    }
  }

  void _leaveCall() {
    if (_hasLeft) return;
    _hasLeft = true;

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });
    await _initializeCall();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary950 : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.primary900 : Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.isVideo ? Icons.videocam : Icons.phone, size: 20),
            const SizedBox(width: 8),
            Text(widget.isVideo ? 'Video Call' : AppLocalizations.of(context).jitsiCallTitle),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _leaveCall,
        ),
        bottom: _progress < 1.0 && !_hasError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent500),
                ),
              )
            : null,
      ),
      body: _hasError
          ? _buildErrorView()
          : _isLoading
              ? _buildLoadingView()
              : _buildWebView(),
    );
  }

  Widget _buildLoadingView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent500),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).jitsiSettingUpCall,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? Colors.white : AppColors.primary900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return WaveMessageScreen.error(
      subtitle: _errorMessage,
      onRetry: _retryConnection,
      isEmbedded: true,
    );
  }

  Widget _buildWebView() {
    return FutureBuilder<String>(
      future: _getConferenceUrl(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingView();
        }

        final url = snapshot.data!;

        return Stack(
          children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url)),
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            iframeAllow: "camera; microphone",
            iframeAllowFullscreen: true,
            javaScriptEnabled: true,
            domStorageEnabled: true,
            useHybridComposition: true,
            supportMultipleWindows: false,
            thirdPartyCookiesEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            cacheMode: CacheMode.LOAD_DEFAULT,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            controller.addJavaScriptHandler(
              handlerName: 'onJitsiLeave',
              callback: (args) {
                _leaveCall();
              },
            );
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onLoadStart: (controller, url) {
          },
          onLoadStop: (controller, url) async {
            if (!_isConferenceUrl(url?.toString())) {
              _leaveCall();
              return;
            }
            setState(() {
              _isLoading = false;
            });
            await controller.evaluateJavascript(source: '''
              (function() {
                var observer = new MutationObserver(function() {
                  var leaveBtn = document.querySelector('.dismiss-button, .icon-default, [aria-label="Leave"], [data-testid="leave"], button[title="Leave"], .toolbox-button[aria-label="Leave call"]');
                  if (leaveBtn) {
                    leaveBtn.addEventListener('click', function() {
                      if (window.flutter_inappwebview) {
                        window.flutter_inappwebview.callHandler('onJitsiLeave');
                      }
                    }, true);
                  }
                });
                observer.observe(document.body, { childList: true, subtree: true });
              })();
            ''');
          },
          onReceivedError: (controller, request, error) {
            if (!_hasLeft && request.isForMainFrame == true) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Failed to load: ${error.description}';
              });
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri != null) {
              if (!_isConferenceUrl(uri.toString())) {
                _leaveCall();
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
          onCloseWindow: (controller) {
            _leaveCall();
          },
        ),
            if (_isLoading && _progress < 0.1)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}
