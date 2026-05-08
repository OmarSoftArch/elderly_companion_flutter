part of 'rafeeq_screens.dart';

class CaregiverAlerts extends StatelessWidget {
  const CaregiverAlerts({
    required this.alerts,
    required this.patientName,
    required this.onBack,
    super.key,
  });

  final List<CaregiverAlert> alerts;
  final String patientName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: AppHeader(
        title: 'تنبيهات مقدم الرعاية',
        leading: BackCircleButton(onPressed: onBack),
        icon: Icons.notifications_rounded,
      ),
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 14,
              color: alerts.isEmpty ? AppColors.secondary : AppColors.error,
            ),
            const SizedBox(width: 10),
            Text(
              alerts.isEmpty ? 'لا توجد تنبيهات نشطة' : 'تنبيهات نشطة',
              style: TextStyle(
                color: alerts.isEmpty ? AppColors.secondary : AppColors.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          alerts.isEmpty ? 'كل شيء مستقر' : 'مطلوب انتباه',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        if (alerts.isEmpty)
          const CardPanel(
            child: Text(
              'ستظهر هنا التنبيهات المهمة عند الحاجة إلى المتابعة.',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: AlertCard(
                critical: alert.type == AlertType.missedMedication,
                title: _alertTitle(alert.type),
                user: patientName,
                time: _formatDate(alert.createdAt),
                body: alert.message,
              ),
            ),
          ),
      ],
    );
  }

  String _alertTitle(AlertType type) {
    return switch (type) {
      AlertType.missedMedication => 'تنبيه جرعة فائتة',
      AlertType.inactivity => 'تنبيه عدم نشاط',
      AlertType.checkIn => 'تنبيه اطمئنان',
    };
  }

  String _formatDate(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
