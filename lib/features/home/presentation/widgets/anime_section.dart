import 'package:flutter/material.dart';
import 'package:live_tv/features/home/domain/entities/anime_entity.dart';
import 'package:live_tv/features/home/presentation/widgets/anime_card.dart';

class AnimeSection extends StatelessWidget {
  final AnimeDataEntity animeData;

  const AnimeSection({super.key, required this.animeData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildList(context, 'Most Popular', animeData.mostPopular),
        _buildList(context, 'Most Favorite', animeData.mostFavorite),
        _buildList(context, 'Top Airing', animeData.topAiring),
        _buildList(context, 'Latest Completed', animeData.latestCompleted),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    String title,
    List<AnimeEntity> animes,
  ) {
    if (animes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: animes.length,
            itemBuilder: (context, index) {
              return AnimeCard(anime: animes[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
