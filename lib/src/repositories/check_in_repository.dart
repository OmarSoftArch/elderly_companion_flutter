import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/check_in.dart';

class CheckInRepository {
  CheckInRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('checkIns');
  }

  Stream<CheckIn?> watchToday(String userId) {
    final today = formatDate(DateTime.now());
    return _collection(userId).doc(today).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return CheckIn.fromMap(snapshot.id, data);
    });
  }

  Future<void> saveToday({
    required String userId,
    String? note,
  }) {
    final today = formatDate(DateTime.now());
    final checkIn = CheckIn(
      id: today,
      userId: userId,
      createdAt: DateTime.now(),
      isOk: true,
      note: note,
    );

    return _collection(userId).doc(today).set(
      {
        ...checkIn.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static String formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
