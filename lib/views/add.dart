import 'package:flutter/material.dart';
import 'package:moneytrail/services/services.dart';
import 'package:moneytrail/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Check if we are editing
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _titleController.text = t.title;
      _amountController.text = t.amount
          .toString(); // or toStringAsFixed if needed
      _isExpense = t.isExpense;

      // Validate category
      final categories = TransactionService().categories;
      if (_isExpense) {
        if (categories.contains(t.category)) {
          _selectedCategory = t.category;
        } else if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
      } else {
        _selectedCategory = "Income";
      }
    } else {
      // Set default category if available
      final categories = TransactionService().categories;
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final user = FirebaseAuth.instance.currentUser;
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty ||
        amount == null ||
        (_isExpense && _selectedCategory == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid data')));
      return;
    }

    if (widget.transactionToEdit != null) {
      // Update existing
      final updatedItem = TransactionModel(
        id: widget.transactionToEdit!.id, // Keep same ID
        title: title,
        amount: amount,
        isExpense: _isExpense,
        date: widget
            .transactionToEdit!
            .date, // Keep original date? Or update? usually keep.
        category: _isExpense ? _selectedCategory! : "Income",
      );
      TransactionService().updateTransaction(user, updatedItem);
    } else {
      // Create new
      final newItem = TransactionModel(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        isExpense: _isExpense,
        date: DateTime.now(),
        category: _isExpense ? _selectedCategory! : "Income",
      );
      // Save to singleton list
      TransactionService().addTransaction(user, newItem);
    }

    Navigator.pop(context); // Return to previous screen
  }

  void _addNewCategory() {
    final categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final newCat = categoryController.text.trim();
              if (newCat.isNotEmpty) {
                setState(() {
                  TransactionService().addCategory(newCat);
                  _selectedCategory = newCat;
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit != null
              ? "Edit Transaction"
              : "Add Transaction",
        ),
      ),
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
                  label: Text(
                    "Expense",
                    style: TextStyle(
                      color: _isExpense
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: _isExpense
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: _isExpense,
                  onSelected: (val) {
                    setState(() {
                      _isExpense = true;
                      // Ensure valid category for Expense
                      final categories = TransactionService().categories;
                      if (_selectedCategory == "Income" ||
                          !categories.contains(_selectedCategory)) {
                        if (categories.isNotEmpty) {
                          _selectedCategory = categories.first;
                        }
                      }
                    });
                  },
                  selectedColor: Colors.indigo,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide.none,
                  checkmarkColor: Colors.white,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text(
                    "Income",
                    style: TextStyle(
                      color: !_isExpense
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: !_isExpense
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: !_isExpense,
                  onSelected: (val) => setState(() => _isExpense = false),
                  selectedColor: Colors.indigo,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide.none,
                  checkmarkColor: Colors.white,
                ),
              ],
            ),
            if (_isExpense) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: TransactionService().categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewCategory,
                    tooltip: "Add Category",
                  ),
                ],
              ),
            ],
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
