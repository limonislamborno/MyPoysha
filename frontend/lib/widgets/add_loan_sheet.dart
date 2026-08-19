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

class AddLoanSheet extends ConsumerStatefulWidget {
  const AddLoanSheet({super.key});

  @override
  ConsumerState<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends ConsumerState<AddLoanSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'lent';
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'type': _type,
        'personName': _nameController.text,
        'amount': double.parse(_amountController.text),
        'note': _noteController.text,
        'loanDate': _selectedDate.toIso8601String().split('T')[0],
        'dueDate': _dueDate.toIso8601String().split('T')[0],
      };
      await ref.read(apiServiceProvider).createLoan(data);
      ref.invalidate(dashboardProvider);
      ref.invalidate(loansProvider);
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

  Future<void> _pickDate(bool isDueDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _dueDate : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _selectedDate = picked;
          if (_dueDate.isBefore(_selectedDate)) {
            _dueDate = _selectedDate.add(const Duration(days: 30));
          }
        }
      });
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
                    Text(AppTranslations.t('addLoanTitle', lang), style: const TextStyle(color: AppColors.deepText, fontSize: 19, fontFamily: 'Tiro Bangla', fontWeight: FontWeight.bold)),
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
                        onTap: () => setState(() => _type = 'lent'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'lent' ? AppColors.lent : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.08)),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppTranslations.t('lentTab', lang), style: TextStyle(color: _type == 'lent' ? Colors.white : AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = 'borrowed'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'borrowed' ? AppColors.borrow : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.08)),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppTranslations.t('borrowedTab', lang), style: TextStyle(color: _type == 'borrowed' ? Colors.white : AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                Text(_type == 'lent' ? AppTranslations.t('lentTo', lang) : AppTranslations.t('borrowedFrom', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.ink, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: AppTranslations.t('namePh', lang),
                      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
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
                      hintText: AppTranslations.t('amountPhLoan', lang),
                      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
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
                      hintText: AppTranslations.t('notePhLoan', lang),
                      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTranslations.t('dateLabel', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _pickDate(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedDate != null ? UiUtils.formatDate(_selectedDate, lang) : 'mm/dd/yyyy', style: const TextStyle(color: AppColors.ink, fontSize: 14)),
                                  const Icon(LucideIcons.calendarDays, color: AppColors.ink, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTranslations.t('returnDate', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _pickDate(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_dueDate != null ? UiUtils.formatDate(_dueDate, lang) : 'mm/dd/yyyy', style: const TextStyle(color: AppColors.ink, fontSize: 14)),
                                  const Icon(LucideIcons.calendarDays, color: AppColors.ink, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
