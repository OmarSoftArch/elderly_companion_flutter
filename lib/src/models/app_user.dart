import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.email,
    this.caregiverId,
    this.careLinkCode,
    this.caregiverIds = const [],
    this.elderlyIds = const [],
    this.fcmTokens = const [],
  });

  final String id;
  final String name;
  final UserRole role;
  final String? phoneNumber;
  final String? email;
  final String? caregiverId;
  final String? careLinkCode;
  final List<String> caregiverIds;
  final List<String> elderlyIds;
  final List<String> fcmTokens;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (item) => item.name == data['role'],
        orElse: () => UserRole.elderly,
      ),
      phoneNumber: data['phoneNumber'] as String?,
      email: data['email'] as String?,
      caregiverId: data['caregiverId'] as String?,
      careLinkCode: data['careLinkCode'] as String?,
      caregiverIds: (data['caregiverIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      elderlyIds: (data['elderlyIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      fcmTokens: (data['fcmTokens'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role.name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (caregiverId != null) 'caregiverId': caregiverId,
      if (careLinkCode != null) 'careLinkCode': careLinkCode,
      'caregiverIds': caregiverIds,
      'elderlyIds': elderlyIds,
      'fcmTokens': fcmTokens,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? phoneNumber,
    String? email,
    String? caregiverId,
    String? careLinkCode,
    List<String>? caregiverIds,
    List<String>? elderlyIds,
    List<String>? fcmTokens,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      caregiverId: caregiverId ?? this.caregiverId,
      careLinkCode: careLinkCode ?? this.careLinkCode,
      caregiverIds: caregiverIds ?? this.caregiverIds,
      elderlyIds: elderlyIds ?? this.elderlyIds,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
