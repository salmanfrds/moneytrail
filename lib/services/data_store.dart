import '../transaction_item.dart';

class DataStore {
  static final DataStore _instance = DataStore._internal();
  factory DataStore() => _instance;
  DataStore._internal();

  // The CRUD List
  final List<TransactionItem> _transactions = [];

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  void addTransaction(TransactionItem item) {
    _transactions.add(item);
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((item) => item.id == id);
  }

  double getTotalBalance() {
    double balance = 0;
    for (var item in _transactions) {
      if (item.isExpense) {
        balance -= item.amount;
      } else {
        balance += item.amount;
      }
    }
    return balance;
  }
}
