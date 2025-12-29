import 'local_db.dart';
import '../models/expense_model.dart';

class ExpenseLocalDatasource {
  final LocalDB _db = LocalDB.instance;

  /// INSERT
  Future<void> insertExpense(Expense expense) async {
    final db = await _db.database;
    await db.insert('expenses', expense.toMap());
  }

  /// GET ALL BY DATE
  Future<List<Expense>> getExpensesByDate(String date) async {
    final db = await _db.database;

    final result = await db.query(
      'expenses',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  /// DAILY INSIGHT (GROUP BY CATEGORY)
  Future<Map<String, int>> getDailyInsight(String date) async {
    final db = await _db.database;

    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE date = ?
      GROUP BY category
    ''', [date]);

    return {
      for (final row in result)
        row['category'] as String: row['total'] as int
    };
  }

  /// GET ALL EXPENSES
  Future<List<Expense>> getAllExpenses() async {
    final db = await _db.database;

    final result = await db.query(
      'expenses',
      orderBy: 'date DESC, id DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  /// UPDATE EXPENSE
  Future<void> updateExpense(Expense expense) async {
    final db = await _db.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// DELETE (opsional)
  Future<void> deleteExpense(int id) async {
    final db = await _db.database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
