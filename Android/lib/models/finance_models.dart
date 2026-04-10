import 'package:flutter/material.dart';

enum TransactionKind { income, expense }

class FinanceCategory {
  final String id;
  final String title;
  final String symbol; // Using Lucide icon names or similar
  final List<Color> colors;

  FinanceCategory({
    required this.id,
    required this.title,
    required this.symbol,
    required this.colors,
  });
}

class TransactionItem {
  final String id;
  final TransactionKind kind;
  final double amount;
  final String? categoryID;
  final String categoryTitle;
  final String categorySymbol;
  final List<Color> categoryColors;
  final DateTime date;
  final String note;

  TransactionItem({
    required this.id,
    required this.kind,
    required this.amount,
    this.categoryID,
    required this.categoryTitle,
    required this.categorySymbol,
    required this.categoryColors,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'amount': amount,
      'categoryID': categoryID,
      'categoryTitle': categoryTitle,
      'categorySymbol': categorySymbol,
      'categoryColors': categoryColors.map((c) => c.value).toList(),
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      kind: TransactionKind.values.firstWhere((e) => e.name == json['kind']),
      amount: json['amount'].toDouble(),
      categoryID: json['categoryID'],
      categoryTitle: json['categoryTitle'],
      categorySymbol: json['categorySymbol'],
      categoryColors: (json['categoryColors'] as List).map((v) => Color(v)).toList(),
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
    );
  }
}

class MonthlySnapshot {
  final double income;
  final double expenses;
  final double balance;

  MonthlySnapshot({
    required this.income,
    required this.expenses,
    required this.balance,
  });
}

final List<FinanceCategory> categoryDefaults = [
  FinanceCategory(id: 'food', title: 'Food', symbol: 'utensils', colors: [Color(0xFF86A89C), Color(0xFF4F6B63)]),
  FinanceCategory(id: 'travel', title: 'Travel', symbol: 'plane', colors: [Color(0xFF7D95B8), Color(0xFF4D6387)]),
  FinanceCategory(id: 'shopping', title: 'Shopping', symbol: 'shopping-bag', colors: [Color(0xFFAE93A9), Color(0xFF765C77)]),
  FinanceCategory(id: 'salary', title: 'Salary', symbol: 'banknote', colors: [Color(0xFF8FAE8A), Color(0xFF557253)]),
  FinanceCategory(id: 'freelance', title: 'Freelance', symbol: 'laptop', colors: [Color(0xFFC4A780), Color(0xFF8B6B49)]),
  FinanceCategory(id: 'bills', title: 'Bills', symbol: 'zap', colors: [Color(0xFFB88C7D), Color(0xFF7E584A)]),
  FinanceCategory(id: 'health', title: 'Health', symbol: 'briefcase-medical', colors: [Color(0xFF7CA0A8), Color(0xFF4E6970)]),
  FinanceCategory(id: 'savings', title: 'Savings', symbol: 'shield-check', colors: [Color(0xFF8F97BB), Color(0xFF5D648B)]),
];
