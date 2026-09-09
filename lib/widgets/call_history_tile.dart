import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/call_time_formatter.dart';
import '../models/call_record.dart';
import 'user_avatar.dart';

class CallHistoryTile extends StatelessWidget {
  final CallRecord record;

  const CallHistoryTile({super.key, required this.record});

  bool get _isMissedOrRejected =>
      record.outcome == CallOutcome.missed || record.outcome == CallOutcome.rejected;

  IconData get _directionIcon {
    if (record.outcome == CallOutcome.missed) return Icons.call_missed_rounded;
    return record.direction == CallDirection.outgoing ? Icons.call_made_rounded : Icons.call_received_rounded;
  }

  String get _subtitle {
    final mediaLabel = record.mediaType == CallMediaType.video ? 'Video call' : 'Audio call';
    switch (record.outcome) {
      case CallOutcome.missed:
        return '$mediaLabel · Missed';
      case CallOutcome.rejected:
        return record.direction == CallDirection.outgoing ? '$mediaLabel · Declined' : '$mediaLabel · You declined';
      case CallOutcome.failed:
        return '$mediaLabel · Failed';
      case CallOutcome.completed:
        final direction = record.direction == CallDirection.outgoing ? 'Outgoing' : 'Incoming';
        return '$mediaLabel · $direction';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(name: record.peerName, photoUrl: record.peerPhotoUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.peerName, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      _directionIcon,
                      size: 14,
                      color: _isMissedOrRejected ? AppColors.missed : secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _subtitle,
                        style: AppTypography.caption.copyWith(
                          color: _isMissedOrRejected ? AppColors.missed : secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CallTimeFormatter.relativeDayAndTime(record.startedAt),
                style: AppTypography.caption.copyWith(color: secondaryText),
              ),
              if (record.outcome == CallOutcome.completed) ...[
                const SizedBox(height: 3),
                Text(
                  CallTimeFormatter.duration(record.duration),
                  style: AppTypography.caption.copyWith(color: secondaryText),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
