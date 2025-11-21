enum LessonStatus { locked, unlocked, completed }

class Lesson {
  final String id;
  final String title;
  final String description;
  final String level;
  final double progress;
  final LessonStatus? status;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.progress,
    this.status,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String?) ?? 'unlocked';
    LessonStatus? status;
    switch (statusStr) {
      case 'locked':
        status = LessonStatus.locked;
        break;
      case 'available':
      case 'unlocked':
        status = LessonStatus.unlocked;
        break;
      case 'completed':
        status = LessonStatus.completed;
        break;
      default:
        status = null;
    }

    final progress =
        status == LessonStatus.completed ? 1.0 : 0.0;

    return Lesson(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? 'Demo lesson from API',
      level: json['level'] ?? 'A1',
      progress: progress,
      status: status,
    );
  }
}
