import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// -------------------- DATA MODEL & MOCK DATABASE --------------------

/// A simple model for a transaction
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

/// A Singleton Data Store to act as your "Local Database"
/// Replace this logic with Firebase later.
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

// -------------------- MAIN APP WIDGET --------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyTrail',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainContainerPage(),
        '/add': (context) => const AddTransactionPage(),
      },
    );
  }
}

// -------------------- PAGE 1: LOGIN PAGE --------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    // Mock validation
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter any email and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("MoneyTrail", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  child: const Text("LOGIN"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- CONTAINER FOR BOTTOM NAV --------------------

class MainContainerPage extends StatefulWidget {
  const MainContainerPage({super.key});

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {
  int _currentIndex = 0;

  // List of pages to switch between
  final List<Widget> _pages = [
    const DashboardPage(), // Page 2
    const HistoryPage(),   // Page 4 (CRUD Read)
    const ProfilePage(),   // Page 5
  ];

  // Callback to refresh state when returning from Add Page
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () async {
          // Navigate to Add Page and wait for result to refresh UI
          await Navigator.pushNamed(context, '/add');
          setState(() {}); 
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// -------------------- PAGE 2: DASHBOARD PAGE --------------------

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = DataStore().getTotalBalance();
    final transactions = DataStore().transactions;
    final recent = transactions.length > 5 ? transactions.sublist(transactions.length - 5) : transactions;

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
                  const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    "RM${balance.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              backgroundColor: item.isExpense ? Colors.red.shade100 : Colors.green.shade100,
                              child: Icon(
                                item.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                color: item.isExpense ? Colors.red : Colors.green,
                              ),
                            ),
                            title: Text(item.title),
                            trailing: Text(
                              "${item.isExpense ? '-' : '+'}RM${item.amount}",
                              style: TextStyle(
                                color: item.isExpense ? Colors.red : Colors.green,
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

// -------------------- PAGE 3: ADD TRANSACTION PAGE --------------------

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid data')));
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
              decoration: const InputDecoration(labelText: 'Title (e.g., Lunch, Salary)'),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: const Text("SAVE TRANSACTION"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- PAGE 4: HISTORY/CRUD PAGE --------------------

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
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
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

// -------------------- PAGE 5: PROFILE PAGE --------------------

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text("User Name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("user@example.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}