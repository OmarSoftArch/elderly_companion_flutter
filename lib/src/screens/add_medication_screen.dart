part of 'rafeeq_screens.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({
    required this.patientName,
    required this.onBack,
    required this.onSave,
    super.key,
  });

  final String patientName;
  final VoidCallback onBack;
  final ValueChanged<Medication> onSave;

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final times = <TimeOfDay>[const TimeOfDay(hour: 8, minute: 0)];
  DateTime startDate = DateTime.now();
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();
  final frequencyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    notesController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  void saveMedication() {
    final name = nameController.text.trim();
    final dosage = dosageController.text.trim();
    final notes = notesController.text.trim();
    final scheduledTimes = times
        .map(_formatTime)
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    if (scheduledTimes.isEmpty) scheduledTimes.add('08:00');

    final parsedFrequency = int.tryParse(frequencyController.text.trim());
    final dailyFrequency = parsedFrequency != null && parsedFrequency > 0
        ? parsedFrequency
        : scheduledTimes.length;

    widget.onSave(
      Medication(
        id: '',
        name: name.isEmpty ? 'دواء جديد' : name,
        dosage: dosage.isEmpty ? 'جرعة واحدة' : dosage,
        description: notes.isEmpty ? 'لم تتم إضافة ملاحظات' : notes,
        time: scheduledTimes.first,
        times: scheduledTimes,
        dailyFrequency: dailyFrequency,
        startDate: startDate,
        status: MedicationStatus.pending,
        category: 'دواء',
        instructions: notes.isEmpty ? const [] : [notes],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      header: AppHeader(
        title: 'إضافة دواء',
        leading: BackCircleButton(onPressed: widget.onBack),
      ),
      children: [
        CardPanel(
          color: AppColors.secondaryContainer,
          child: Row(
            children: [
              const CircleIcon(
                icon: Icons.person_rounded,
                color: AppColors.secondary,
                iconColor: Colors.white,
                size: 54,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سيتم إضافة الدواء إلى',
                      style: TextStyle(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.patientName,
                      style: const TextStyle(
                        color: AppColors.onSecondaryContainer,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        CardPanel(
          borderRadius: 28,
          child: Column(
            children: [
              AppTextField(
                label: 'اسم الدواء',
                hint: 'مثال: ليسينوبريل',
                controller: nameController,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'الجرعة',
                hint: 'مثال: قرص واحد 10 ملجم',
                controller: dosageController,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: Text('وقت الدواء', style: FieldLabelStyle()),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                times.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PickerField(
                          icon: Icons.schedule_rounded,
                          value: _formatTime(times[index]),
                          onTap: () => _pickTime(index),
                        ),
                      ),
                      if (times.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () => setState(() {
                            times.removeAt(index);
                            _syncFrequencyWithTimes();
                          }),
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  final last = times.last;
                  final nextMinutes = (last.hour * 60 + last.minute + 240) %
                      Duration.minutesPerDay;
                  times.add(
                    TimeOfDay(
                      hour: nextMinutes ~/ 60,
                      minute: nextMinutes % 60,
                    ),
                  );
                  _syncFrequencyWithTimes();
                }),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة وقت آخر'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'عدد المرات يومياً',
                hint: 'مرة واحدة',
                controller: frequencyController,
              ),
              const SizedBox(height: 18),
              _PickerField(
                label: 'تاريخ البدء',
                icon: Icons.calendar_today_rounded,
                value: _formatDate(startDate),
                onTap: _pickStartDate,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'ملاحظات اختيارية',
                hint: 'مثال: يؤخذ بعد الأكل مع كوب ماء',
                maxLines: 4,
                controller: notesController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'حفظ الدواء',
          icon: Icons.check_circle_rounded,
          onPressed: saveMedication,
          height: 76,
          fontSize: 24,
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

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _syncFrequencyWithTimes() {
    frequencyController.text = times.length.toString();
  }

  Future<void> _pickTime(int index) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: times[index],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
    if (selected == null) return;
    setState(() => times[index] = selected);
  }

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (selected == null) return;
    setState(() => startDate = selected);
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.onTap,
    this.label,
    this.icon,
  });

  final String? label;
  final IconData? icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: FieldLabelStyle()),
          const SizedBox(height: 8),
        ],
        Material(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.outline),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
