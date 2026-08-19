import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../core/ui_utils.dart';
import '../../services/api_service.dart';
import '../../providers/dashboard_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String _categoryId = 'food';
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = ['food', 'rent', 'transport', 'bills', 'shopping', 'health', 'education', 'other'];
  final List<String> _incomeCategories = ['salary', 'business', 'other_income'];
  
  static const Map<String, Map<String, dynamic>> _catData = {
    'food': {'bn': 'খাবার', 'en': 'Food'},
    'rent': {'bn': 'বাসাভাড়া', 'en': 'Rent'},
    'transport': {'bn': 'যাতায়াত', 'en': 'Transport'},
    'bills': {'bn': 'বিল', 'en': 'Bills'},
    'shopping': {'bn': 'কেনাকাটা', 'en': 'Shopping'},
    'health': {'bn': 'স্বাস্থ্য', 'en': 'Health'},
    'education': {'bn': 'শিক্ষা', 'en': 'Education'},
    'other': {'bn': 'অন্যান্য', 'en': 'Other'},
    'salary': {'bn': 'বেতন', 'en': 'Salary'},
    'business': {'bn': 'ব্যবসা', 'en': 'Business'},
    'other_income': {'bn': 'অন্যান্য আয়', 'en': 'Other income'},
  };

  List<String> get _currentCategories => _type == 'expense' ? _expenseCategories : _incomeCategories;

  Future<void> _submit() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'type': _type,
        'categoryId': _categoryId,
        'amount': double.parse(_amountController.text),
        'note': _noteController.text,
        'txnDate': _selectedDate.toIso8601String().split('T')[0],
      };
      await ref.read(apiServiceProvider).createTransaction(data);
      ref.invalidate(dashboardProvider);
      ref.invalidate(transactionsProvider);
      if (mounted) {
        Navigator.pop(context);
        UiUtils.showSuccessPopup(context, AppTranslations.t('saveSuccess', ref.read(languageProvider)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 250, 244, 0.9),
            border: Border(top: BorderSide(color: Colors.white)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppTranslations.t('addTxnTitle', lang), style: const TextStyle(color: AppColors.deepText, fontSize: 19, fontFamily: 'Tiro Bangla', fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(LucideIcons.x, color: AppColors.muted, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Type Toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _categoryId = _expenseCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'expense' ? AppColors.expense : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.08)),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppTranslations.t('fExpense', lang), style: TextStyle(color: _type == 'expense' ? Colors.white : AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _categoryId = _incomeCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'income' ? AppColors.income : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.08)),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppTranslations.t('fIncome', lang), style: TextStyle(color: _type == 'income' ? Colors.white : AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                Text(AppTranslations.t('amountLabel', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.ink, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: AppTranslations.t('amountPh', lang),
                      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category
                Text(AppTranslations.t('categoryLabel', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _currentCategories.map((c) {
                    final isSelected = _categoryId == c;
                    final catName = _catData[c]?[lang] ?? c;
                    return GestureDetector(
                      onTap: () => setState(() => _categoryId = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.deepText : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.deepText : Colors.white),
                        ),
                        child: Text(catName, style: TextStyle(color: isSelected ? Colors.white : AppColors.ink, fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Note
                Text(AppTranslations.t('noteLabel', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(color: AppColors.ink, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppTranslations.t('notePhTxn', lang),
                      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date
                Text(AppTranslations.t('dateLabel', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedDate != null ? UiUtils.formatDate(_selectedDate, lang) : 'mm/dd/yyyy', style: const TextStyle(color: AppColors.ink, fontSize: 15)),
                        const Icon(LucideIcons.calendarDays, color: AppColors.ink, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF0C563)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF3B1E00), strokeWidth: 2))
                        : Text(AppTranslations.t('save', lang), style: const TextStyle(color: Color(0xFF3B1E00), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
