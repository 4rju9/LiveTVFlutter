import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';
import 'package:live_tv/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_tv/features/home/presentation/pages/anime_details_page.dart';
import 'package:live_tv/features/home/presentation/pages/live_tv_player_page.dart';
import 'package:live_tv/features/home/presentation/widgets/anime_section.dart';
import 'package:live_tv/features/home/presentation/widgets/channel_card.dart';
import 'package:live_tv/features/home/presentation/widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  late PageController _pageController;

  final List<String> _categories = [
    'Sports',
    'Entertainment',
    'Anime',
    'Music',
    'News',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    context.read<HomeCubit>().fetchChannels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  IconData _getIcon(String category) {
    switch (category) {
      case 'Sports':
        return Icons.sports_soccer;
      case 'Entertainment':
        return Icons.movie;
      case 'Anime':
        return Icons.animation;
      case 'Music':
        return Icons.music_note;
      case 'News':
        return Icons.article;
      default:
        return Icons.tv;
    }
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);

    return Column(
      children: [
        const HomeHeader(),
        Expanded(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeCubit>().fetchChannels();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state is AnimeSearchLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AnimeSearchLoaded) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.results.length,
                  itemBuilder: (context, i) {
                    final anime = state.results[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimeDetailsPage(animeId: anime.id),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              anime.poster, 
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.error),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black.withValues(alpha: 0.7),
                                child: Text(
                                  anime.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is HomeLoaded) {
                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final categoryName = _categories[index];

                    if (categoryName.toLowerCase() == 'anime') {
                      if (state.animeData != null) {
                        return AnimeSection(animeData: state.animeData!);
                      } else {
                        return Center(
                          child: Text(
                            "Anime data not available",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                    }

                    final mapKey = state.channelsMap.keys.firstWhere(
                      (k) => k.toLowerCase() == categoryName.toLowerCase(),
                      orElse: () => '',
                    );

                    final channels = mapKey.isNotEmpty
                        ? state.channelsMap[mapKey]!
                        : <LiveChannelEntity>[];

                    if (channels.isEmpty) {
                      return Center(
                        child: Text(
                          "Content coming soon for $categoryName",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: channels.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, i) {
                        final channel = channels[i];
                        return ChannelCard(
                          channel: channel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LiveTvPlayerPage(
                                  url: channel.url,
                                  name: channel.title,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onNavTapped,
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: IconThemeData(color: theme.primaryColor),
                    selectedLabelTextStyle: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    destinations: _categories.map((category) {
                      return NavigationRailDestination(
                        icon: Icon(_getIcon(category)),
                        label: Text(category),
                      );
                    }).toList(),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: _buildMainContent()),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            body: SafeArea(child: _buildMainContent()),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: theme.primaryColor,
              unselectedItemColor: Colors.grey,
              items: _categories.map((category) {
                return BottomNavigationBarItem(
                  icon: Icon(_getIcon(category)),
                  label: category,
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
