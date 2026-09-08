import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:chewie/chewie.dart';
import '../../widgets/video/minimal_video_controls.dart';
import '../../../core/constants/app_colors.dart';

class FullScreenVideoScreen extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoScreen({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoScreen> createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> with WidgetsBindingObserver {
  CachedVideoPlayerPlus? _player;
  ChewieController? _chewieController;
  bool _wasPlayingBeforeBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
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
    _chewieController = ChewieController(
      videoPlayerController: player.controller,
      autoPlay: true,
      looping: false,
      aspectRatio: player.controller.value.aspectRatio,
      allowFullScreen: false,
      showControls: true,
      showOptions: false,
      customControls: const MinimalVideoControls(),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.accent500,
        handleColor: AppColors.accent500,
        backgroundColor: AppColors.zinc300,
        bufferedColor: AppColors.zinc300,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _player?.controller;
    if (controller == null || !controller.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _wasPlayingBeforeBackground = controller.value.isPlaying;
        if (controller.value.isPlaying) {
          controller.pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforeBackground) {
          controller.play();
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _chewieController?.dispose();
        _chewieController = null;
        _player?.dispose();
        _player = null;
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chewieController?.dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: _chewieController == null
            ? const CircularProgressIndicator(color: Colors.white)
            : Chewie(controller: _chewieController!),
      ),
    );
  }
}
