import 'package:ai_exspense_analyzer/core/ai/smart_recommendation_ai.dart';
import 'package:ai_exspense_analyzer/core/ai/daily_insight_ai.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository repository;

  ExpenseProvider(this.repository);

  bool loading = false;
  List<Expense> todayExpenses = [];
  List<Expense> allExpenses = [];
  Map<String, int> dailyInsight = {};

  List<String> _recommendations = [];
  bool _isLoadingRecommendation = false;

  String _dailyAiInsight = '';
  bool _isLoadingInsight = false;

  List<String> get recommendations => _recommendations;
  bool get isLoadingRecommendation => _isLoadingRecommendation;
  String get dailyAiInsight => _dailyAiInsight;
  bool get isLoadingInsight => _isLoadingInsight;

  int get totalTodayExpense {
  if (dailyInsight.isEmpty) return 0;
  return dailyInsight.values.fold(0, (sum, value) => sum + value);
}


  /// ADD EXPENSE (AI + DB)
  Future<void> addExpense(String title, int amount) async {
    loading = true;
    notifyListeners();

    await repository.addExpense(
      title: title,
      amount: amount,
    );

    await loadTodayData();

    loading = false;
    notifyListeners();
  }

  /// LOAD TODAY EXPENSES + INSIGHT
  Future<void> loadTodayData() async {
    todayExpenses = await repository.getTodayExpenses();
    dailyInsight = await repository.getTodayInsight();
    notifyListeners();
  }

  /// LOAD ALL EXPENSES
  Future<void> loadAllExpenses() async {
    allExpenses = await repository.getAllExpenses();
    notifyListeners();
  }

  String get topCategory {
  if (dailyInsight.isEmpty) return '-';
  return dailyInsight.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
}

Future<void> generateSmartRecommendation() async {
  _isLoadingRecommendation = true;
  notifyListeners();

  final ai = SmartRecommendationAI(Dio());

  _recommendations = await ai.generateRecommendations(
    topCategory: topCategory,
    totalExpense: totalTodayExpense,
    breakdown: dailyInsight,
  );

  _isLoadingRecommendation = false;
  notifyListeners();
}

Future<void> generateDailyInsight() async {
  _isLoadingInsight = true;
  notifyListeners();

  final ai = DailyInsightAI(Dio());

  // Create summary from daily data
  final summary = '''
Hari ini Anda telah menghabiskan total Rp $totalTodayExpense
 dengan rincian:
${dailyInsight.entries.map((e) => "- ${e.key}: Rp ${e.value}").join('\n')}
Kategori terbesar: $topCategory
''';

  _dailyAiInsight = await ai.generateInsight(summary);

  _isLoadingInsight = false;
  notifyListeners();
}

  /// UPDATE EXPENSE
  Future<void> updateExpense(Expense expense) async {
    loading = true;
    notifyListeners();

    await repository.updateExpense(expense);

    await loadTodayData();
    await loadAllExpenses();

    loading = false;
    notifyListeners();
  }

  /// DELETE EXPENSE
  Future<void> deleteExpense(int id) async {
    loading = true;
    notifyListeners();

    await repository.deleteExpense(id);

    await loadTodayData();
    await loadAllExpenses();

    loading = false;
    notifyListeners();
  }


}
