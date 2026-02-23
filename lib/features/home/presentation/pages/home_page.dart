import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';
import 'package:live_tv/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_tv/features/home/presentation/widgets/channel_card.dart';
import 'package:live_tv/features/home/presentation/widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchChannels();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sports':
        return Icons.sports_soccer;
      case 'news':
        return Icons.article;
      case 'entertainment':
        return Icons.movie;
      case 'music':
        return Icons.music_note;
      case 'anime':
        return Icons.animation;
      default:
        return Icons.tv;
    }
  }

  Widget _buildChannelList(List<LiveChannelEntity> channels) {
    return ListView.builder(
      itemCount: channels.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return ChannelCard(
          channel: channel,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Playing: ${channel.title}")),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  } else if (state is HomeLoaded) {
                    final categories = state.channelsMap.keys.toList()..sort();

                    if (categories.isEmpty) {
                      return const Center(child: Text("No channels found."));
                    }

                    if (_selectedIndex >= categories.length) {
                      _selectedIndex = 0;
                    }

                    final currentCategory = categories[_selectedIndex];
                    final currentChannels = state.channelsMap[currentCategory]!;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 800) {
                          return Row(
                            children: [
                              NavigationRail(
                                selectedIndex: _selectedIndex,
                                onDestinationSelected: (int index) {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                                labelType: NavigationRailLabelType.all,
                                selectedIconTheme: IconThemeData(
                                  color: theme.primaryColor,
                                ),
                                selectedLabelTextStyle: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                destinations: categories.map((category) {
                                  return NavigationRailDestination(
                                    icon: Icon(_getCategoryIcon(category)),
                                    label: Text(category),
                                  );
                                }).toList(),
                              ),
                              const VerticalDivider(thickness: 1, width: 1),
                              Expanded(
                                child: _buildChannelList(currentChannels),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Expanded(
                                child: _buildChannelList(currentChannels),
                              ),
                              BottomNavigationBar(
                                currentIndex: _selectedIndex,
                                onTap: (int index) {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                                type: BottomNavigationBarType.fixed,
                                selectedItemColor: theme.primaryColor,
                                unselectedItemColor: Colors.grey,
                                items: categories.map((category) {
                                  return BottomNavigationBarItem(
                                    icon: Icon(_getCategoryIcon(category)),
                                    label: category,
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
