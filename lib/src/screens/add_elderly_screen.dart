part of 'rafeeq_screens.dart';

class AddElderlyScreen extends StatefulWidget {
  const AddElderlyScreen({
    required this.onBack,
    required this.onLink,
    super.key,
  });

  final VoidCallback onBack;
  final Future<void> Function(String code) onLink;

  @override
  State<AddElderlyScreen> createState() => _AddElderlyScreenState();
}

class _AddElderlyScreenState extends State<AddElderlyScreen> {
  final codeController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> link() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await widget.onLink(codeController.text);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: AppHeader(
        title: 'إضافة مسن',
        leading: BackCircleButton(onPressed: widget.onBack),
        icon: Icons.person_add_rounded,
      ),
      children: [
        const Text(
          'أدخل رمز الربط',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'احصل على الرمز من حساب المسن ثم أدخله هنا لإضافته إلى قائمة الرعاية.',
          style: TextStyle(
            color: AppColors.outline,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        CardPanel(
          child: AppTextField(
            label: 'رمز الربط',
            hint: 'RFQ-123456',
            icon: Icons.link_rounded,
            controller: codeController,
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: loading ? 'جار الربط...' : 'إضافة المسن',
          icon: Icons.check_circle_rounded,
          onPressed: loading ? () {} : link,
          height: 72,
          fontSize: 22,
        ),
        const SizedBox(height: 14),
        SoftButton(
          label: 'إلغاء',
          onPressed: widget.onBack,
          height: 62,
          fontSize: 20,
        ),
      ],
    );
  }
}
