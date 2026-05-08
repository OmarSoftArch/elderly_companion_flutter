import 'package:cloud_firestore/cloud_firestore.dart';

import 'alert_status.dart';
import 'alert_type.dart';

class CaregiverAlert {
  const CaregiverAlert({
    required this.id,
    required this.elderlyUserId,
    required this.caregiverId,
    required this.type,
    required this.message,
    required this.createdAt,
    this.status = AlertStatus.open,
  });

  final String id;
  final String elderlyUserId;
  final String caregiverId;
  final AlertType type;
  final String message;
  final DateTime createdAt;
  final AlertStatus status;

  factory CaregiverAlert.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];

    return CaregiverAlert(
      id: id,
      elderlyUserId: data['elderlyUserId'] as String? ?? '',
      caregiverId: data['caregiverId'] as String? ?? '',
      type: AlertType.values.firstWhere(
        (item) => item.name == data['type'],
        orElse: () => AlertType.checkIn,
      ),
      message: data['message'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : createdAtValue is DateTime
              ? createdAtValue
              : DateTime.fromMillisecondsSinceEpoch(0),
      status: AlertStatus.values.firstWhere(
        (item) => item.name == data['status'],
        orElse: () => AlertStatus.open,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elderlyUserId': elderlyUserId,
      'caregiverId': caregiverId,
      'type': type.name,
      'message': message,
      'createdAt': createdAt,
      'status': status.name,
    };
  }
}
