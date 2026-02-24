import 'package:live_tv/features/home/data/models/anime_model.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';

class AnimeDetailsModel extends AnimeDetailsEntity {
  AnimeDetailsModel({
    required super.anime,
    required super.seasons,
    required super.episodes,
  });

  factory AnimeDetailsModel.fromInfoJson(Map<String, dynamic> json) {
    final results = json['results'];
    final data = results['data'];

    return AnimeDetailsModel(
      anime: AnimeModel(
        id: data['id']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        poster: data['poster']?.toString() ?? '',
        description: data['animeInfo']?['Overview']?.toString() ?? '',
      ),
      seasons: (results['seasons'] as List? ?? [])
          .map(
            (s) => SeasonEntity(
              id: s['id']?.toString() ?? '',
              name: s['season']?.toString() ?? '',
            ),
          )
          .toList(),
      episodes: [],
    );
  }

  AnimeDetailsModel copyWithEpisodes(List<EpisodeEntity> newEpisodes) {
    return AnimeDetailsModel(
      anime: anime,
      seasons: seasons,
      episodes: newEpisodes,
    );
  }
}
