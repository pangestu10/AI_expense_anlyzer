class Expense {
  final int? id;
  final String title;
  final int amount;
  final String category;
  final String date; // yyyy-MM-dd

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as int,
      category: map['category'] as String,
      date: map['date'] as String,
    );
  }
}
