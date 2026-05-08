part of 'rafeeq_widgets.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.title,
    required this.user,
    required this.time,
    required this.body,
    this.image,
    this.critical = false,
    super.key,
  });

  final String title;
  final String user;
  final String time;
  final String body;
  final String? image;
  final bool critical;

  @override
  Widget build(BuildContext context) {
    final background =
        critical ? AppColors.errorContainer : AppColors.surfaceHigh;
    final foreground =
        critical ? AppColors.onErrorContainer : AppColors.onSurface;

    return CardPanel(
      color: background,
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Chip(
                  avatar: Icon(
                    critical
                        ? Icons.medication_rounded
                        : Icons.notifications_rounded,
                    color: foreground,
                    size: 18,
                  ),
                  label: Text(title),
                  backgroundColor: Colors.white.withValues(alpha: 0.38),
                  labelStyle: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(color: foreground.withValues(alpha: 0.7)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AppNetworkImage(
                    image!,
                    height: 82,
                    width: 82,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المستخدم',
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.70),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user,
                      style: TextStyle(
                        color: foreground,
                        fontSize: critical ? 28 : 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: critical ? 0.30 : 0.70),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              body,
              style: TextStyle(
                color: critical ? foreground : AppColors.outline,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'اتصال',
            icon: Icons.phone_rounded,
            onPressed: () {},
            height: 58,
            fontSize: 16,
          ),
          const SizedBox(height: 10),
          SoftButton(
            label: critical ? 'تحديد كمحلول' : 'عرض التفاصيل',
            icon: critical ? Icons.check_circle_rounded : Icons.info_rounded,
            onPressed: () {},
            height: 54,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
