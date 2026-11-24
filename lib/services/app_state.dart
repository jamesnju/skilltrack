
import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../models/learning_topic.dart';

class AppState extends ChangeNotifier {
  List<String> subjects = [];

  List<LearningTopic> topics = [];
  List<Map<String, Object?>> journals = [];
  List<Map<String, Object?>> flashcards = [];
  List<Map<String, Object?>> sessions = [];

  bool loading = true;

  // User settings
  int dailyGoalMinutes = 60;
  int weeklyGoalMinutes = 420;

  int learnMinutes = 25;
  int practiseMinutes = 25;
  int recallMinutes = 10;

  bool remindersEnabled = true;

  // Load all application data
  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      final db = await AppDatabase.instance.database;

      final subjectRows = await db.query(
        'subjects',
        orderBy: 'name COLLATE NOCASE',
      );

      subjects = subjectRows
          .map((row) => row['name'] as String)
          .toList();

      topics = (await db.query(
        'topics',
        orderBy: 'subject, week, id',
      )).map(LearningTopic.fromMap).toList();

      journals = await db.query(
        'journal',
        orderBy: 'created_at DESC',
      );

      flashcards = await db.query(
        'flashcards',
        orderBy: 'id DESC',
      );

      sessions = await db.query(
        'sessions',
        orderBy: 'date DESC',
      );

      final settingsRows = await db.query(
        'settings',
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (settingsRows.isNotEmpty) {
        final settings = settingsRows.first;

        dailyGoalMinutes =
            (settings['daily_goal_minutes'] as num).toInt();

        weeklyGoalMinutes =
            (settings['weekly_goal_minutes'] as num).toInt();

        learnMinutes =
            (settings['learn_minutes'] as num).toInt();

        practiseMinutes =
            (settings['practise_minutes'] as num).toInt();

        recallMinutes =
            (settings['recall_minutes'] as num).toInt();

        remindersEnabled =
            (settings['reminders_enabled'] as num).toInt() == 1;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------
  // SUBJECT MANAGEMENT
  // -----------------------------------------

  Future<void> addSubject(String name) async {
    final cleanedName = name.trim();

    if (cleanedName.isEmpty) {
      throw Exception('Subject name cannot be empty.');
    }

    if (subjects.any(
      (subject) => subject.toLowerCase() == cleanedName.toLowerCase(),
    )) {
      throw Exception('This subject already exists.');
    }

    final db = await AppDatabase.instance.database;

    await db.insert('subjects', {
      'name': cleanedName,
      'created_at': DateTime.now().toIso8601String(),
    });

    await load();
  }

  Future<void> updateSubject({
    required String oldName,
    required String newName,
  }) async {
    final cleanedName = newName.trim();

    if (cleanedName.isEmpty) {
      throw Exception('Subject name cannot be empty.');
    }

    if (subjects.any(
      (subject) =>
          subject.toLowerCase() == cleanedName.toLowerCase() &&
          subject.toLowerCase() != oldName.toLowerCase(),
    )) {
      throw Exception('A subject with this name already exists.');
    }

    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.update(
        'subjects',
        {'name': cleanedName},
        where: 'name = ?',
        whereArgs: [oldName],
      );

      // Update all records that use this subject.
      for (final table in [
        'topics',
        'sessions',
        'journal',
        'flashcards',
      ]) {
        await txn.update(
          table,
          {'subject': cleanedName},
          where: 'subject = ?',
          whereArgs: [oldName],
        );
      }
    });

    await load();
  }

  Future<void> deleteSubject(String name) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      // Remove the subject's roadmap topics.
      await txn.delete(
        'topics',
        where: 'subject = ?',
        whereArgs: [name],
      );

      // Keep historical sessions, journal entries and flashcards.
      // They remain available in the database.
      await txn.delete(
        'subjects',
        where: 'name = ?',
        whereArgs: [name],
      );
    });

    await load();
  }

  // -----------------------------------------
  // TOPIC MANAGEMENT
  // -----------------------------------------

  Future<void> addTopic({
    required String subject,
    required String title,
    required int week,
  }) async {
    final cleanedTitle = title.trim();

    if (cleanedTitle.isEmpty) {
      throw Exception('Topic title cannot be empty.');
    }

    if (!subjects.contains(subject)) {
      throw Exception('Please select a valid subject.');
    }

    if (week < 1) {
      throw Exception('Week must be at least 1.');
    }

    final db = await AppDatabase.instance.database;

    await db.insert('topics', {
      'subject': subject,
      'title': cleanedTitle,
      'week': week,
      'completed': 0,
    });

    await load();
  }

  Future<void> updateTopic({
    required int id,
    required String subject,
    required String title,
    required int week,
  }) async {
    final cleanedTitle = title.trim();

    if (cleanedTitle.isEmpty) {
      throw Exception('Topic title cannot be empty.');
    }

    if (!subjects.contains(subject)) {
      throw Exception('Please select a valid subject.');
    }

    if (week < 1) {
      throw Exception('Week must be at least 1.');
    }

    final db = await AppDatabase.instance.database;

    await db.update(
      'topics',
      {
        'subject': subject,
        'title': cleanedTitle,
        'week': week,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await load();
  }

  Future<void> deleteTopic(int id) async {
    final db = await AppDatabase.instance.database;

    await db.delete(
      'topics',
      where: 'id = ?',
      whereArgs: [id],
    );

    await load();
  }

  // -----------------------------------------
  // SETTINGS
  // -----------------------------------------

  Future<void> updateSettings({
    required int dailyGoal,
    required int weeklyGoal,
    required int learn,
    required int practise,
    required int recall,
    required bool reminders,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'settings',
      {
        'daily_goal_minutes': dailyGoal,
        'weekly_goal_minutes': weeklyGoal,
        'learn_minutes': learn,
        'practise_minutes': practise,
        'recall_minutes': recall,
        'reminders_enabled': reminders ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    dailyGoalMinutes = dailyGoal;
    weeklyGoalMinutes = weeklyGoal;
    learnMinutes = learn;
    practiseMinutes = practise;
    recallMinutes = recall;
    remindersEnabled = reminders;

    notifyListeners();
  }

  // -----------------------------------------
  // ROADMAP
  // -----------------------------------------

  Future<void> toggleTopic(
    LearningTopic topic,
    bool completed,
  ) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'topics',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [topic.id],
    );

    await load();
  }

  // -----------------------------------------
  // STUDY SESSIONS
  // -----------------------------------------

  Future<void> addSession(
    String subject,
    int minutes,
  ) async {
    if (minutes <= 0) return;

    final db = await AppDatabase.instance.database;

    await db.insert('sessions', {
      'subject': subject,
      'minutes': minutes,
      'date': DateTime.now().toIso8601String(),
    });

    await load();
  }

  // -----------------------------------------
  // JOURNAL
  // -----------------------------------------

  Future<void> addJournal({
    required String subject,
    required String learned,
    required String practised,
    required String struggled,
    required String nextStep,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.insert('journal', {
      'subject': subject,
      'learned': learned,
      'practised': practised,
      'struggled': struggled,
      'next_step': nextStep,
      'created_at': DateTime.now().toIso8601String(),
    });

    await load();
  }

  Future<void> updateJournal({
    required int id,
    required String subject,
    required String learned,
    required String practised,
    required String struggled,
    required String nextStep,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'journal',
      {
        'subject': subject,
        'learned': learned,
        'practised': practised,
        'struggled': struggled,
        'next_step': nextStep,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await load();
  }

  Future<void> deleteJournal(int id) async {
    final db = await AppDatabase.instance.database;

    await db.delete(
      'journal',
      where: 'id = ?',
      whereArgs: [id],
    );

    await load();
  }

  // -----------------------------------------
  // FLASHCARDS
  // -----------------------------------------

  Future<void> addFlashcard(
    String subject,
    String question,
    String answer,
  ) async {
    final db = await AppDatabase.instance.database;

    await db.insert('flashcards', {
      'subject': subject,
      'question': question,
      'answer': answer,
    });

    await load();
  }

  Future<void> updateFlashcard({
    required int id,
    required String subject,
    required String question,
    required String answer,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'flashcards',
      {
        'subject': subject,
        'question': question,
        'answer': answer,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await load();
  }

  Future<void> deleteFlashcard(int id) async {
    final db = await AppDatabase.instance.database;

    await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );

    await load();
  }

  // -----------------------------------------
  // ANALYTICS
  // -----------------------------------------

  int get completedTopics =>
      topics.where((topic) => topic.completed).length;

  int get totalTopics => topics.length;

  int get totalStudyMinutes {
    return sessions.fold(
      0,
      (sum, row) =>
          sum + ((row['minutes'] as num?)?.toInt() ?? 0),
    );
  }

  Map<String, int> get minutesBySubject {
    final result = <String, int>{};

    for (final row in sessions) {
      final subject = row['subject'] as String;

      result[subject] =
          (result[subject] ?? 0) +
          ((row['minutes'] as num?)?.toInt() ?? 0);
    }

    return result;
  }

  int get thisWeekMinutes {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return sessions.where((session) {
      final date = DateTime.tryParse(
        session['date'] as String? ?? '',
      );

      return date != null && !date.isBefore(monday);
    }).fold(
      0,
      (sum, row) =>
          sum + ((row['minutes'] as num?)?.toInt() ?? 0),
    );
  }

  int get activeStudyDaysThisWeek {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return sessions
        .map(
          (session) => DateTime.tryParse(
            session['date'] as String? ?? '',
          ),
        )
        .whereType<DateTime>()
        .where(
          (date) =>
              !date.isBefore(monday) &&
              !date.isAfter(now),
        )
        .map(
          (date) => DateTime(
            date.year,
            date.month,
            date.day,
          ).toIso8601String(),
        )
        .toSet()
        .length;
  }

  int get todayStudyMinutes {
    final now = DateTime.now();

    return sessions.where((session) {
      final date = DateTime.tryParse(
        session['date'] as String? ?? '',
      );

      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).fold(
      0,
      (sum, row) =>
          sum + ((row['minutes'] as num?)?.toInt() ?? 0),
    );
  }

  double get dailyGoalProgress {
    if (dailyGoalMinutes <= 0) return 0;

    return (todayStudyMinutes / dailyGoalMinutes)
        .clamp(0.0, 1.0);
  }

  double get weeklyGoalProgress {
    if (weeklyGoalMinutes <= 0) return 0;

    return (thisWeekMinutes / weeklyGoalMinutes)
        .clamp(0.0, 1.0);
  }
}
