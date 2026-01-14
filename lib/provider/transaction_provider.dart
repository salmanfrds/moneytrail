import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrail/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneytrail/services/services.dart';

final transactionProvider = StreamProvider<List<TransactionModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return TransactionService().getTransactions(user);
});
