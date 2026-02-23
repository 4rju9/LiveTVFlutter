import 'package:flutter/material.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';

class ChannelCard extends StatelessWidget {
  final LiveChannelEntity channel;
  final VoidCallback onTap;

  const ChannelCard({super.key, required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  channel.logo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(Icons.tv, color: theme.primaryColor),
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
                      channel.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(context, channel.quality),
                        const SizedBox(width: 8),
                        _buildBadge(
                          context,
                          channel.language,
                          isLanguage: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill, color: theme.primaryColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String text, {
    bool isLanguage = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (text.isEmpty || text == 'Multi') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isLanguage
            ? (isDark ? Colors.grey[800] : Colors.grey[200])
            : theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isLanguage
              ? Colors.transparent
              : theme.primaryColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isLanguage ? null : theme.primaryColor,
        ),
      ),
    );
  }
}
