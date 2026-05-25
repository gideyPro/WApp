import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'minimal_video_controls.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool autoPlay;
  final bool looping;
  final String? title;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.autoPlay = false,
    this.looping = false,
    this.title,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  CachedVideoPlayerPlus? _player;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _userTappedPlay = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeControllers();
      setState(() {
        _isLoading = true;
        _hasError = false;
        _userTappedPlay = false;
      });
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final player = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.videoUrl),
        invalidateCacheIfOlderThan: const Duration(days: 30),
      );

      await player.initialize();

      if (!mounted) {
        player.dispose();
        return;
      }

      _player = player;
      player.controller.addListener(_onVideoProgress);
      _chewieController = ChewieController(
        videoPlayerController: player.controller,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: player.controller.value.aspectRatio,
        allowFullScreen: true,
        showControls: true,
        showOptions: false,
        placeholder: Container(
          color: AppColors.zinc100,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent500,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget();
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.accent500,
          handleColor: AppColors.accent500,
          backgroundColor: AppColors.zinc300,
          bufferedColor: AppColors.zinc300,
        ),
        customControls: const MinimalVideoControls(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _retry() {
    _disposeControllers();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _initializeVideo();
  }

  void _onVideoProgress() {
    final controller = _player?.controller;
    if (controller == null || !controller.value.isInitialized) return;
    final isFinished = controller.value.position >= controller.value.duration &&
        controller.value.duration.inSeconds > 0;
    if (isFinished != _isFinished && mounted) {
      setState(() => _isFinished = isFinished);
    }
  }

  void _disposeControllers() {
    _player?.controller.removeListener(_onVideoProgress);
    _chewieController?.dispose();
    _chewieController = null;
    _player?.dispose();
    _player = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: _player?.controller.value.isInitialized == true
            ? _player!.controller.value.aspectRatio
            : 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_chewieController != null)
              Chewie(controller: _chewieController!),
            if (!_userTappedPlay || _isLoading || _isFinished) _buildThumbnailOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailOverlay() {
    return GestureDetector(
      onTap: _isLoading ? null : _onPlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: widget.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.zinc100),
              errorWidget: (_, __, ___) => Container(color: AppColors.zinc100),
            )
          else
            Container(color: AppColors.zinc100),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent500),
            )
          else
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isFinished ? Icons.replay_rounded : Icons.play_arrow_rounded,
                  size: 36,
                  color: AppColors.accent500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onPlay() {
    if (_isFinished) {
      _replay();
    } else {
      setState(() => _userTappedPlay = true);
      _player?.controller.play();
    }
  }

  void _replay() {
    _disposeControllers();
    setState(() {
      _isLoading = true;
      _userTappedPlay = true;
      _isFinished = false;
    });
    _initializeVideo();
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).errorVideoLoad,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
