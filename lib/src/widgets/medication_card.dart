part of 'rafeeq_widgets.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.dose,
    required this.onTap,
    required this.onTaken,
    required this.onPostpone,
    super.key,
  });

  final ScheduledDose dose;
  final VoidCallback onTap;
  final VoidCallback onTaken;
  final VoidCallback onPostpone;

  @override
  Widget build(BuildContext context) {
    final medication = dose.medication;

    return CardPanel(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleIcon(icon: Icons.medication_rounded),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${medication.category} - ${medication.description}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.outline,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DosePill(
                      icon: Icons.schedule_rounded,
                      label: dose.scheduledTime,
                      color: AppColors.primary,
                    ),
                    _DosePill(
                      label: _statusLabel(dose.status),
                      color: _statusColor(dose.status),
                    ),
                  ],
                ),
                if (medication.scheduledTimes.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'هذه جرعة ${dose.scheduledTime} من ${medication.scheduledTimes.length} جرعات اليوم',
                    style: const TextStyle(
                      color: AppColors.outline,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (dose.isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTaken,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('تم التناول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(64),
                      textStyle: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPostpone,
                    icon: const Icon(Icons.schedule_rounded),
                    label: const Text('تأجيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceHighest,
                      foregroundColor: AppColors.outline,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(64),
                      textStyle: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: _statusColor(dose.status).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusLabel(dose.status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusColor(dose.status),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(MedicationStatus status) {
    return switch (status) {
      MedicationStatus.taken => AppColors.secondary,
      MedicationStatus.postponed => AppColors.tertiary,
      MedicationStatus.missed => AppColors.error,
      MedicationStatus.pending => AppColors.primary,
    };
  }

  String _statusLabel(MedicationStatus status) {
    return switch (status) {
      MedicationStatus.taken => 'تم التناول',
      MedicationStatus.postponed => 'مؤجلة',
      MedicationStatus.missed => 'فائتة',
      MedicationStatus.pending => 'بانتظار التأكيد',
    };
  }
}

class _DosePill extends StatelessWidget {
  const _DosePill({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
