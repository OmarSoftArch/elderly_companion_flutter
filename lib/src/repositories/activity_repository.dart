import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_log.dart';
import '../models/activity_type.dart';
import '../models/medication.dart';
import '../models/medication_status.dart';

class ActivityRepository {
  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('activityLogs');
  }

  Stream<List<ActivityLog>> watchRecent(String userId, {int limit = 10}) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityLog.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addCheckIn(String userId, {String userName = ''}) {
    return _collection(userId).add({
      ...ActivityLog(
        id: '',
        type: ActivityType.checkIn,
        title: 'تم الاطمئنان',
        description: 'تم تسجيل التأكيد اليومي بنجاح.',
        time: _formatTime(DateTime.now()),
        user: userName,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addMedicationStatusChange({
    required String userId,
    required Medication medication,
    required MedicationStatus status,
    String userName = '',
  }) {
    final title = switch (status) {
      MedicationStatus.taken => 'تم تناول الدواء',
      MedicationStatus.postponed => 'تم تأجيل الدواء',
      MedicationStatus.missed => 'فاتت جرعة الدواء',
      MedicationStatus.pending => 'تم تحديث الدواء',
    };

    return _collection(userId).add({
      ...ActivityLog(
        id: '',
        type: ActivityType.activity,
        title: title,
        description: '${medication.name} - ${medication.dosage}',
        time: _formatTime(DateTime.now()),
        user: userName,
      ).toMap(),
      'medicationId': medication.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
