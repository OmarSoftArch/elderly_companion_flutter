part of 'rafeeq_screens.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({
    required this.activities,
    required this.alerts,
    required this.patients,
    required this.patientName,
    required this.selectedPatientId,
    required this.isLinked,
    required this.onPatientSelected,
    required this.onAlertsClick,
    required this.onAddElderlyClick,
    required this.onAddMedicationClick,
    required this.onLogout,
    super.key,
  });

  final List<ActivityLog> activities;
  final List<CaregiverAlert> alerts;
  final List<AppUser> patients;
  final String patientName;
  final String? selectedPatientId;
  final bool isLinked;
  final ValueChanged<AppUser> onPatientSelected;
  final VoidCallback onAlertsClick;
  final VoidCallback onAddElderlyClick;
  final VoidCallback onAddMedicationClick;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: AppHeader(
        title: 'لوحة مقدم الرعاية',
        icon: Icons.account_circle,
        actions: [
          IconButton(
            tooltip: 'إضافة مسن',
            onPressed: onAddElderlyClick,
            icon:
                const Icon(Icons.person_add_rounded, color: AppColors.primary),
          ),
          IconButton(
            tooltip: 'إضافة دواء',
            onPressed: onAddMedicationClick,
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.outline),
          ),
        ],
      ),
      children: [
        GradientPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusPill(
                label: 'المتابعة نشطة',
                icon: Icons.verified_user_rounded,
                light: true,
              ),
              const SizedBox(height: 22),
              Text(
                !isLinked
                    ? 'أضف أول مسن'
                    : alerts.isEmpty
                        ? '$patientName بخير حالياً.'
                        : 'يوجد تنبيه يحتاج انتباهك.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                !isLinked
                    ? 'أدخل رمز الربط الخاص بالمسن لبدء المتابعة.'
                    : alerts.isEmpty
                        ? 'لا توجد تنبيهات نشطة الآن.'
                        : alerts.first.message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SmallActionButton(
                    label: 'إضافة مسن',
                    icon: Icons.person_add_rounded,
                    onPressed: onAddElderlyClick,
                  ),
                  SmallActionButton(
                    label: 'إضافة دواء',
                    icon: Icons.medication_rounded,
                    onPressed: onAddMedicationClick,
                    transparent: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'المسنون المرتبطون'),
        const SizedBox(height: 14),
        if (patients.isEmpty)
          const CardPanel(
            child: Text(
              'لا توجد حسابات مسنين مرتبطة بعد.',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          CardPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: patients
                  .map(
                    (patient) {
                      final selected = patient.id == selectedPatientId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.secondary
                                : AppColors.surfaceHighest,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleIcon(
                            icon: Icons.person_rounded,
                            size: 44,
                            color: selected
                                ? AppColors.secondary
                                : AppColors.surfaceHighest,
                            iconColor:
                                selected ? Colors.white : AppColors.outline,
                          ),
                          title: Text(
                            patient.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(
                            selected
                                ? 'المسن المحدد حالياً'
                                : patient.email ?? 'حساب مسن',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.onSecondaryContainer
                                  : AppColors.outline,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                          trailing: selected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.secondary,
                                )
                              : const Icon(Icons.chevron_left_rounded),
                          onTap: () => onPatientSelected(patient),
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 18),
        CardPanel(
          color: AppColors.primary.withValues(alpha: 0.08),
          child: Row(
            children: [
              const CircleIcon(
                icon: Icons.medication_rounded,
                size: 54,
                color: AppColors.primary,
                iconColor: Colors.white,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أي دواء جديد سيضاف إلى',
                      style: TextStyle(
                        color: AppColors.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isLinked ? patientName : 'اختر مسناً أولاً',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'أدوية اليوم',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'متابعة',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: ' الالتزام',
                      style: TextStyle(
                        color: AppColors.outline,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'تابع جرعات اليوم وتأكد أن الروتين يسير بهدوء.',
                style: TextStyle(color: AppColors.outline, fontSize: 16),
              ),
              SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(999)),
                child: LinearProgressIndicator(
                  value: 0.95,
                  minHeight: 14,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.surfaceHighest,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const RowTitle(
          icon: Icons.warning_rounded,
          title: 'تنبيهات حرجة',
          color: AppColors.error,
          size: 25,
        ),
        const SizedBox(height: 16),
        if (alerts.isEmpty)
          const CardPanel(
            child: Text(
              'لا توجد تنبيهات نشطة حالياً.',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          InkWell(
            onTap: onAlertsClick,
            borderRadius: BorderRadius.circular(12),
            child: CardPanel(
              color: AppColors.errorContainer.withValues(alpha: 0.45),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleIcon(
                    icon: Icons.warning_rounded,
                    color: AppColors.error,
                    iconColor: Colors.white,
                    size: 50,
                    radius: 12,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تنبيه نشط',
                          style: TextStyle(
                            color: AppColors.onErrorContainer,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alerts.first.message,
                          style: const TextStyle(
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'عرض التنبيهات',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 30),
        const SectionTitle(
          title: 'النشاط الأخير',
          trailing: 'يتم تحديثه تلقائياً',
        ),
        const SizedBox(height: 16),
        CardPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: activities.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'لا يوجد نشاط مسجل حتى الآن.',
                        style: TextStyle(
                          color: AppColors.outline,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ]
                : activities.map(ActivityRow.new).toList(),
          ),
        ),
      ],
    );
  }
}
