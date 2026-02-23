import 'package:live_tv/features/home/domain/entities/anime_entity.dart';

class AnimeModel extends AnimeEntity {
  AnimeModel({
    required super.id,
    required super.title,
    required super.poster,
    required super.description,
    super.sub,
    super.dub,
    super.eps,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    final tvInfo = json['tvInfo'] as Map<String, dynamic>? ?? {};
    return AnimeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sub: tvInfo['sub']?.toString(),
      dub: tvInfo['dub']?.toString(),
      eps: tvInfo['eps']?.toString(),
    );
  }
}

class AnimeDataModel extends AnimeDataEntity {
  AnimeDataModel({
    required super.mostPopular,
    required super.mostFavorite,
    required super.topAiring,
    required super.latestCompleted,
  });

  factory AnimeDataModel.fromJson(Map<String, dynamic> json) {
    List<AnimeModel> parseList(String key) {
      final list = json[key] as List?;
      if (list == null) return [];
      return list
          .map((e) => AnimeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return AnimeDataModel(
      mostPopular: parseList('mostPopular'),
      mostFavorite: parseList('mostFavorite'),
      topAiring: parseList('topAiring'),
      latestCompleted: parseList('latestCompleted'),
    );
  }
}
