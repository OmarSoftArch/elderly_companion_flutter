part of 'rafeeq_screens.dart';

class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({
    required this.medication,
    required this.onBack,
    required this.onTaken,
    required this.onPostpone,
    super.key,
  });

  final Medication medication;
  final VoidCallback onBack;
  final ValueChanged<Medication> onTaken;
  final ValueChanged<Medication> onPostpone;

  @override
  Widget build(BuildContext context) {
    final med = medication;

    return AppScrollView(
      header: AppHeader(
        title: 'تفاصيل الدواء',
        leading: BackCircleButton(onPressed: onBack),
        icon: Icons.account_circle,
      ),
      children: [
        const Center(
          child: CircleIcon(icon: Icons.medication_rounded, size: 96),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'الدواء الحالي',
            style: TextStyle(
              color: AppColors.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            med.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: StatusPill(label: 'تنبيه نشط')),
        const SizedBox(height: 30),
        DetailTile(
          icon: Icons.medication_rounded,
          title: 'الجرعة',
          value: med.dosage,
          body: med.description,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        DetailTile(
          icon: Icons.schedule_rounded,
          title: 'الجدول',
          value: med.scheduleLabel,
          body: _scheduleBody(med),
          color: AppColors.tertiary,
        ),
        const SizedBox(height: 16),
        CardPanel(
          color: AppColors.surfaceLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RowTitle(
                icon: Icons.info_rounded,
                title: 'تعليمات خاصة',
              ),
              const SizedBox(height: 12),
              if (med.instructions.isEmpty)
                const Text(
                  'لا توجد تعليمات إضافية.',
                  style: TextStyle(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                ...med.instructions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RoundedListItem(
                      icon: Icons.check_circle_rounded,
                      label: item,
                      iconColor: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (med.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                AppNetworkImage(
                  med.image!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: Colors.black.withValues(alpha: 0.55),
                  child: const Text(
                    'تحقق من شكل الدواء قبل تناوله.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: 'تأكيد الجرعة',
          icon: Icons.check_circle_rounded,
          onPressed: () => onTaken(med),
          height: 86,
          fontSize: 26,
        ),
        const SizedBox(height: 14),
        SoftButton(
          label: 'تأجيل الجرعة',
          icon: Icons.alarm_rounded,
          onPressed: () => onPostpone(med),
          height: 74,
          fontSize: 21,
        ),
      ],
    );
  }

  String _scheduleBody(Medication medication) {
    final parts = <String>[];
    if (medication.dailyFrequency != null) {
      parts.add('${medication.dailyFrequency} مرات يومياً');
    }
    if (medication.startDate != null) {
      parts.add('يبدأ من ${_formatDate(medication.startDate!)}');
    }
    return parts.isEmpty ? 'حسب الوقت المحدد' : parts.join(' - ');
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
