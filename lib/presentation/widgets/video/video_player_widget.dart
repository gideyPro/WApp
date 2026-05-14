import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/constants/app_colors.dart';
import 'minimal_video_controls.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final String? title;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
    this.title,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

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
      });
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      _videoController = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: controller.value.aspectRatio,
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

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || _chewieController == null) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent500,
        ),
      ),
    );
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
            const Text(
              'Failed to load video',
              style: TextStyle(
                color: AppColors.primary600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
