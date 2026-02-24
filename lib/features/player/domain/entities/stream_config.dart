enum StreamType { hls, dash, drm }

class SubtitleEntity {
  final String url;
  final String label;
  SubtitleEntity({required this.url, required this.label});
}

class DrmConfig {
  final String key;
  final String keyId;
  DrmConfig({required this.key, required this.keyId});
}

class StreamConfig {
  final String url;
  final String title;
  final StreamType type;
  final List<SubtitleEntity>? subtitles;
  final Map<String, String>? headers;
  final DrmConfig? drmConfig;

  StreamConfig({
    required this.url,
    required this.title,
    required this.type,
    this.subtitles,
    this.headers,
    this.drmConfig,
  });
}
