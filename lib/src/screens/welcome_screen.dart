part of 'rafeeq_screens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onStart,
    required this.onCaregiver,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onCaregiver;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: const AppHeader(title: 'رفيق'),
      children: [
        const SizedBox(height: 24),
        const CircleIcon(
          icon: Icons.health_and_safety_rounded,
          size: 112,
          color: AppColors.primary,
          iconColor: Colors.white,
        ),
        const SizedBox(height: 28),
        const Text(
          'رفيق كبار السن',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        const Text(
          'متابعة الأدوية، الاطمئنان اليومي، وتنبيهات مقدم الرعاية في مكان واحد.',
          style: TextStyle(
            color: AppColors.outline,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 34),
        PrimaryButton(
          label: 'تسجيل دخول المستخدم',
          icon: Icons.person_rounded,
          onPressed: onStart,
          height: 72,
          fontSize: 22,
        ),
        const SizedBox(height: 14),
        SoftButton(
          label: 'دخول مقدم الرعاية',
          icon: Icons.supervisor_account_rounded,
          onPressed: onCaregiver,
          height: 66,
          fontSize: 20,
        ),
      ],
    );
  }
}
