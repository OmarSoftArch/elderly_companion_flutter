import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dose_log.dart';
import '../models/medication.dart';
import '../models/medication_status.dart';
import '../models/scheduled_dose.dart';

class DoseLogRepository {
  DoseLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const missedDoseGracePeriod = Duration(minutes: 30);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('doseLogs');
  }

  Stream<List<DoseLog>> watchForDate(String userId, String date) {
    return _collection(userId)
        .where('scheduledDate', isEqualTo: date)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoseLog.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> upsertStatus({
    required String userId,
    required ScheduledDose dose,
    required MedicationStatus status,
  }) {
    final log = DoseLog(
      id: dose.id,
      medicationId: dose.medication.id,
      userId: userId,
      scheduledAt: dose.scheduledAt,
      scheduledDate: dose.scheduledDate,
      scheduledTime: dose.scheduledTime,
      status: status,
      medicationName: dose.medication.name,
      dosage: dose.medication.dosage,
      confirmedAt: DateTime.now(),
    );

    return _collection(userId).doc(dose.id).set(
      {
        ...log.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (dose.log == null) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<List<ScheduledDose>> markOverdueDosesMissed({
    required String userId,
    required List<ScheduledDose> doses,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final batch = _firestore.batch();
    final newlyMissed = <ScheduledDose>[];
    var hasUpdates = false;

    for (final dose in doses) {
      if (dose.status != MedicationStatus.pending) continue;

      final missedAfter = dose.scheduledAt.add(missedDoseGracePeriod);
      if (reference.isBefore(missedAfter)) continue;

      final log = DoseLog(
        id: dose.id,
        medicationId: dose.medication.id,
        userId: userId,
        scheduledAt: dose.scheduledAt,
        scheduledDate: dose.scheduledDate,
        scheduledTime: dose.scheduledTime,
        status: MedicationStatus.missed,
        medicationName: dose.medication.name,
        dosage: dose.medication.dosage,
      );

      batch.set(
        _collection(userId).doc(dose.id),
        {
          ...log.toMap(),
          'missedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (dose.log == null) 'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      hasUpdates = true;
      newlyMissed.add(dose);
    }

    if (hasUpdates) {
      await batch.commit();
    }
    return newlyMissed;
  }

  List<ScheduledDose> buildTodayDoses({
    required List<Medication> medications,
    required List<DoseLog> logs,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final date = formatDate(reference);
    final logsById = {for (final log in logs) log.id: log};
    final doses = <ScheduledDose>[];

    for (final medication in medications) {
      for (final time in medication.scheduledTimes) {
        final scheduledAt = _scheduledDateTime(reference, time);
        final id = DoseLog.documentId(
          medicationId: medication.id,
          scheduledDate: date,
          scheduledTime: time,
        );
        doses.add(
          ScheduledDose(
            medication: medication,
            scheduledAt: scheduledAt,
            scheduledDate: date,
            scheduledTime: time,
            log: logsById[id],
          ),
        );
      }
    }

    doses.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return doses;
  }

  static String formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  DateTime _scheduledDateTime(DateTime reference, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final safeHour = hour.clamp(0, 23).toInt();
    final safeMinute = minute.clamp(0, 59).toInt();
    return DateTime(
      reference.year,
      reference.month,
      reference.day,
      safeHour,
      safeMinute,
    );
  }
}
