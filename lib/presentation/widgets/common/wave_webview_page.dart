import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A reusable WebView page for handling external flows like Chapa payments.
///
/// Accepts either a [url] directly or a [urlFuture] that resolves to one.
/// When [urlFuture] is provided the WebView opens immediately with a loading
/// state and navigates to the real URL once it resolves — avoids blocking the
/// transition on an upstream API call.
class WaveWebViewPage extends StatefulWidget {
  final String? url;
  final Future<String>? urlFuture;
  final String title;
  final List<String> successUrls;
  final List<String> cancelUrls;

  const WaveWebViewPage({
    super.key,
    this.url,
    this.urlFuture,
    required this.title,
    this.successUrls = const ['subscriptions/activate', 'payments/success'],
    this.cancelUrls = const ['payments/cancel'],
  }) : assert(url != null || urlFuture != null, 'Either url or urlFuture must be provided');

  @override
  State<WaveWebViewPage> createState() => WaveWebViewPageState();
}

class WaveWebViewPageState extends State<WaveWebViewPage> {
  InAppWebViewController? webViewController;
  String? _resolvedUrl;
  double progress = 0;
  bool isLoading = true;
  bool _awaitingUrl = true;
  Timer? _watchdogTimer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startWatchdog();
    _resolveUrl();
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    super.dispose();
  }

  Future<void> _resolveUrl() async {
    if (widget.url != null) {
      setState(() {
        _resolvedUrl = widget.url;
        _awaitingUrl = false;
      });
      return;
    }

    try {
      final url = await widget.urlFuture;
      if (mounted) {
        setState(() {
          _resolvedUrl = url;
          _awaitingUrl = false;
        });
        if (url != null && webViewController != null) {
          webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
        }
      }
    } catch (_) {
      if (mounted) {
        _handleError('Failed to load payment URL');
      }
    }
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(minutes: 1), () {
      if (isLoading && mounted) {
        _handleError('Gateway Timeout');
      }
    });
  }

  void _handleError(String message) {
    if (_hasError) return;
    _hasError = true;
    _watchdogTimer?.cancel();
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
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent500),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          if (_resolvedUrl != null)
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_resolvedUrl!)),
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
                  _watchdogTimer?.cancel();
                });
                _checkUrl(url.toString());
              },
              onReceivedError: (controller, request, error) {
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
          if (_awaitingUrl || (isLoading && progress < 0.1))
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to payment gateway...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _checkUrl(String url) {
    for (final successUrl in widget.successUrls) {
      if (url.contains(successUrl)) {
        Navigator.of(context).pop('success');
        return;
      }
    }

    for (final cancelUrl in widget.cancelUrls) {
      if (url.contains(cancelUrl)) {
        Navigator.of(context).pop('cancelled');
        return;
      }
    }
  }
}
