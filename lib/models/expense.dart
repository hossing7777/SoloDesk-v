class Expense {
  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = '',
  });

  factory Expense.fromJson(Map<String, Object?> j) => Expense(
        id: j['id'] as int?,
        title: j['title'] as String,
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        date: j['date'] as int,
        category: (j['category'] as String?) ?? '',
      );

  final int? id;
  final String title;
  final double amount;
  final int date;
  final String category;

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'date': date,
        'category': category,
      };
}
