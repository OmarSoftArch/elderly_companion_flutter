import 'dose_log.dart';
import 'medication.dart';
import 'medication_status.dart';

class ScheduledDose {
  const ScheduledDose({
    required this.medication,
    required this.scheduledAt,
    required this.scheduledDate,
    required this.scheduledTime,
    this.log,
  });

  final Medication medication;
  final DateTime scheduledAt;
  final String scheduledDate;
  final String scheduledTime;
  final DoseLog? log;

  String get id => DoseLog.documentId(
        medicationId: medication.id,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
      );

  MedicationStatus get status => log?.status ?? MedicationStatus.pending;

  bool get isPending => status == MedicationStatus.pending;

  int minutesUntil([DateTime? from]) {
    final reference = from ?? DateTime.now();
    return scheduledAt.difference(reference).inMinutes;
  }
}
