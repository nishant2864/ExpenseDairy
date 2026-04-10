import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../models/finance_models.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/ui_elements.dart';
import '../widgets/home_components.dart' hide GlassCard;

class AddTransactionScreen extends StatefulWidget {
  final String kind;
  final VoidCallback? onSave;

  const AddTransactionScreen({super.key, required this.kind, this.onSave});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();
  late TransactionKind _kind;
  FinanceCategory? _selectedCategory;
  DateTime _date = DateTime.now();
  bool _useCustomCategory = false;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.kind == 'income' ? TransactionKind.income : TransactionKind.expense;
    _selectedCategory = categoryDefaults.first;
  }

  void _submit() {
    setState(() => _showValidation = true);
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    
    TransactionItem item;
    if (_useCustomCategory) {
      final title = _customCategoryController.text.trim();
      if (title.isEmpty) return;
      
      final palette = [const Color(0xFF8A9CB4), const Color(0xFF586B84)]; // Simple default palette
      item = TransactionItem(
        id: const Uuid().v4(),
        kind: _kind,
        amount: amount,
        categoryID: null,
        categoryTitle: title,
        categorySymbol: _kind == TransactionKind.income ? 'sparkles' : 'circle',
        categoryColors: palette,
        date: _date,
        note: _noteController.text.trim(),
      );
    } else {
      if (_selectedCategory == null) return;
      item = TransactionItem(
        id: const Uuid().v4(),
        kind: _kind,
        amount: amount,
        categoryID: _selectedCategory!.id,
        categoryTitle: _selectedCategory!.title,
        categorySymbol: _selectedCategory!.symbol,
        categoryColors: _selectedCategory!.colors,
        date: _date,
        note: _noteController.text.trim(),
      );
    }

    provider.addTransaction(item);
    Navigator.pop(context);
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AppBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 22),
                _buildKindPicker(),
                const SizedBox(height: 22),
                _buildInputCard('Amount', _buildAmountField()),
                const SizedBox(height: 22),
                _buildInputCard('Category', _buildCategorySection()),
                const SizedBox(height: 22),
                _buildInputCard('Date', _buildDatePicker()),
                const SizedBox(height: 22),
                _buildInputCard('Note', _buildNoteField()),
                const SizedBox(height: 30),
                PrimaryButton(title: 'Save transaction', action: _submit),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add transaction',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        Text(
          'Capture spending while it’s still fresh. A few details now make the monthly picture clear later.',
          style: TextStyle(fontSize: 15, color: Colors.white54, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildKindPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _kindButton('Expense', TransactionKind.expense),
          _kindButton('Income', TransactionKind.income),
        ],
      ),
    );
  }

  Widget _kindButton(String label, TransactionKind kind) {
    bool isSelected = _kind == kind;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kind = kind),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String title, Widget body) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          body,
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        border: InputBorder.none,
        errorText: (_showValidation && (double.tryParse(_amountController.text) ?? 0) <= 0) 
            ? 'Enter a valid amount greater than zero.' : null,
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Use custom category', style: TextStyle(color: Colors.white, fontSize: 15)),
            Switch(
              value: _useCustomCategory,
              onChanged: (v) => setState(() => _useCustomCategory = v),
              activeColor: Colors.white,
            ),
          ],
        ),
        if (_useCustomCategory)
          TextField(
            controller: _customCategoryController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Custom category name',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              border: InputBorder.none,
              errorText: (_showValidation && _useCustomCategory && _customCategoryController.text.trim().isEmpty) 
                  ? 'Add a category name.' : null,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryDefaults.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final cat = categoryDefaults[index];
              bool isSelected = _selectedCategory?.id == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryIcon(symbol: cat.symbol, colors: cat.colors, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        cat.title, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5), 
                          fontSize: 12, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        )
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return CalendarDatePicker(
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      onDateChanged: (d) => setState(() => _date = d),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      style: const TextStyle(color: Colors.white),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Optional note',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        border: InputBorder.none,
      ),
    );
  }
}
