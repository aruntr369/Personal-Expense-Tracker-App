abstract class HiveNames {
  static const String incomeBoxName = 'incomeBox';
  static const String expenseBoxName = 'expenseBox';
  static const String categoryLimitBoxName = 'categoryLimitBox';
}

abstract class CategoryTypes {
  static const List<String> income = [
    'Salary',
    'Bonus',
    'Freelance',
    'Interest',
  ];
  static const List<String> expense = [
    'Entertainment',
    'Food',
    'Transportation',
    'Shopping',
    'Utilities',
    'Other',
  ];
}
