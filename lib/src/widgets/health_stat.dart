part of 'rafeeq_widgets.dart';

class HealthStat extends StatelessWidget {
  const HealthStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CardPanel(
        color: AppColors.surfaceLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.outline,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: unit.isEmpty ? '' : ' $unit',
                    style: const TextStyle(
                      color: AppColors.outline,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
