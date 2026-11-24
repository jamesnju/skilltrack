
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final path = p.join(
      await getDatabasesPath(),
      'focustech.db',
    );

    _db = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createExistingTables(db);
        await _createSettingsTable(db);
        await _createSubjectsTable(db);
        await _createReminderSettingsTable(db);
        await _seedDefaultSubjectsAndTopics(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSettingsTable(db);
        }

        if (oldVersion < 3) {
          await _createSubjectsTable(db);
          await _migrateExistingSubjects(db);
        }
        if (oldVersion < 4) {
  await _createReminderSettingsTable(db);
}
      },
    );

    return _db!;
  }

  Future<void> _createExistingTables(Database db) async {
    await db.execute('''
      CREATE TABLE topics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        title TEXT NOT NULL,
        week INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        minutes INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE journal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        learned TEXT NOT NULL,
        practised TEXT NOT NULL,
        struggled TEXT NOT NULL,
        next_step TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings(
        id INTEGER PRIMARY KEY,
        daily_goal_minutes INTEGER NOT NULL DEFAULT 60,
        weekly_goal_minutes INTEGER NOT NULL DEFAULT 420,
        learn_minutes INTEGER NOT NULL DEFAULT 25,
        practise_minutes INTEGER NOT NULL DEFAULT 25,
        recall_minutes INTEGER NOT NULL DEFAULT 10,
        reminders_enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.insert(
      'settings',
      {
        'id': 1,
        'daily_goal_minutes': 60,
        'weekly_goal_minutes': 420,
        'learn_minutes': 25,
        'practise_minutes': 25,
        'recall_minutes': 10,
        'reminders_enabled': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _createSubjectsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');
  }
Future<void> _createReminderSettingsTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS daily_reminder_settings (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      enabled INTEGER NOT NULL DEFAULT 0,
      hour INTEGER NOT NULL DEFAULT 18,
      minute INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.insert(
    'daily_reminder_settings',
    {
      'id': 1,
      'enabled': 0,
      'hour': 18,
      'minute': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}
  // Used when upgrading an existing installation.
  // Existing subject names are copied from all learning tables.
  Future<void> _migrateExistingSubjects(Database db) async {
    final tables = [
      'topics',
      'sessions',
      'journal',
      'flashcards',
    ];

    for (final table in tables) {
      final rows = await db.rawQuery('''
        SELECT DISTINCT subject
        FROM $table
        WHERE subject IS NOT NULL
          AND TRIM(subject) != ''
      ''');

      for (final row in rows) {
        final name = (row['subject'] as String).trim();

        await db.insert(
          'subjects',
          {
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  // Used only for a fresh installation.
  Future<void> _seedDefaultSubjectsAndTopics(Database db) async {
    final seed = <String, List<String>>{
      'SQL Server': [
        'SELECT, WHERE and ORDER BY',
        'DISTINCT and aggregate functions',
        'INNER JOIN and LEFT JOIN',
        'Subqueries, IN and EXISTS',
        'GROUP BY and HAVING',
        'Stored procedures and views',
        'Transactions and error handling',
        'Backup, restore and troubleshooting',
      ],
      'C#': [
        'Variables and data types',
        'Conditions and loops',
        'Methods and parameters',
        'Classes and objects',
        'Encapsulation and inheritance',
        'Polymorphism and interfaces',
        'Collections and LINQ',
        'Exception handling',
      ],
      'Oracle': [
        'Oracle tools and architecture basics',
        'Schemas, tables and data types',
        'SELECT and filtering',
        'Joins and subqueries',
        'Constraints and indexes',
        'Sequences and views',
        'PL/SQL blocks',
        'Procedures and privileges',
      ],
      'Flexcube': [
        'Core banking overview',
        'Customers and accounts',
        'Products and account types',
        'Debits and credits',
        'Funds transfers',
        'Transaction posting',
        'Loans and repayments',
        'Reconciliation concepts',
      ],
      'WCF': [
        'Services, clients and endpoints',
        'Service and data contracts',
        'Bindings and addresses',
        'SOAP and XML basics',
        'Hosting WCF in IIS',
        'Consuming a WCF service',
        'Configuration and security',
        'Troubleshooting service calls',
      ],
    };

    for (final entry in seed.entries) {
      await db.insert(
        'subjects',
        {
          'name': entry.key,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      for (var i = 0; i < entry.value.length; i++) {
        await db.insert('topics', {
          'subject': entry.key,
          'title': entry.value[i],
          'week': (i ~/ 2) + 1,
          'completed': 0,
        });
      }
    }
  }
}
