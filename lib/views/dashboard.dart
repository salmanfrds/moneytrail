import 'package:flutter/material.dart';
import 'package:moneytrail/core/core.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = DataStore().getTotalBalance();
    final transactions = DataStore().transactions;
    final recent = transactions.length > 5
        ? transactions.sublist(transactions.length - 5)
        : transactions;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "RM${balance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: recent.isEmpty
                  ? const Center(child: Text("No transactions yet"))
                  : ListView.builder(
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        // Show latest first
                        final item = recent[recent.length - 1 - index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isExpense
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              child: Icon(
                                item.isExpense
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: item.isExpense
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                            title: Text(item.title),
                            trailing: Text(
                              "${item.isExpense ? '-' : '+'}RM${item.amount}",
                              style: TextStyle(
                                color: item.isExpense
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
