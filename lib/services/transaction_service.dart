import '../models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  // The CRUD List
  final List<String> _categories = ["Food", "Transport", "Utilities", "Salary"];

  List<String> get categories => List.unmodifiable(_categories);

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
  }

  Future<void> addTransaction(User? user, TransactionModel item) async {
    // Save to Firebase
    await usersCollection
        .doc(user!.uid)
        .collection('transactions')
        .add(item.toMap());
  }

  Stream<List<TransactionModel>> getTransactions(User? user) {
    if (user == null) return Stream.value([]);

    final historyRef = usersCollection.doc(user.uid).collection('transactions');
    final historySnapshotOrdered = historyRef
        .orderBy('date', descending: true)
        .snapshots();
    final histroyList = historySnapshotOrdered.map(
      (documents) => documents.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList(),
    );
    return histroyList;
  }
}
