import 'package:cloud_firestore/cloud_firestore.dart';

import 'medication_status.dart';

class DoseLog {
  const DoseLog({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.scheduledAt,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.medicationName,
    required this.dosage,
    this.confirmedAt,
  });

  final String id;
  final String medicationId;
  final String userId;
  final DateTime scheduledAt;
  final String scheduledDate;
  final String scheduledTime;
  final MedicationStatus status;
  final String medicationName;
  final String dosage;
  final DateTime? confirmedAt;

  factory DoseLog.fromMap(String id, Map<String, dynamic> data) {
    final scheduledAtValue = data['scheduledAt'];
    final confirmedAtValue = data['confirmedAt'];

    return DoseLog(
      id: id,
      medicationId: data['medicationId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      scheduledAt: _dateFromValue(scheduledAtValue),
      scheduledDate: data['scheduledDate'] as String? ?? '',
      scheduledTime: data['scheduledTime'] as String? ?? '',
      status: MedicationStatus.values.firstWhere(
        (item) => item.name == data['status'],
        orElse: () => MedicationStatus.pending,
      ),
      medicationName: data['medicationName'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      confirmedAt:
          confirmedAtValue == null ? null : _dateFromValue(confirmedAtValue),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'userId': userId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'status': status.name,
      'medicationName': medicationName,
      'dosage': dosage,
      if (confirmedAt != null) 'confirmedAt': Timestamp.fromDate(confirmedAt!),
    };
  }

  static String documentId({
    required String medicationId,
    required String scheduledDate,
    required String scheduledTime,
  }) {
    final normalizedTime = scheduledTime.replaceAll(':', '');
    return '${medicationId}_${scheduledDate}_$normalizedTime';
  }

  static DateTime _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
