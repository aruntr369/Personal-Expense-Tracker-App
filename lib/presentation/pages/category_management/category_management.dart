import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/injections/dependency_injections.dart';
import '../../../../domain/entities/category_limit.dart';
import '../../bloc/category_management/category_management_bloc.dart';
import '../../bloc/category_management/category_management_event.dart';
import '../../bloc/category_management/category_management_state.dart';

@RoutePage()
class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryManagementBloc>()..add(LoadCategoryLimits()),
      child: const _CategoryManagementView(),
    );
  }
}

class _CategoryManagementView extends StatelessWidget {
  const _CategoryManagementView();

  void _showEditLimitDialog(BuildContext context, CategoryLimit category) {
    final TextEditingController controller = TextEditingController(
      text:
          category.limitAmount > 0
              ? category.limitAmount.toStringAsFixed(0)
              : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Set Limit for ${category.category}"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: "₹ ",
                labelText: "Monthly Limit",
                hintText: '0 for no limit',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  // Allow empty for no limit
                  return null;
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newLimit = double.tryParse(controller.text) ?? 0.0;
                  final updatedCategory = CategoryLimit(
                    category: category.category,
                    limitAmount: newLimit,
                  );
                  // Dispatch event to BLoC
                  context.read<CategoryManagementBloc>().add(
                    UpdateLimit(updatedCategory),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Category Limits")),
      body: BlocConsumer<CategoryManagementBloc, CategoryManagementState>(
        listener: (context, state) {
          if (state is CategoryManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryManagementLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final hasLimit = category.limitAmount > 0;
                return ListTile(
                  title: Text(
                    category.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    hasLimit
                        ? 'Limit: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(category.limitAmount)}'
                        : 'No limit set',
                    style: TextStyle(
                      color: hasLimit ? Colors.blue : Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _showEditLimitDialog(context, category),
                );
              },
            );
          }
          return const Center(child: Text("Loading categories..."));
        },
      ),
    );
  }
}
