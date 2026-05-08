part of 'rafeeq_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onLogin,
    required this.onSignUp,
    super.key,
  });

  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await widget.onLogin(
        emailController.text.trim(),
        passwordController.text,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: const AppHeader(
        title: 'تسجيل الدخول',
        icon: Icons.lock_rounded,
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.asset(
                'assets/images/login_elderly_couple.png',
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
                child: const Text(
                  'رعاية قريبة واطمئنان يومي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      
        const SizedBox(height: 24),
        CardPanel(
          child: Column(
            children: [
              AppTextField(
                label: 'البريد الإلكتروني',
                hint: 'name@example.com',
                icon: Icons.email_rounded,
                controller: emailController,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'كلمة المرور',
                hint: '********',
                icon: Icons.password_rounded,
                obscureText: true,
                controller: passwordController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: loading ? 'جار تسجيل الدخول...' : 'تسجيل الدخول',
          icon: Icons.login_rounded,
          onPressed: loading ? () {} : login,
          height: 72,
          fontSize: 22,
        ),
        const SizedBox(height: 22),
        TextButton(
          onPressed: loading ? null : widget.onSignUp,
          child: const Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
