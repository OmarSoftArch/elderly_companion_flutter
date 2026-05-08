part of 'rafeeq_screens.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.doses,
    required this.onBack,
    super.key,
  });

  final List<ScheduledDose> doses;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final completed = doses
        .where((item) => item.status != MedicationStatus.pending)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final takenCount =
        doses.where((item) => item.status == MedicationStatus.taken).length;
    final adherence =
        doses.isEmpty ? 0 : ((takenCount / doses.length) * 100).round();
    final pending = doses
        .where((item) => item.status == MedicationStatus.pending)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final nextDose = pending.isEmpty ? null : pending.first;

    return AppScrollView(
      header: AppHeader(
        title: 'رفيق كبار السن',
        leading: BackCircleButton(onPressed: onBack),
        icon: Icons.account_circle,
      ),
      children: [
        const Text(
          'تاريخ الأدوية',
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'راجع حالة الجرعات خلال اليوم.',
          style: TextStyle(
            color: AppColors.outline,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 26),
        CardPanel(
          color: AppColors.secondaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.onSecondaryContainer,
                size: 58,
              ),
              const SizedBox(height: 34),
              Text(
                '$adherence%',
                style: const TextStyle(
                  color: AppColors.onSecondaryContainer,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'معدل الالتزام',
                style: TextStyle(
                  color: AppColors.onSecondaryContainer,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CardPanel(
          color: AppColors.primary.withValues(alpha: 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الجرعة القادمة',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nextDose?.scheduledTime ?? '--',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              RowTitle(
                icon: Icons.medication_rounded,
                title: nextDose?.medication.name ?? 'لا توجد جرعات قادمة',
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('الجرعات المسجلة', style: SectionHeaderStyle()),
        const SizedBox(height: 16),
        if (completed.isEmpty)
          const CardPanel(
            child: Text(
              'لا توجد جرعات مكتملة أو مؤجلة حتى الآن.',
              style: TextStyle(
                color: AppColors.outline,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          ...completed.map(
            (dose) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: HistoryItem(
                time: dose.scheduledTime,
                name: dose.medication.name,
                status: dose.status,
              ),
            ),
          ),
        const SizedBox(height: 30),
        PrimaryButton(
          label: 'تحميل التقرير الكامل',
          onPressed: () => _showFullReport(context, adherence),
        ),
      ],
    );
  }

  void _showFullReport(BuildContext context, int adherence) {
    final report = _buildReport(adherence);

    showDialog<void>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تقرير المتابعة اليومي',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                report,
                style: const TextStyle(
                  height: 1.55,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  String _buildReport(int adherence) {
    final now = DateTime.now();
    final sortedDoses = [...doses]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final total = sortedDoses.length;
    final taken = sortedDoses
        .where((dose) => dose.status == MedicationStatus.taken)
        .length;
    final postponed = sortedDoses
        .where((dose) => dose.status == MedicationStatus.postponed)
        .length;
    final missed = sortedDoses
        .where((dose) => dose.status == MedicationStatus.missed)
        .length;
    final pending = sortedDoses
        .where((dose) => dose.status == MedicationStatus.pending)
        .length;

    final lines = <String>[
      'تاريخ التقرير: ${_formatDate(now)}',
      'معدل الالتزام: $adherence%',
      'إجمالي جرعات اليوم: $total',
      'تم التناول: $taken',
      'مؤجلة: $postponed',
      'فائتة: $missed',
      'بانتظار التأكيد: $pending',
      '',
      'تفاصيل الجرعات:',
    ];

    if (sortedDoses.isEmpty) {
      lines.add('لا توجد جرعات مجدولة لهذا اليوم.');
    } else {
      for (final dose in sortedDoses) {
        lines.add(
          '${dose.scheduledTime} - ${dose.medication.name} - ${dose.medication.dosage} - ${_statusLabel(dose.status)}',
        );
      }
    }

    return lines.join('\n');
  }

  String _statusLabel(MedicationStatus status) {
    return switch (status) {
      MedicationStatus.taken => 'تم التناول',
      MedicationStatus.postponed => 'مؤجلة',
      MedicationStatus.missed => 'فائتة',
      MedicationStatus.pending => 'بانتظار التأكيد',
    };
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
