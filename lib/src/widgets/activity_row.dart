part of 'rafeeq_widgets.dart';

class ActivityRow extends StatelessWidget {
  const ActivityRow(this.activity, {super.key});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    final icon = switch (activity.type) {
      ActivityType.checkIn => Icons.check_circle_rounded,
      ActivityType.activity => Icons.dashboard_rounded,
      ActivityType.sleep => Icons.schedule_rounded,
    };
    final color = switch (activity.type) {
      ActivityType.checkIn => AppColors.secondary,
      ActivityType.activity => AppColors.primary,
      ActivityType.sleep => AppColors.outline,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(
                  activity.description,
                  style:
                      const TextStyle(color: AppColors.outline, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: const TextStyle(
              color: AppColors.outline,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
