import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medication.dart';
import '../models/medication_status.dart';

class MedicationRepository {
  MedicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('medications');
  }

  Stream<List<Medication>> watchAll(String userId) {
    return _collection(userId).orderBy('time').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Medication.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Medication> add(String userId, Medication medication) async {
    final data = medication.toMap()
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    final doc = await _collection(userId).add(data);
    return medication.copyWith(id: doc.id);
  }

  Future<void> updateStatus({
    required String userId,
    required String medicationId,
    required MedicationStatus status,
  }) {
    return _collection(userId).doc(medicationId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
