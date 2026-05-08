import 'package:cloud_firestore/cloud_firestore.dart';

class CheckIn {
  const CheckIn({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.isOk,
    this.note,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final bool isOk;
  final String? note;

  factory CheckIn.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];

    return CheckIn(
      id: id,
      userId: data['userId'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : createdAtValue is DateTime
              ? createdAtValue
              : DateTime.tryParse(createdAtValue?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
      isOk: data['isOk'] as bool? ?? true,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isOk': isOk,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}
