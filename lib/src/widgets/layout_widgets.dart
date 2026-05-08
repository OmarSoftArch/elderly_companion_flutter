part of 'rafeeq_widgets.dart';

class AppScrollView extends StatelessWidget {
  const AppScrollView({required this.children, this.header, super.key});

  final Widget? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (header != null) header!,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 118),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class ScreenPadding extends StatelessWidget {
  const ScreenPadding({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
      child: child,
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.leading,
    this.icon,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget? leading;
  final IconData? icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class BackCircleButton extends StatelessWidget {
  const BackCircleButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_forward_rounded),
      color: AppColors.outline,
      style: IconButton.styleFrom(backgroundColor: AppColors.surfaceHigh),
    );
  }
}
