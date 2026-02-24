import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/core/theme/cubit/theme_cubit.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';
import 'package:live_tv/features/premium_auth/presentation/pages/premium_activation_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 50, color: theme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          BlocBuilder<PremiumCubit, PremiumState>(
            builder: (context, state) {
              bool isPremium = false;
              if (state is PremiumStatus) {
                isPremium = state.isPremium;
              }

              return Card(
                elevation: 0,
                color: isPremium
                    ? Colors.amber.withValues(alpha: 0.1)
                    : theme.primaryColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        isPremium ? Icons.workspace_premium : Icons.stars,
                        color: isPremium ? Colors.amber : theme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Plan",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              isPremium ? "Premium Activated" : "Free User",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isPremium)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PremiumActivationPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Upgrade"),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "App Theme",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, currentTheme) {
              final List<Color> themeColors = [
                const Color(0xFF00BEF7),
                Colors.brown,
              ];

              return Row(
                children: List.generate(themeColors.length, (index) {
                  final color = themeColors[index];
                  final isSelected = currentTheme.primaryColor == color;

                  return GestureDetector(
                    onTap: () {
                      context.read<ThemeCubit>().changeTheme(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
