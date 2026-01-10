import 'package:flutter/material.dart';
import 'package:moneytrail/core/core.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;

  void _saveTransaction() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid data')));
      return;
    }

    final newItem = TransactionItem(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      isExpense: _isExpense,
      date: DateTime.now(),
    );

    // Save to singleton list
    DataStore().addTransaction(newItem);

    Navigator.pop(context); // Return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (e.g., Lunch, Salary)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Type: ", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Expense"),
                  selected: _isExpense,
                  onSelected: (val) => setState(() => _isExpense = true),
                  selectedColor: Colors.red.shade100,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Income"),
                  selected: !_isExpense,
                  onSelected: (val) => setState(() => _isExpense = false),
                  selectedColor: Colors.green.shade100,
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text("SAVE TRANSACTION"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
