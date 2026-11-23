class LearningTopic {
  const LearningTopic({required this.id, required this.subject, required this.title, required this.week, required this.completed});
  final int id;
  final String subject;
  final String title;
  final int week;
  final bool completed;
  factory LearningTopic.fromMap(Map<String, Object?> map) => LearningTopic(
    id: map['id'] as int,
    subject: map['subject'] as String,
    title: map['title'] as String,
    week: map['week'] as int,
    completed: (map['completed'] as int) == 1,
  );
}
