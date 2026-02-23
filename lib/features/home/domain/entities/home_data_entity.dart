import 'package:live_tv/features/home/domain/entities/anime_entity.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';

class HomeDataEntity {
  final Map<String, List<LiveChannelEntity>> channelsMap;
  final AnimeDataEntity? animeData;

  HomeDataEntity({required this.channelsMap, this.animeData});
}
