import 'package:flutter/foundation.dart';
import '../data/app_database.dart';
import '../models/learning_topic.dart';

class AppState extends ChangeNotifier {
  List<LearningTopic> topics = [];
  List<Map<String, Object?>> journals = [];
  List<Map<String, Object?>> flashcards = [];
  List<Map<String, Object?>> sessions = [];
  bool loading = true;

  Future<void> load() async {
    final db = await AppDatabase.instance.database;
    topics = (await db.query('topics', orderBy: 'subject, week, id')).map(LearningTopic.fromMap).toList();
    journals = await db.query('journal', orderBy: 'created_at DESC');
    flashcards = await db.query('flashcards', orderBy: 'id DESC');
    sessions = await db.query('sessions', orderBy: 'date DESC');
    loading = false;
    notifyListeners();
  }

  Future<void> toggleTopic(LearningTopic topic, bool completed) async {
    final db = await AppDatabase.instance.database;
    await db.update('topics', {'completed': completed ? 1 : 0}, where: 'id = ?', whereArgs: [topic.id]);
    await load();
  }

  Future<void> addSession(String subject, int minutes) async {
    if (minutes <= 0) return;
    final db = await AppDatabase.instance.database;
    await db.insert('sessions', {'subject': subject, 'minutes': minutes, 'date': DateTime.now().toIso8601String()});
    await load();
  }

  Future<void> addJournal({required String subject, required String learned, required String practised, required String struggled, required String nextStep}) async {
    final db = await AppDatabase.instance.database;
    await db.insert('journal', {'subject': subject, 'learned': learned, 'practised': practised, 'struggled': struggled, 'next_step': nextStep, 'created_at': DateTime.now().toIso8601String()});
    await load();
  }

  Future<void> updateJournal({required int id, required String subject, required String learned, required String practised, required String struggled, required String nextStep}) async {
    final db = await AppDatabase.instance.database;
    await db.update('journal', {'subject': subject, 'learned': learned, 'practised': practised, 'struggled': struggled, 'next_step': nextStep}, where: 'id = ?', whereArgs: [id]);
    await load();
  }

  Future<void> deleteJournal(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('journal', where: 'id = ?', whereArgs: [id]);
    await load();
  }

  Future<void> addFlashcard(String subject, String question, String answer) async {
    final db = await AppDatabase.instance.database;
    await db.insert('flashcards', {'subject': subject, 'question': question, 'answer': answer});
    await load();
  }

  Future<void> updateFlashcard({required int id, required String subject, required String question, required String answer}) async {
    final db = await AppDatabase.instance.database;
    await db.update('flashcards', {'subject': subject, 'question': question, 'answer': answer}, where: 'id = ?', whereArgs: [id]);
    await load();
  }

  Future<void> deleteFlashcard(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
    await load();
  }

  int get completedTopics => topics.where((t) => t.completed).length;
  int get totalTopics => topics.length;
  int get totalStudyMinutes => sessions.fold(0, (sum, row) => sum + ((row['minutes'] as num?)?.toInt() ?? 0));

  Map<String, int> get minutesBySubject {
    final result = <String, int>{};
    for (final row in sessions) {
      final subject = row['subject'] as String;
      result[subject] = (result[subject] ?? 0) + ((row['minutes'] as num?)?.toInt() ?? 0);
    }
    return result;
  }

  int get thisWeekMinutes {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return sessions.where((s) => DateTime.tryParse(s['date'] as String? ?? '')?.isAfter(monday.subtract(const Duration(seconds: 1))) ?? false)
      .fold(0, (sum, row) => sum + ((row['minutes'] as num?)?.toInt() ?? 0));
  }

  int get activeStudyDaysThisWeek {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return sessions.map((s) => DateTime.tryParse(s['date'] as String? ?? ''))
      .whereType<DateTime>().where((d) => !d.isBefore(monday)).map((d) => DateTime(d.year, d.month, d.day).toIso8601String()).toSet().length;
  }
}
