import 'package:flutter/material.dart';
import 'package:moneytrail/services/services.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  void _deleteItem(String id) {
    setState(() {
      DataStore().removeTransaction(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactions = DataStore().transactions;

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: transactions.isEmpty
          ? const Center(child: Text("No history available"))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];
                return Dismissible(
                  key: Key(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _deleteItem(item.id),
                  child: ListTile(
                    leading: Icon(
                      item.isExpense ? Icons.remove_circle : Icons.add_circle,
                      color: item.isExpense ? Colors.red : Colors.green,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.date.toString().substring(0, 10)),
                    trailing: Text(
                      "\$${item.amount}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
