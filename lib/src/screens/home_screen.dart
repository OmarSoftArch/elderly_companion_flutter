part of 'rafeeq_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.doses,
    required this.checkedInToday,
    required this.userName,
    required this.careLinkCode,
    required this.onCheckIn,
    required this.onMedicationClick,
    required this.onTaken,
    required this.onPostpone,
    required this.onLogout,
    super.key,
  });

  final List<ScheduledDose> doses;
  final bool checkedInToday;
  final String userName;
  final String? careLinkCode;
  final VoidCallback onCheckIn;
  final ValueChanged<ScheduledDose> onMedicationClick;
  final ValueChanged<ScheduledDose> onTaken;
  final ValueChanged<ScheduledDose> onPostpone;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final orderedDoses = [...doses]..sort(_compareByDoseStatusThenTime);
    final pendingCount =
        doses.where((item) => item.status == MedicationStatus.pending).length;

    return AppScrollView(
      header: AppHeader(
        title: 'رفيق كبار السن',
        icon: Icons.account_circle,
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.outline),
          ),
        ],
      ),
      children: [
        const Text(
          'مرحباً',
          style: TextStyle(
            color: AppColors.outline,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 22),
        if (careLinkCode != null && careLinkCode!.isNotEmpty) ...[
          CardPanel(
            color: AppColors.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RowTitle(
                  icon: Icons.link_rounded,
                  title: 'رمز ربط مقدم الرعاية',
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  careLinkCode!,
                  style: const TextStyle(
                    color: AppColors.onSecondaryContainer,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'شارك هذا الرمز مع مقدم الرعاية الذي تثق به.',
                  style: TextStyle(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
        ],
        GradientPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تأكيد يومي',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هل تشعر أنك بخير؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: checkedInToday ? null : onCheckIn,
                icon: const Icon(Icons.check_circle_rounded, size: 34),
                label: Text(checkedInToday ? 'تم التأكيد اليوم' : 'أنا بخير'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(72),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 34),
        SectionTitle(
          title: 'أدوية اليوم',
          trailing: 'متبقي $pendingCount',
        ),
        const SizedBox(height: 16),
        if (orderedDoses.isEmpty)
          const CardPanel(
            child: Text(
              'لا توجد أدوية متبقية الآن.',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          ...orderedDoses.map(
            (dose) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MedicationCard(
                dose: dose,
                onTap: () => onMedicationClick(dose),
                onTaken: () => onTaken(dose),
                onPostpone: () => onPostpone(dose),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Center(
          child: Chip(
            avatar: const Icon(
              Icons.verified_rounded,
              color: AppColors.onSecondaryContainer,
            ),
            backgroundColor: AppColors.secondaryContainer,
            label: const Text(
              'روتينك اليومي قيد المتابعة',
              style: TextStyle(
                color: AppColors.onSecondaryContainer,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  int _compareByDoseStatusThenTime(ScheduledDose a, ScheduledDose b) {
    final statusComparison = _statusRank(a.status).compareTo(
      _statusRank(b.status),
    );
    if (statusComparison != 0) return statusComparison;
    return a.scheduledAt.compareTo(b.scheduledAt);
  }

  int _statusRank(MedicationStatus status) {
    return switch (status) {
      MedicationStatus.pending => 0,
      MedicationStatus.postponed => 1,
      MedicationStatus.missed => 2,
      MedicationStatus.taken => 3,
    };
  }
}
