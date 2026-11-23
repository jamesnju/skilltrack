import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'focustech.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''CREATE TABLE topics(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, title TEXT NOT NULL, week INTEGER NOT NULL, completed INTEGER NOT NULL DEFAULT 0)''');
      await db.execute('''CREATE TABLE sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, minutes INTEGER NOT NULL, date TEXT NOT NULL)''');
      await db.execute('''CREATE TABLE journal(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, learned TEXT NOT NULL, practised TEXT NOT NULL, struggled TEXT NOT NULL, next_step TEXT NOT NULL, created_at TEXT NOT NULL)''');
      await db.execute('''CREATE TABLE flashcards(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, question TEXT NOT NULL, answer TEXT NOT NULL)''');
      final seed = <String, List<String>>{
        'SQL Server': ['SELECT, WHERE and ORDER BY','DISTINCT and aggregate functions','INNER JOIN and LEFT JOIN','Subqueries, IN and EXISTS','GROUP BY and HAVING','Stored procedures and views','Transactions and error handling','Backup, restore and troubleshooting'],
        'C#': ['Variables and data types','Conditions and loops','Methods and parameters','Classes and objects','Encapsulation and inheritance','Polymorphism and interfaces','Collections and LINQ','Exception handling'],
        'Oracle': ['Oracle tools and architecture basics','Schemas, tables and data types','SELECT and filtering','Joins and subqueries','Constraints and indexes','Sequences and views','PL/SQL blocks','Procedures and privileges'],
        'Flexcube': ['Core banking overview','Customers and accounts','Products and account types','Debits and credits','Funds transfers','Transaction posting','Loans and repayments','Reconciliation concepts'],
        'WCF': ['Services, clients and endpoints','Service and data contracts','Bindings and addresses','SOAP and XML basics','Hosting WCF in IIS','Consuming a WCF service','Configuration and security','Troubleshooting service calls'],
      };
      for (final entry in seed.entries) {
        for (var i = 0; i < entry.value.length; i++) {
          await db.insert('topics', {'subject': entry.key, 'title': entry.value[i], 'week': (i ~/ 2) + 1, 'completed': 0});
        }
      }
    });
    return _db!;
  }
}
