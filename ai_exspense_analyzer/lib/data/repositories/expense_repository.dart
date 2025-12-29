import '../../core/ai/expense_classifier.dart';
import '../datasources/expense_local_ds.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final ExpenseClassifier ai;
  final ExpenseLocalDatasource local;

  ExpenseRepository({
    required this.ai,
    required this.local,
  });

  Future<void> addExpense({
    required String title,
    required int amount,
  }) async {
    final category = await ai.classify(title);

    final expense = Expense(
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now().toIso8601String().split('T')[0],
    );

    await local.insertExpense(expense);
  }

  Future<Map<String, int>> getTodayInsight() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return local.getDailyInsight(today);
  }

  Future<List<Expense>> getTodayExpenses() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return local.getExpensesByDate(today);
  }

  Future<List<Expense>> getAllExpenses() async {
    return local.getAllExpenses();
  }

  /// UPDATE EXPENSE
  Future<void> updateExpense(Expense expense) async {
    await local.updateExpense(expense);
  }

  /// DELETE EXPENSE
  Future<void> deleteExpense(int id) async {
    await local.deleteExpense(id);
  }
}
