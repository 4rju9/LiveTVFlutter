import 'package:live_tv/features/home/domain/entities/anime_entity.dart';

class AnimeDetailsEntity {
  final AnimeEntity anime;
  final List<SeasonEntity> seasons;
  final List<EpisodeEntity> episodes;

  AnimeDetailsEntity({
    required this.anime,
    required this.seasons,
    required this.episodes,
  });
}

class SeasonEntity {
  final String id;
  final String name;
  final bool isCurrent;

  SeasonEntity({required this.id, required this.name, this.isCurrent = false});
}

class EpisodeEntity {
  final String id;
  final String title;
  final String episodeNumber;
  final String? poster;

  EpisodeEntity({
    required this.id,
    required this.title,
    required this.episodeNumber,
    this.poster,
  });
}
