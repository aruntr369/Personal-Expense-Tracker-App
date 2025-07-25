import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/expense_entry.dart';
import '../../../../domain/entities/income_entry.dart';
import '../../../bloc/finance_bloc.dart';

class EntryForm extends StatefulWidget {
  final bool isIncome;
  const EntryForm({super.key, required this.isIncome});

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String? _subCategory;
  String? _description;
  DateTime _selectedDate = DateTime.now();
  double? _amount;
  bool _submitted = false;

  final _incomeCategories = ['Salary', 'Bonus', 'Freelance', 'Interest'];
  final _expenseCategories = [
    'Entertainment',
    'Food',
    'Transportation',
    'Shopping',
    'Utilities',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (_submitted) {
          if (state is FinanceLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.isIncome ? 'Income added!' : 'Expense added!',
                ),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is FinanceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            setState(() => _submitted = false);
          }
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isIncome ? 'Add Income' : 'Add Expense',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      (widget.isIncome ? _incomeCategories : _expenseCategories)
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _category = val),
                  validator: (val) => val == null ? 'Select a category' : null,
                ),
                if (!widget.isIncome) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sub-Category',
                    ),
                    maxLength: 30,
                    onChanged: (val) => _subCategory = val,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Enter sub-category';
                      if (val.length > 30) return 'Max 30 characters';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLength: 256,
                  onChanged: (val) => _description = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter amount';
                    final d = double.tryParse(val);
                    if (d == null || d <= 0) return 'Enter a valid amount';
                    return null;
                  },
                  onChanged: (val) => _amount = double.tryParse(val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Date:'),
                    const SizedBox(width: 12),
                    Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: firstDay,
                          lastDate: lastDay,
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _submitted = true);
                      final uuid = const Uuid();
                      if (widget.isIncome) {
                        final entry = IncomeEntry(
                          id: uuid.v4(),
                          category: _category!,
                          description: _description,
                          date: _selectedDate,
                          amount: _amount!,
                        );
                        context.read<FinanceBloc>().add(AddIncome(entry));
                      } else {
                        final entry = ExpenseEntry(
                          id: uuid.v4(),
                          category: _category!,
                          subCategory: _subCategory!,
                          description: _description,
                          date: _selectedDate,
                          amount: _amount!,
                        );
                        context.read<FinanceBloc>().add(AddExpense(entry));
                      }
                    }
                  },
                  child: Text(widget.isIncome ? 'Add Income' : 'Add Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
