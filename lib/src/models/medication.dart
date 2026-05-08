import 'medication_status.dart';

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.description,
    required this.time,
    required this.status,
    required this.category,
    required this.instructions,
    this.times = const [],
    this.dailyFrequency,
    this.startDate,
    this.image,
  });

  final String id;
  final String name;
  final String dosage;
  final String description;
  final String time;
  final MedicationStatus status;
  final String category;
  final List<String> instructions;
  final List<String> times;
  final int? dailyFrequency;
  final DateTime? startDate;
  final String? image;

  List<String> get scheduledTimes {
    final values = times.isEmpty ? [time] : times;
    return values
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  String get scheduleLabel => scheduledTimes.join('، ');

  int minutesUntilNextDose([DateTime? from]) {
    final reference = from ?? DateTime.now();
    final nowMinutes = reference.hour * 60 + reference.minute;
    final dayMinutes = const Duration(days: 1).inMinutes;

    final offsets = scheduledTimes
        .map(_parseTime)
        .whereType<int>()
        .map((minutes) => (minutes - nowMinutes + dayMinutes) % dayMinutes)
        .toList();

    if (offsets.isEmpty) return dayMinutes;
    offsets.sort();
    return offsets.first;
  }

  String get nextDoseTime {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final dayMinutes = const Duration(days: 1).inMinutes;

    final upcoming = scheduledTimes
        .map((time) => MapEntry(time, _parseTime(time)))
        .where((entry) => entry.value != null)
        .map(
          (entry) => MapEntry(
            entry.key,
            (entry.value! - nowMinutes + dayMinutes) % dayMinutes,
          ),
        )
        .toList();

    if (upcoming.isEmpty) {
      return scheduledTimes.isEmpty ? time : scheduledTimes.first;
    }
    upcoming.sort((a, b) => a.value.compareTo(b.value));
    return upcoming.first.key;
  }

  static int? _parseTime(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  factory Medication.fromMap(String id, Map<String, dynamic> data) {
    final savedTime = data['time'] as String? ?? '';
    final savedTimes = (data['times'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
    final startDateValue = data['startDate'];

    return Medication(
      id: id,
      name: data['name'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      description: data['description'] as String? ?? '',
      time: savedTime,
      status: MedicationStatus.values.firstWhere(
        (item) => item.name == data['status'],
        orElse: () => MedicationStatus.pending,
      ),
      category: data['category'] as String? ?? '',
      instructions: (data['instructions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      times:
          savedTimes.isEmpty && savedTime.isNotEmpty ? [savedTime] : savedTimes,
      dailyFrequency: data['dailyFrequency'] is int
          ? data['dailyFrequency'] as int
          : int.tryParse(data['dailyFrequency']?.toString() ?? ''),
      startDate: startDateValue is DateTime
          ? startDateValue
          : DateTime.tryParse(startDateValue?.toString() ?? ''),
      image: data['image'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedTimes = scheduledTimes;

    return {
      'name': name,
      'dosage': dosage,
      'description': description,
      'time': normalizedTimes.isEmpty ? time : normalizedTimes.first,
      'times': normalizedTimes,
      if (dailyFrequency != null) 'dailyFrequency': dailyFrequency,
      if (startDate != null)
        'startDate': startDate!.toIso8601String().split('T').first,
      'status': status.name,
      'category': category,
      'instructions': instructions,
      if (image != null) 'image': image,
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? description,
    String? time,
    MedicationStatus? status,
    String? category,
    List<String>? instructions,
    List<String>? times,
    int? dailyFrequency,
    DateTime? startDate,
    String? image,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      description: description ?? this.description,
      time: time ?? this.time,
      status: status ?? this.status,
      category: category ?? this.category,
      instructions: instructions ?? this.instructions,
      times: times ?? this.times,
      dailyFrequency: dailyFrequency ?? this.dailyFrequency,
      startDate: startDate ?? this.startDate,
      image: image ?? this.image,
    );
  }
}
