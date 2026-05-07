import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/conference_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../l10n/app_localizations.dart';

/// WebView-based Jitsi call screen that properly handles authentication
/// by pre-injecting session cookies to avoid login page redirect
class WebViewJitsiScreen extends ConsumerStatefulWidget {
  final String? jitsiUrl;
  final String? jitsiToken;
  final int conferenceId;

  const WebViewJitsiScreen({
    super.key,
    this.jitsiUrl,
    this.jitsiToken,
    required this.conferenceId,
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
      final apiClient = ApiClient();
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
        } else {
          debugPrint('Failed to get session cookie: ${sessionResponse.data}');
        }
      } catch (e) {
        debugPrint('Error getting session cookie: $e');
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

      debugPrint('Session cookie injected: $cookieName for domain: $domain secure: $isSecure');
    } catch (e) {
      debugPrint('Failed to inject session cookie: $e');
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
    final apiClient = ApiClient();
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
      final jitsiHosts = [
        'jitsi.member.fsf.org',
        'meet.jit.si',
        conference.host,
      ];
      return jitsiHosts.contains(incoming.host) ||
          incoming.host == conference.host;
    } catch (_) {
      return false;
    }
  }

  Future<void> _leaveCall() async {
    if (_hasLeft) return;
    _hasLeft = true;

    try {
      final service = ConferenceService();
      await service.updateConferenceStatus(
        conferenceId: widget.conferenceId,
        status: 'left',
      );
    } catch (e) {
      debugPrint('Error updating conference status: $e');
    }

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
      backgroundColor: isDark ? AppColors.navy950 : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.navy900 : Colors.white,
        title: Text(AppLocalizations.of(context).jitsiCallTitle),
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
                      const AlwaysStoppedAnimation<Color>(AppColors.wave500),
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.wave500),
          ),
          const SizedBox(height: 24),
          Text(
            'Setting up call...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? Colors.white : AppColors.navy900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? AppLocalizations.of(context).commonError,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? Colors.white : AppColors.navy900,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryConnection,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
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
        debugPrint('Loading WebView with URL: $url');

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
                debugPrint('Jitsi leave event received via JS');
                _leaveCall();
              },
            );
          },
          onPermissionRequest: (controller, request) async {
            debugPrint('WebView permission request: ${request.resources}');
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100;
            });
            debugPrint('WebView progress: $progress%');
          },
          onLoadStart: (controller, url) {
            debugPrint('WebView started loading: $url');
          },
          onLoadStop: (controller, url) async {
            debugPrint('WebView finished loading: $url');
            if (!_isConferenceUrl(url?.toString())) {
              debugPrint('Navigated away from conference URL, leaving call');
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
            debugPrint('WebView error: ${error.description}');
            if (!_hasLeft) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Failed to load: ${error.description}';
              });
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri != null) {
              debugPrint('WebView navigating to: $uri');
              if (!_isConferenceUrl(uri.toString())) {
                debugPrint('Navigation outside conference detected, leaving call');
                _leaveCall();
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
          onCloseWindow: (controller) {
            debugPrint('WebView window closed');
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
