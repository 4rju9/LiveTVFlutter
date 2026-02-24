import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/presentation/cubit/anime_details_cubit.dart';
import 'package:live_tv/features/player/presentation/cubit/player_cubit.dart';
import 'package:live_tv/features/player/presentation/widgets/custom_video_player.dart';
import 'package:live_tv/init_dependencies.dart';

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

  String _getEpisodeNumber(String? episodeId) {
    if (episodeId == null) return "1";
    try {
      final ep = _allEpisodes.firstWhere((e) => e.id == episodeId);
      return ep.episodeNumber;
    } catch (_) {
      return "1";
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocProvider(
      create: (context) => sl<AnimeDetailsCubit>()..fetchAnimeDetails(widget.animeId),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<AnimeDetailsCubit, AnimeDetailsState>(
            listener: (context, state) {
              if (state is AnimeDetailsLoaded) {
                _allEpisodes = state.details.episodes;
                _filteredEpisodes = _allEpisodes;

                if (_allEpisodes.isNotEmpty && _currentPlayingEpisodeId == null) {
                  _currentPlayingEpisodeId = _allEpisodes.first.id;
                  context.read<PlayerCubit>().loadAnimeEpisode(
                    _allEpisodes.first.id,
                    state.details.anime.title,
                  );
                }
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
                      expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
                      pinned: false,
                      automaticallyImplyLeading: true,
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
                              errorBuilder: (context, error, stackTrace) => Container(color: theme.colorScheme.surfaceContainerHighest),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<PlayerCubit, PlayerState>(
                            builder: (context, pState) {
                              if (pState is PlayerLoaded && pState.servers != null) {
                                final servers = pState.servers!;
                                final activeServer = pState.activeServer;

                                return Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      color: theme.colorScheme.primaryContainer,
                                      child: Column(
                                        children: [
                                          Text(
                                            "Now Watching:",
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                          Text(
                                            "${details.anime.title} Episode ${_getEpisodeNumber(_currentPlayingEpisodeId)}",
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                          Text(
                                            "If current server doesn't work please try other servers beside.",
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      child: Column(
                                        children: [
                                          if (servers.sub.isNotEmpty)
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.subtitles, size: 20, color: theme.colorScheme.onSurfaceVariant),
                                                const SizedBox(width: 8),
                                                Text("SUB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurfaceVariant)),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: servers.sub.map((server) {
                                                      final isActive = activeServer?.dataId == server.dataId;
                                                      return InkWell(
                                                        onTap: () {
                                                          if (!isActive) {
                                                            context.read<PlayerCubit>().changeServer(
                                                              _currentPlayingEpisodeId!,
                                                              details.anime.title,
                                                              servers,
                                                              server,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            server.serverName,
                                                            style: TextStyle(
                                                              color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (servers.sub.isNotEmpty && servers.dub.isNotEmpty)
                                            const SizedBox(height: 12),
                                          if (servers.dub.isNotEmpty)
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.record_voice_over, size: 20, color: theme.colorScheme.onSurfaceVariant),
                                                const SizedBox(width: 8),
                                                Text("DUB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurfaceVariant)),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: servers.dub.map((server) {
                                                      final isActive = activeServer?.dataId == server.dataId;
                                                      return InkWell(
                                                        onTap: () {
                                                          if (!isActive) {
                                                            context.read<PlayerCubit>().changeServer(
                                                              _currentPlayingEpisodeId!,
                                                              details.anime.title,
                                                              servers,
                                                              server,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            server.serverName,
                                                            style: TextStyle(
                                                              color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink(); 
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    details.anime.poster,
                                    width: 120,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 120,
                                        height: 180,
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Center(child: Icon(Icons.broken_image)),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        details.anime.title,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        details.anime.description,
                                        maxLines: 7,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "List of Episodes:",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  height: 36,
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterEpisodes,
                                    keyboardType: TextInputType.number,
                                    style: theme.textTheme.bodyMedium,
                                    decoration: InputDecoration(
                                      hintText: 'Number of Ep',
                                      prefixIcon: const Icon(Icons.search, size: 18),
                                      filled: true,
                                      fillColor: theme.colorScheme.surfaceContainerHighest,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final episode = _filteredEpisodes[index];
                          final isPlaying = _currentPlayingEpisodeId == episode.id;
                          final isEven = index % 2 == 0;
                          
                          return InkWell(
                            onTap: () {
                              setState(() => _currentPlayingEpisodeId = episode.id);
                              context.read<PlayerCubit>().loadAnimeEpisode(
                                episode.id,
                                details.anime.title,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              color: isPlaying 
                                  ? theme.colorScheme.primaryContainer 
                                  : (isEven ? theme.colorScheme.surfaceContainer : Colors.transparent),
                              child: Text(
                                "${episode.episodeNumber}  ${details.anime.title} Episode ${episode.episodeNumber}",
                                style: TextStyle(
                                  color: isPlaying ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _filteredEpisodes.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
