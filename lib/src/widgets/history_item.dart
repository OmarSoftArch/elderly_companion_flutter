part of 'rafeeq_widgets.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    required this.time,
    required this.name,
    required this.status,
    super.key,
  });

  final String time;
  final String name;
  final MedicationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MedicationStatus.taken => AppColors.secondary,
      MedicationStatus.missed => AppColors.error,
      MedicationStatus.postponed => AppColors.tertiary,
      MedicationStatus.pending => AppColors.outline,
    };
    final label = switch (status) {
      MedicationStatus.taken => 'تم التناول',
      MedicationStatus.missed => 'فائتة',
      MedicationStatus.postponed => 'مؤجلة',
      MedicationStatus.pending => 'بانتظار',
    };

    return CardPanel(
      child: Row(
        children: [
          CircleIcon(
            icon: Icons.medication_rounded,
            color: color,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(label),
            backgroundColor: color.withValues(alpha: 0.14),
            labelStyle: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
