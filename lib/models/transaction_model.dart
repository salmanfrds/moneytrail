import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final String category;
  final String? receiptUrl;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
    this.receiptUrl,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      isExpense: map['isExpense'],
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'],
      receiptUrl: map['receiptUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'date': date,
      'category': category,
      'receiptUrl': receiptUrl,
    };
  }
}
