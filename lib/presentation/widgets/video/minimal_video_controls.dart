import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MinimalVideoControls extends StatefulWidget {
  const MinimalVideoControls({super.key});

  @override
  State<MinimalVideoControls> createState() => _MinimalVideoControlsState();
}

class _MinimalVideoControlsState extends State<MinimalVideoControls> {
  late VideoPlayerValue _latestValue;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;
  bool _controlsVisible = false;

  late VideoPlayerController controller;
  ChewieController? _chewieController;

  ChewieController get chewieController => _chewieController!;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Future<void> _initialize() async {
    controller.addListener(_updateState);
    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _controlsVisible = true);
      });
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder?.call(
            context,
            chewieController.videoPlayerController.value.errorDescription!,
          ) ??
          const Center(child: Icon(Icons.error, color: Colors.white, size: 42));
    }

    return GestureDetector(
      onTap: _cancelAndRestartTimer,
      child: Stack(
        children: [
          if (_displayBufferingIndicator)
            chewieController.bufferingBuilder?.call(context) ??
                const Center(child: CircularProgressIndicator())
          else
            _buildHitArea(),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished =
        (_latestValue.position >= _latestValue.duration) &&
        _latestValue.duration.inSeconds > 0;

    return GestureDetector(
      onTap: () {
        if (_latestValue.isPlaying) {
          if (!_controlsVisible) {
            _cancelAndRestartTimer();
          } else {
            setState(() => _controlsVisible = false);
          }
        } else {
          _playPause();
          setState(() => _controlsVisible = true);
        }
      },
      child: Container(
        alignment: Alignment.center,
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: _playPause,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(
                isFinished ? Icons.replay : _latestValue.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: .7)],
            ),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 8,
            top: 24,
            bottom: chewieController.isFullScreen ? 16 : 8,
          ),
          child: SafeArea(
            top: false,
            bottom: chewieController.isFullScreen,
            minimum: chewieController.controlsSafeAreaMinimum,
            child: Row(
              children: [
                _buildPosition(),
                const SizedBox(width: 12),
                Expanded(child: _buildProgressBar()),
                if (chewieController.allowFullScreen) _buildExpandButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosition() {
    return Text(
      '${_formatDuration(_latestValue.position)} / ${_formatDuration(_latestValue.duration)}',
      style: const TextStyle(
        fontSize: 13,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDuration(Duration position) {
    final ms = position.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    final minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursStr = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';
    final minutesStr = minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';
    final secondsStr = seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';

    return '${hoursStr == '00' ? '' : '$hoursStr:'}$minutesStr:$secondsStr';
  }

  Widget _buildProgressBar() {
    final chewieColors = chewieController.materialProgressColors;
    return ChewieProgressBar(
      controller: controller,
      onDragStart: () => _hideTimer?.cancel(),
      onDragEnd: _startHideTimer,
      playedColor: chewieColors?.playedPaint.color ?? Theme.of(context).colorScheme.secondary,
      handleColor: chewieColors?.handlePaint.color ?? Theme.of(context).colorScheme.secondary,
      bufferedColor: chewieColors?.bufferedPaint.color ?? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      backgroundColor: chewieColors?.backgroundPaint.color ?? Theme.of(context).disabledColor.withValues(alpha: .5),
      draggable: chewieController.draggableProgressBar,
    );
  }

  Widget _buildExpandButton() {
    return IconButton(
      icon: Icon(
        chewieController.isFullScreen
            ? Icons.fullscreen_exit
            : Icons.fullscreen,
        color: Colors.white,
        size: 28,
      ),
      onPressed: () {
        setState(() => _controlsVisible = false);
        chewieController.toggleFullScreen();
        _showAfterExpandCollapseTimer = Timer(
          const Duration(milliseconds: 300),
          () => _cancelAndRestartTimer(),
        );
      },
    );
  }

  void _playPause() {
    final bool isFinished =
        (_latestValue.position >= _latestValue.duration) &&
        _latestValue.duration.inSeconds > 0;

    setState(() {
      if (controller.value.isPlaying) {
        _controlsVisible = true;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) => controller.play());
        } else {
          if (isFinished) controller.seekTo(Duration.zero);
          controller.play();
        }
      }
    });
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();
    if (mounted) setState(() => _controlsVisible = true);
  }

  void _startHideTimer() {
    final hideDuration = chewieController.hideControlsTimer.isNegative
        ? ChewieController.defaultHideControlsTimer
        : chewieController.hideControlsTimer;
    _hideTimer = Timer(hideDuration, () {
      if (!mounted) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) setState(() {});
  }

  void _updateState() {
    if (!mounted) return;

    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() => _latestValue = controller.value);
  }
}

class ChewieProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Color playedColor;
  final Color handleColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final bool draggable;

  const ChewieProgressBar({
    super.key,
    required this.controller,
    this.onDragStart,
    this.onDragEnd,
    this.playedColor = Colors.white,
    this.handleColor = Colors.white,
    this.bufferedColor = Colors.white38,
    this.backgroundColor = Colors.white24,
    this.draggable = true,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final duration = value.duration;
    final position = value.position;

    if (duration == Duration.zero) return const SizedBox();

    final played = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
    final buffered = value.buffered.isNotEmpty
        ? value.buffered.last.end.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: draggable ? (details) => _seek(details, constraints.maxWidth) : null,
          onHorizontalDragStart: draggable ? (_) => onDragStart?.call() : null,
          onHorizontalDragUpdate: draggable
              ? (details) {
                  final local = details.localPosition;
                  final p = (local.dx / constraints.maxWidth).clamp(0.0, 1.0);
                  controller.seekTo(duration * p);
                }
              : null,
          onHorizontalDragEnd: draggable ? (_) => onDragEnd?.call() : null,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: buffered.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bufferedColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: played.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: playedColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (draggable)
                  Positioned(
                    left: (played.clamp(0.0, 1.0) * constraints.maxWidth) - 6,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: handleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _seek(TapDownDetails details, double width) {
    final p = (details.localPosition.dx / width).clamp(0.0, 1.0);
    controller.seekTo(controller.value.duration * p);
  }
}
