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

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  CachedVideoPlayerPlus? _player;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
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
      customControls: MinimalVideoControls(),
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
  void dispose() {
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
