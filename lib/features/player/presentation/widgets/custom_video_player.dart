import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';

class CustomVideoPlayer extends StatefulWidget {
  final StreamConfig config;
  const CustomVideoPlayer({super.key, required this.config});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _play();
  }

  Future<void> _play() async {
    if (kIsWeb) await player.setVolume(0);
    await player.open(
      Media(widget.config.url, httpHeaders: widget.config.headers),
    );

    if (widget.config.subtitles != null &&
        widget.config.subtitles!.isNotEmpty) {
      player.setSubtitleTrack(
        SubtitleTrack.uri(
          widget.config.subtitles!.first.url,
          title: widget.config.subtitles!.first.label,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.url != widget.config.url) {
      _play();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(controller: controller, controls: MaterialVideoControls);
  }
}
