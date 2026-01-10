class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final bool isExpense; // true = expense, false = income
  final DateTime date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
  });
}
