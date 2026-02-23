import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';

class LiveChannelModel extends LiveChannelEntity {
  const LiveChannelModel({
    required super.title,
    required super.quality,
    required super.language,
    required super.mediaType,
    required super.logo,
    required super.url,
  });

  factory LiveChannelModel.fromJson(Map<String, dynamic> json) {
    return LiveChannelModel(
      title: json['title'] ?? 'Unknown',
      quality: json['quality'] ?? 'Multi',
      language: json['language'] ?? 'Multi',
      mediaType: json['mediaType'] ?? '',
      logo: json['logo'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
