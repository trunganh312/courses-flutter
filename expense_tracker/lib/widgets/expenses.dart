import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/expenses_list/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _listExpenses = [
    Expense(
      title: "Du lịch",
      amount: 19.5,
      date: DateTime.now(),
      category: Category.food,
    ),
    Expense(
      title: "Du lịch 2",
      amount: 19.5,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: "Du lịch 3",
      amount: 19.5,
      date: DateTime.now(),
      category: Category.travel,
    ),
  ];

  void _showModalAddExpense() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return NewExpense(
          onAddExpense: _handleAddExpense,
        );
      },
    );
  }

  void _handleAddExpense(Expense expense) {
    setState(() {
      _listExpenses.add(expense);
    });
  }

  void _handleRemoveExpense(Expense expense) {
    final expenseIndex = _listExpenses.indexOf(expense);
    setState(() {
      _listExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Text("Expense removed"),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  _listExpenses.insert(expenseIndex, expense);
                  ScaffoldMessenger.of(context).clearSnackBars();
                });
              },
              child: const Text("Undo"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isRotating =
        width / height < 1; // nhỏ hơn 1 là không xoay, lớn hơn 1 là xoay

    Widget mainContent = const Center(
      child: Text("No expenses found. Start adding some"),
    );
    if (_listExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _listExpenses,
        onRemoveExpense: _handleRemoveExpense,
      );
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text('Flutter ExpensesTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showModalAddExpense,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isRotating
            ? Column(
                children: [
                  Chart(
                    expenses: _listExpenses,
                  ),
                  Expanded(
                    child: mainContent,
                  )
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Chart(
                      expenses: _listExpenses,
                    ),
                  ),
                  Expanded(
                    child: mainContent,
                  )
                ],
              ),
      ),
    );
  }
}
