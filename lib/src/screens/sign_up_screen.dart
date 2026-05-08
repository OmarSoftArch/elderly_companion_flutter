part of 'rafeeq_screens.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    required this.onBack,
    required this.onCreateAccount,
    super.key,
  });

  final VoidCallback onBack;
  final Future<void> Function({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) onCreateAccount;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  UserRole role = UserRole.elderly;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await widget.onCreateAccount(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: role,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: AppHeader(
        title: 'إنشاء حساب',
        leading: BackCircleButton(onPressed: widget.onBack),
        icon: Icons.person_add_rounded,
      ),
      children: [
        const Text(
          'ابدأ باستخدام رفيق',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'اختر نوع الحساب بدقة؛ ستظهر لك الواجهة المناسبة بعد الإنشاء.',
          style: TextStyle(
            color: AppColors.outline,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        CardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'نوع الحساب',
                style: FieldLabelStyle(),
              ),
              const SizedBox(height: 10),
              SegmentedButton<UserRole>(
                segments: const [
                  ButtonSegment(
                    value: UserRole.elderly,
                    label: Text('مستخدم مسن'),
                    icon: Icon(Icons.person_rounded),
                  ),
                  ButtonSegment(
                    value: UserRole.caregiver,
                    label: Text('مقدم رعاية'),
                    icon: Icon(Icons.supervisor_account_rounded),
                  ),
                ],
                selected: {role},
                onSelectionChanged: (selection) {
                  setState(() => role = selection.first);
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'الاسم',
                hint: 'اكتب الاسم الكامل',
                icon: Icons.badge_rounded,
                controller: nameController,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'البريد الإلكتروني',
                hint: 'name@example.com',
                icon: Icons.email_rounded,
                controller: emailController,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'كلمة المرور',
                hint: 'ستة أحرف على الأقل',
                icon: Icons.password_rounded,
                obscureText: true,
                controller: passwordController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: loading ? 'جار إنشاء الحساب...' : 'إنشاء الحساب',
          icon: Icons.check_circle_rounded,
          onPressed: loading ? () {} : createAccount,
          height: 72,
          fontSize: 22,
        ),
        const SizedBox(height: 14),
        SoftButton(
          label: 'لدي حساب بالفعل',
          onPressed: widget.onBack,
          height: 62,
          fontSize: 19,
        ),
      ],
    );
  }
}
