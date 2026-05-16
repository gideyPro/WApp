import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A reusable WebView page for handling external flows like Chapa payments
class WaveWebViewPage extends StatefulWidget {
  final String url;
  final String title;
  final List<String> successUrls;
  final List<String> cancelUrls;

  const WaveWebViewPage({
    super.key,
    required this.url,
    required this.title,
    this.successUrls = const ['subscriptions/activate', 'payments/success'],
    this.cancelUrls = const ['payments/cancel'],
  });

  @override
  State<WaveWebViewPage> createState() => _WaveWebViewPageState();
}

class _WaveWebViewPageState extends State<WaveWebViewPage> {
  InAppWebViewController? webViewController;
  double progress = 0;
  bool isLoading = true;
  Timer? _watchdogTimer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startWatchdog();
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    super.dispose();
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(minutes: 1), () {
      if (isLoading && mounted) {
        debugPrint('WebView Watchdog Timeout: Page failed to load in 60s');
        _handleError('Gateway Timeout');
      }
    });
  }

  void _handleError(String message) {
    if (_hasError) return;
    _hasError = true;
    _watchdogTimer?.cancel();
    debugPrint('WebView Technical Error: $message');
    if (mounted) {
      Navigator.of(context).pop('technical_failure');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: AppTextStyles.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop('closed'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('done'),
            child: Text(
              'Done',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        bottom: progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent500),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              iframeAllow: "camera; microphone",
              iframeAllowFullscreen: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
              _checkUrl(url.toString());
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
                _watchdogTimer?.cancel(); // Success!
              });
              _checkUrl(url.toString());
            },
            onReceivedError: (controller, request, error) {
              // Ignore some minor errors if needed, but usually network errors are fatal for payment
              if (request.isForMainFrame == true) {
                _handleError(error.description);
              }
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              if (request.isForMainFrame == true) {
                _handleError('HTTP ${errorResponse.statusCode}');
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url;
              if (uri != null) {
                _checkUrl(uri.toString());
              }
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (isLoading && progress < 0.1)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _checkUrl(String url) {
    debugPrint('WebView navigating to: $url');
    
    // Check for success URLs
    for (final successUrl in widget.successUrls) {
      if (url.contains(successUrl)) {
        debugPrint('Success URL detected: $url');
        Navigator.of(context).pop('success');
        return;
      }
    }

    // Check for cancel URLs
    for (final cancelUrl in widget.cancelUrls) {
      if (url.contains(cancelUrl)) {
        debugPrint('Cancel URL detected: $url');
        Navigator.of(context).pop('cancelled');
        return;
      }
    }
  }
}
