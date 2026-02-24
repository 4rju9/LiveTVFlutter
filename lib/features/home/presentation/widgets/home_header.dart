import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_tv/features/profile/presentation/pages/profile_page.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Text(
                'Watch Now',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.primaryColor.withValues(alpha: 0.15)
                    : theme.primaryColorDark.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                style: TextStyle(color: theme.primaryColor),
                onChanged: (value) {
                  // Only search if we are on the Anime tab or if you want global search
                  context.read<HomeCubit>().executeAnimeSearch(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search anime...',
                  hintStyle: TextStyle(color: theme.primaryColor),
                  prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
