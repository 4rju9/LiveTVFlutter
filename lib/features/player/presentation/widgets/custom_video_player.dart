import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:live_tv/init_dependencies.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';

class CustomVideoPlayer extends StatefulWidget {
  final StreamConfig config;
  const CustomVideoPlayer({super.key, required this.config});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.url != widget.config.url) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _chewieController = null;
    });

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.config.url),
        httpHeaders: widget.config.headers ?? {},
      );

      await _videoPlayerController!.initialize();

      // Force lowest resolution by default (if supported by platform plugin)
      try {
        await (_videoPlayerController as dynamic).setPreferredPeakBitRate(1.0);
      } catch (_) {
        debugPrint('setPreferredPeakBitRate not supported on this platform/version');
      }

      // Setup Subtitles (Default to English)
      if (widget.config.subtitles != null && widget.config.subtitles!.isNotEmpty) {
        final enSub = widget.config.subtitles!.firstWhere(
          (sub) => sub.label.toLowerCase().contains('english') || sub.label.toLowerCase() == 'en',
          orElse: () => widget.config.subtitles!.first,
        );
        try {
          final res = await sl<Dio>().get(enSub.url);
          if (res.statusCode == 200) {
            await _videoPlayerController!.setClosedCaptionFile(
              Future.value(WebVTTCaptionFile(res.data.toString())),
            );
          }
        } catch (e) {
          debugPrint('Failed to load subtitle: $e');
        }
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio > 0
            ? _videoPlayerController!.value.aspectRatio
            : 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey.withValues(alpha: 0.5),
          bufferedColor: Colors.white.withValues(alpha: 0.5),
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          debugPrint('Chewie Error: $errorMessage');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sorry, this video is currently unavailable. Please try again later.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing CustomVideoPlayer: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Sorry, this video is currently unavailable. Please try again later.';
      });
    }
  }

  void _disposePlayer() {
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Stream unavailable',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                onPressed: _initializePlayer,
              )
            ],
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );
  }
}
