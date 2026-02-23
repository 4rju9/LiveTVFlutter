class AnimeEntity {
  final String id;
  final String title;
  final String poster;
  final String description;
  final String? sub;
  final String? dub;
  final String? eps;

  AnimeEntity({
    required this.id,
    required this.title,
    required this.poster,
    required this.description,
    this.sub,
    this.dub,
    this.eps,
  });
}

class AnimeDataEntity {
  final List<AnimeEntity> mostPopular;
  final List<AnimeEntity> mostFavorite;
  final List<AnimeEntity> topAiring;
  final List<AnimeEntity> latestCompleted;

  AnimeDataEntity({
    required this.mostPopular,
    required this.mostFavorite,
    required this.topAiring,
    required this.latestCompleted,
  });
}
