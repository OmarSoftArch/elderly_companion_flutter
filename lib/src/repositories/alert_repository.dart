import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert_status.dart';
import '../models/alert_type.dart';
import '../models/caregiver_alert.dart';
import '../models/scheduled_dose.dart';

class AlertRepository {
  AlertRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('alerts');
  }

  Stream<List<CaregiverAlert>> watchOpenAlerts(String userId,
      {int limit = 20}) {
    return _collection(userId)
        .where('status', isEqualTo: AlertStatus.open.name)
        .limit(limit)
        .snapshots()
        .map(
      (snapshot) {
        final alerts = snapshot.docs
            .map((doc) => CaregiverAlert.fromMap(doc.id, doc.data()))
            .toList();
        alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return alerts;
      },
    );
  }

  Future<void> resolve({
    required String userId,
    required String alertId,
  }) {
    return _collection(userId).doc(alertId).update({
      'status': AlertStatus.resolved.name,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createMissedDoseAlerts({
    required String elderlyUserId,
    required String elderlyName,
    required List<String> caregiverIds,
    required ScheduledDose dose,
  }) async {
    if (caregiverIds.isEmpty) return;

    final batch = _firestore.batch();
    for (final caregiverId in caregiverIds) {
      final alertId = 'missed_${dose.id}_$caregiverId';
      final message =
          'لم يتم تأكيد جرعة ${dose.medication.name} الساعة ${dose.scheduledTime} للمسن $elderlyName.';
      final alert = CaregiverAlert(
        id: alertId,
        elderlyUserId: elderlyUserId,
        caregiverId: caregiverId,
        type: AlertType.missedMedication,
        message: message,
        createdAt: DateTime.now(),
      );

      batch.set(
        _collection(elderlyUserId).doc(alertId),
        {
          ...alert.toMap(),
          'doseLogId': dose.id,
          'medicationId': dose.medication.id,
          'scheduledDate': dose.scheduledDate,
          'scheduledTime': dose.scheduledTime,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
