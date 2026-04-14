import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class FinanceProvider with ChangeNotifier {
  List<TransactionItem> _transactions = [];
  DateTime _selectedMonth = DateTime.now();
  String _userFirstName = '';
  String _userLastName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _profileImage;
  bool _hasCompletedOnboarding = false;
  String _cardNumber = '';
  bool _cardGenerated = false;
  ThemeMode _appearance = ThemeMode.system;

  List<TransactionItem> get transactions => _transactions;
  DateTime get selectedMonth => _selectedMonth;
  String get userFirstName => _userFirstName;
  String get userLastName => _userLastName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String? get profileImage => _profileImage;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String get cardNumber => _cardNumber;
  bool get cardGenerated => _cardGenerated;
  ThemeMode get appearance => _appearance;

  String get userDisplayName => (_userFirstName.isNotEmpty || _userLastName.isNotEmpty) 
      ? '${_userFirstName} ${_userLastName}'.trim() 
      : 'Friend';

  String get cardLast4 => _cardGenerated ? _cardNumber.replaceAll(' ', '').substring(_cardNumber.replaceAll(' ', '').length - 4) : '••••';
  
  String get cardExpiry {
    final expiry = DateTime(DateTime.now().year + 3, DateTime.now().month);
    return DateFormat('MM/yy').format(expiry);
  }

  FinanceProvider() {
    _loadData();
  }

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? _currentUserId;

  Future<void> refreshSession() async {
    final token = await AuthService.getToken();
    final userId = await AuthService.getUserId();
    
    if (token != null && userId != null) {
      _isAuthenticated = true;
      _currentUserId = userId;
      await _loadData();
    } else {
      _isAuthenticated = false;
      _currentUserId = null;
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    
    if (_currentUserId != null) {
      try {
        // Sync from Cloud
        _transactions = await ApiService.fetchTransactions(_currentUserId!);
      } catch (e) {
        print('Fallback to local: $e');
        await _loadLocalTransactions();
      }
    } else {
      await _loadLocalTransactions();
    }

    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('finance.app.onboardingDone') ?? false;
    
    final userNameJson = prefs.getString('finance.app.userName');
    if (userNameJson != null) {
      final decoded = jsonDecode(userNameJson);
      _userFirstName = decoded['first'] ?? '';
      _userLastName = decoded['last'] ?? '';
    }

    final userContactJson = prefs.getString('finance.app.userContact');
    if (userContactJson != null) {
      final decoded = jsonDecode(userContactJson);
      _userEmail = decoded['email'] ?? '';
      _userPhone = decoded['phone'] ?? '';
    }

    _profileImage = prefs.getString('finance.app.profileImage');

    final cardJson = prefs.getString('finance.app.card');
    if (cardJson != null) {
      final decoded = jsonDecode(cardJson);
      _cardNumber = decoded['number'] ?? '';
      _cardGenerated = decoded['generated'] ?? false;
    }

    final appearanceStr = prefs.getString('finance.app.appearance');
    if (appearanceStr != null) {
      _appearance = ThemeMode.values.firstWhere((e) => e.name == appearanceStr, orElse: () => ThemeMode.system);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadLocalTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('finance.app.transactions');
    if (transactionsJson != null) {
      final List decoded = jsonDecode(transactionsJson);
      _transactions = decoded.map((v) => TransactionItem.fromJson(v)).toList();
    }
  }

  Future<void> _saveTransactionsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('finance.app.transactions', encoded);
  }

  Future<void> addTransaction(TransactionItem item) async {
    if (_currentUserId == null) return;
    try {
      final data = item.toJson();
      data['userId'] = _currentUserId;
      final saved = await ApiService.addTransaction(data);
      _transactions.insert(0, saved);
    } catch (e) {
      // Fallback
      _transactions.insert(0, item);
      _saveTransactionsLocal();
    }
    notifyListeners();
  }

  Future<void> addSmartTransaction(String input) async {
    if (_currentUserId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final saved = await ApiService.smartLog(_currentUserId!, input);
      _transactions.insert(0, saved);
    } catch (e) {
      print('Smart Log Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveTransactionsLocal();
    notifyListeners();
  }

  Future<void> saveUserName(String first, String last) async {
    _userFirstName = first;
    _userLastName = last;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('finance.app.userName', jsonEncode({'first': first, 'last': last}));
    notifyListeners();
  }

  Future<void> saveContactInfo(String email, String phone) async {
    _userEmail = email;
    _userPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('finance.app.userContact', jsonEncode({'email': email, 'phone': phone}));
    notifyListeners();
  }

  Future<void> saveProfileImage(String? uri) async {
    _profileImage = uri;
    final prefs = await SharedPreferences.getInstance();
    if (uri != null) {
      await prefs.setString('finance.app.profileImage', uri);
    } else {
      await prefs.remove('finance.app.profileImage');
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('finance.app.onboardingDone', true);
    notifyListeners();
  }

  Future<void> generateCard() async {
    if (_cardGenerated) return;
    final random = Random();
    String digits = '';
    for (int i = 0; i < 16; i++) {
      digits += random.nextInt(10).toString();
    }
    _cardNumber = digits.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ").trim();
    _cardGenerated = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('finance.app.card', jsonEncode({'number': _cardNumber, 'generated': true}));
    notifyListeners();
  }

  Future<void> destroyCard() async {
    _cardNumber = '';
    _cardGenerated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('finance.app.card');
    notifyListeners();
  }

  Future<void> setAppearance(ThemeMode mode) async {
    _appearance = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('finance.app.appearance', mode.name);
    notifyListeners();
  }

  void setSelectedMonth(DateTime date) {
    _selectedMonth = date;
    notifyListeners();
  }

  String formatCurrency(double amount) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    return currencyFormat.format(amount);
  }

  List<TransactionItem> get currentMonthTransactions {
    return _transactions.where((t) {
      return t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  MonthlySnapshot get monthlySnapshot {
    final current = currentMonthTransactions;
    final income = current.where((t) => t.kind == TransactionKind.income).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = current.where((t) => t.kind == TransactionKind.expense).fold(0.0, (sum, t) => sum + t.amount);
    return MonthlySnapshot(income: income, expenses: expenses, balance: income - expenses);
  }

  List<TransactionItem> get recentTransactions {
    final sorted = List<TransactionItem>.from(_transactions)..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(8).toList();
  }

  bool get hasTransactions => _transactions.isNotEmpty;

  List<Map<String, dynamic>> monthlyTotalsByCategory(TransactionKind kind) {
    final filtered = currentMonthTransactions.where((t) => t.kind == kind);
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var t in filtered) {
      if (!grouped.containsKey(t.categoryTitle)) {
        grouped[t.categoryTitle] = {
          'category': t.categoryTitle,
          'total': 0.0,
          'colors': t.categoryColors,
          'symbol': t.categorySymbol,
        };
      }
      grouped[t.categoryTitle]!['total'] += t.amount;
    }

    final result = grouped.values.toList();
    result.sort((a, b) => b['total'].compareTo(a['total']));
    return result;
  }
}
