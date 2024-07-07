import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class Transaction {
  final DateTime date;
  final double amount;
  final String category;
  final String description;

  Transaction({
    required this.date,
    required this.amount,
    required this.category,
    this.description = "",
  });
}

class FinanceModel {
  List<Transaction> transactions = [];
  double savings = 0;
  Map<String, double> budgetAllocation = {'needs': 0, 'wants': 0, 'savings': 0};

  bool setBudgetAllocation(double needsPercent, double wantsPercent, double savingsPercent) {
    double totalPercent = needsPercent + wantsPercent + savingsPercent;
    if (totalPercent != 100) {
      return false;
    }
    budgetAllocation = {'needs': needsPercent, 'wants': wantsPercent, 'savings': savingsPercent};
    return true;
  }

  void addIncome(double amount) {
    double needsAmount = amount * (budgetAllocation['needs']! / 100);
    double wantsAmount = amount * (budgetAllocation['wants']! / 100);
    double savingsAmount = amount * (budgetAllocation['savings']! / 100);

    transactions.add(Transaction(
      date: DateTime.now(),
      amount: needsAmount,
      category: "Needs",
      description: "Allocated for needs",
    ));
    transactions.add(Transaction(
      date: DateTime.now(),
      amount: wantsAmount,
      category: "Wants",
      description: "Allocated for wants",
    ));
    addSavings(savingsAmount);
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }

  void addSavings(double amount) {
    savings += amount;
  }

  String generateReport() {
    String report = "Monthly Finance History\n";
    for (Transaction t in transactions) {
      report += "${DateFormat('yyyy-MM-dd').format(t.date)} | ${t.amount.toStringAsFixed(2)} | ${t.category} | ${t.description}\n";
    }
    report += "\nTotal Savings: $savings";

    double totalIncome = transactions.where((t) => t.amount > 0).fold(0, (sum, t) => sum + t.amount);
    double totalExpenses = transactions.where((t) => t.amount < 0).fold(0, (sum, t) => sum + t.amount.abs());

    report += "\nTotal Income: $totalIncome";
    report += "\nTotal Expenses: $totalExpenses";
    report += "\nNet Balance: ${totalIncome + totalExpenses + savings}";

    return report;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FinanceApp(),
    );
  }
}

class FinanceApp extends StatefulWidget {
  @override
  _FinanceAppState createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  FinanceModel finance = FinanceModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Manager'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => setBudgetAllocation(),
              child: Text('Set Budget Allocation'),
            ),
            ElevatedButton(
              onPressed: () => addIncome(),
              child: Text('Add Income'),
            ),
            ElevatedButton(
              onPressed: () => addExpense(),
              child: Text('Add Expense'),
            ),
            ElevatedButton(
              onPressed: () => generateReport(),
              child: Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }

  void setBudgetAllocation() async {
    double? needsPercent = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Set Budget Allocation'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 50.0),
              child: Text('Needs: 50%'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 30.0),
              child: Text('Wants: 30%'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 20.0),
              child: Text('Savings: 20%'),
            ),
          ],
        );
      },
    );

    double? wantsPercent = 100 - needsPercent!;

    if (finance.setBudgetAllocation(needsPercent, wantsPercent, 20.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget allocation set successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Percentages must add up to 100.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void addIncome() async {
    double? amount = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add Income'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 100.0),
              child: Text('Add \$100'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 200.0),
              child: Text('Add \$200'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 500.0),
              child: Text('Add \$500'),
            ),
          ],
        );
      },
    );

    if (amount != null) {
      finance.addIncome(amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income added and allocated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void addExpense() async {
    double? amount = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add Expense'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 50.0),
              child: Text('Add \$50'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 100.0),
              child: Text('Add \$100'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 200.0),
              child: Text('Add \$200'),
            ),
          ],
        );
      },
    );

    if (amount != null) {
      amount = -amount; // Make expense negative

      String? category = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Enter Expense Category'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'Needs'),
                child: Text('Needs'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'Wants'),
                child: Text('Wants'),
              ),
            ],
          );
        },
      );

      String? description = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Enter Expense Description'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'Groceries'),
                child: Text('Groceries'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'Shopping'),
                child: Text('Shopping'),
              ),
            ],
          );
        },
      );

      if (category != null && (category.toLowerCase() == 'needs' || category.toLowerCase() == 'wants')) {
        finance.addTransaction(Transaction(
          date: DateTime.now(),
          amount: amount,
          category: category,
          description: description ?? "",
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid category. Please enter \'Needs\' or \'Wants\'.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void generateReport() {
    String report = finance.generateReport();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Monthly Finance Report'),
          content: Text(report),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
