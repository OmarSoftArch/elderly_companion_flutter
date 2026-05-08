import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _random = Random.secure();

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  DocumentReference<Map<String, dynamic>> _codeDoc(String code) {
    return _firestore.collection('careLinkCodes').doc(code);
  }

  Future<AppUser> getOrCreate({
    required User firebaseUser,
    required UserRole fallbackRole,
  }) async {
    final existing = await getForSignIn(firebaseUser);
    if (existing != null) return existing;

    final code = fallbackRole == UserRole.elderly
        ? await _createUniqueCareLinkCode(firebaseUser.uid)
        : null;
    final user = AppUser(
      id: firebaseUser.uid,
      name: _displayName(firebaseUser),
      role: fallbackRole,
      email: firebaseUser.email,
      careLinkCode: code,
      caregiverIds: const [],
      elderlyIds: const [],
    );

    await _userDoc(firebaseUser.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  Future<AppUser?> getForSignIn(User firebaseUser) async {
    final user = await getById(firebaseUser.uid);
    if (user == null) return null;

    final updates = <String, dynamic>{};
    var result = user;

    if ((user.email == null || user.email!.isEmpty) &&
        firebaseUser.email != null) {
      updates['email'] = firebaseUser.email;
      result = result.copyWith(email: firebaseUser.email);
    }

    if (user.role == UserRole.elderly &&
        (user.careLinkCode == null || user.careLinkCode!.isEmpty)) {
      final code = await _createUniqueCareLinkCode(user.id);
      updates['careLinkCode'] = code;
      result = result.copyWith(careLinkCode: code);
    }

    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _userDoc(firebaseUser.uid).update(updates);
    }

    return result;
  }

  Future<AppUser?> getById(String userId) async {
    final snapshot = await _userDoc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return AppUser.fromMap(snapshot.id, data);
  }

  Future<List<AppUser>> getUsersByIds(List<String> ids) async {
    final users = <AppUser>[];
    for (final id in ids) {
      final user = await getById(id);
      if (user != null) users.add(user);
    }
    return users;
  }

  Future<AppUser?> linkCaregiverByCode({
    required String caregiverId,
    required String code,
  }) async {
    final normalizedCode = _normalizeCode(code);
    final codeSnapshot = await _codeDoc(normalizedCode).get();
    final codeData = codeSnapshot.data();
    if (!codeSnapshot.exists ||
        codeData == null ||
        codeData['active'] != true) {
      return null;
    }

    final elderlyId = codeData['elderlyId'] as String?;
    if (elderlyId == null || elderlyId.isEmpty || elderlyId == caregiverId) {
      return null;
    }

    final caregiverDoc = _userDoc(caregiverId);
    final elderlyDoc = _userDoc(elderlyId);
    final batch = _firestore.batch();

    batch.update(caregiverDoc, {
      'elderlyIds': FieldValue.arrayUnion([elderlyId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(elderlyDoc, {
      'caregiverIds': FieldValue.arrayUnion([caregiverId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return getById(elderlyId);
  }

  Future<void> saveMessagingToken({
    required String userId,
    required String token,
  }) {
    return _userDoc(userId).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<String> _createUniqueCareLinkCode(String elderlyId) async {
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = _generateCareLinkCode();
      final doc = _codeDoc(code);
      final snapshot = await doc.get();
      if (snapshot.exists) continue;

      await doc.set({
        'elderlyId': elderlyId,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return code;
    }

    throw StateError('Unable to create a unique care link code.');
  }

  String _generateCareLinkCode() {
    final number = 100000 + _random.nextInt(900000);
    return 'RFQ-$number';
  }

  String _normalizeCode(String code) {
    final value = code.trim().toUpperCase().replaceAll(' ', '');
    if (value.startsWith('RFQ-')) return value;
    if (value.startsWith('RFQ')) return 'RFQ-${value.substring(3)}';
    return 'RFQ-$value';
  }

  String _displayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return 'مستخدم رفيق';
  }
}
