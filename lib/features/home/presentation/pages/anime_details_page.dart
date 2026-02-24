import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_tv/features/player/presentation/cubit/player_cubit.dart';
import 'package:live_tv/features/player/presentation/widgets/custom_video_player.dart';

class AnimeDetailsPage extends StatefulWidget {
  final String animeId;
  const AnimeDetailsPage({super.key, required this.animeId});

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<EpisodeEntity> _filteredEpisodes = [];
  List<EpisodeEntity> _allEpisodes = [];
  String? _currentPlayingEpisodeId;

  @override
  void initState() {
    super.initState();
    // Fetch initial anime details from Home API
    context.read<HomeCubit>().fetchAnimeDetails(widget.animeId);
  }

  void _filterEpisodes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEpisodes = _allEpisodes;
      } else {
        _filteredEpisodes = _allEpisodes
            .where((ep) => ep.episodeNumber.contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is AnimeDetailsLoaded) {
            _allEpisodes = state.details.episodes;
            _filteredEpisodes = _allEpisodes;

            _currentPlayingEpisodeId = _allEpisodes[0].id;
            context.read<PlayerCubit>().loadAnimeEpisode(
              _allEpisodes[0].id,
              state.details.anime.title,
            );
          }
        },
        builder: (context, state) {
          if (state is AnimeDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimeDetailsLoaded) {
            final details = state.details;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: BlocBuilder<PlayerCubit, PlayerState>(
                      builder: (context, pState) {
                        if (pState is PlayerLoaded) {
                          return CustomVideoPlayer(config: pState.config);
                        }
                        if (pState is PlayerLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Image.network(
                          details.anime.poster,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.anime.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details.anime.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _searchController,
                          onChanged: _filterEpisodes,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Search episode number...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: theme.primaryColor.withAlpha(20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Episodes",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_filteredEpisodes.length} Items",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 1.0,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final episode = _filteredEpisodes[index];
                      final isPlaying = _currentPlayingEpisodeId == episode.id;
                      return _EpisodeBox(
                        episode: episode,
                        primaryColor: theme.primaryColor,
                        isPlaying: isPlaying,
                        onTap: () {
                          setState(() => _currentPlayingEpisodeId = episode.id);
                          context.read<PlayerCubit>().loadAnimeEpisode(
                            episode.id,
                            details.anime.title,
                          );
                        },
                      );
                    }, childCount: _filteredEpisodes.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EpisodeBox extends StatefulWidget {
  final EpisodeEntity episode;
  final Color primaryColor;
  final bool isPlaying;
  final VoidCallback onTap;
  const _EpisodeBox({
    required this.episode,
    required this.primaryColor,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  State<_EpisodeBox> createState() => _EpisodeBoxState();
}

class _EpisodeBoxState extends State<_EpisodeBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isPlaying
                ? widget.primaryColor
                : (_isHovered
                      ? widget.primaryColor.withAlpha(100)
                      : widget.primaryColor.withAlpha(25)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (widget.isPlaying || _isHovered)
                  ? widget.primaryColor
                  : widget.primaryColor.withAlpha(50),
              width: 1,
            ),
            boxShadow: (widget.isPlaying || _isHovered)
                ? [
                    BoxShadow(
                      color: widget.primaryColor.withAlpha(100),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.episode.episodeNumber,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: (widget.isPlaying || _isHovered)
                    ? Colors.white
                    : widget.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
