import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';
import 'package:live_tv/features/home/data/models/anime_model.dart';
import 'package:live_tv/features/home/data/models/live_channel_model.dart';

abstract class HomeLocalDataSource {
  Future<void> cacheHomeData(Map<String, dynamic> rawJsonData);
  Future<HomeDataEntity?> getCachedHomeData();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const boxName = 'homeDataBox';
  static const keyName = 'homeChannelsMap';

  @override
  Future<void> cacheHomeData(Map<String, dynamic> rawJsonData) async {
    final box = await Hive.openBox(boxName);
    await box.put(keyName, json.encode(rawJsonData));
  }

  @override
  Future<HomeDataEntity?> getCachedHomeData() async {
    final box = await Hive.openBox(boxName);
    final String? jsonString = box.get(keyName);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> data = json.decode(jsonString);
        
        Map<String, List<LiveChannelModel>> categoryMap = {};
        AnimeDataModel? animeData;

        data.forEach((key, value) {
          if (key == 'anime' && value is Map<String, dynamic>) {
            final animeContent = value['data'];
            if (animeContent is Map<String, dynamic>) {
              animeData = AnimeDataModel.fromJson(animeContent);
            }
          } else if (value is List) {
            categoryMap[key] = value
                .map((json) => LiveChannelModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        });

        return HomeDataEntity(channelsMap: categoryMap, animeData: animeData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
