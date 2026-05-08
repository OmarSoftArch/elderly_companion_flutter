part of 'rafeeq_widgets.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
    this.controller,
    this.onChanged,
    super.key,
  });

  final String? label;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final int maxLines;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: FieldLabelStyle()),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          obscureText: obscureText,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon == null ? null : Icon(icon, color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class FieldLabelStyle extends TextStyle {
  const FieldLabelStyle()
      : super(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        );
}

class ActionTextStyle extends TextStyle {
  const ActionTextStyle()
      : super(
          color: AppColors.outline,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        );
}

class SectionHeaderStyle extends TextStyle {
  const SectionHeaderStyle()
      : super(
          color: AppColors.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        );
}
