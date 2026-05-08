import 'activity_type.dart';

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.user,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String time;
  final String user;

  factory ActivityLog.fromMap(String id, Map<String, dynamic> data) {
    return ActivityLog(
      id: id,
      type: ActivityType.values.firstWhere(
        (item) => item.name == data['type'],
        orElse: () => ActivityType.activity,
      ),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      time: data['time'] as String? ?? '',
      user: data['user'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'time': time,
      'user': user,
    };
  }
}
