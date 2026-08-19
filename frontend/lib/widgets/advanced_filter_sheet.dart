import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../core/ui_utils.dart';

class AdvancedFilterSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialFilters;
  final Map<String, Map<String, dynamic>> catData;

  const AdvancedFilterSheet({super.key, this.initialFilters, required this.catData});

  @override
  ConsumerState<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends ConsumerState<AdvancedFilterSheet> {
  late List<String> _selectedCategories;
  DateTime? _fromDate;
  DateTime? _toDate;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters ?? {};
    _selectedCategories = List<String>.from(f['categories'] ?? []);
    _fromDate = f['fromDate'];
    _toDate = f['toDate'];
    if (f['minAmount'] != null) _minController.text = f['minAmount'].toString();
    if (f['maxAmount'] != null) _maxController.text = f['maxAmount'].toString();
  }

  void _apply() {
    final filters = {
      'categories': _selectedCategories,
      'fromDate': _fromDate,
      'toDate': _toDate,
      'minAmount': double.tryParse(_minController.text),
      'maxAmount': double.tryParse(_maxController.text),
    };
    Navigator.pop(context, filters);
  }

  void _reset() {
    setState(() {
      _selectedCategories.clear();
      _fromDate = null;
      _toDate = null;
      _minController.clear();
      _maxController.clear();
    });
  }

  Future<void> _pickDate(bool isToDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isToDate ? (_toDate ?? DateTime.now()) : (_fromDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isToDate) {
          _toDate = picked;
        } else {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = _fromDate;
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
                    Text(AppTranslations.t('advFilterTitle', lang), style: const TextStyle(color: AppColors.deepText, fontSize: 19, fontFamily: 'Tiro Bangla', fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(LucideIcons.x, color: AppColors.muted, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories
                Text(AppTranslations.t('categoryLabelMulti', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.catData.keys.map((c) {
                    final isSelected = _selectedCategories.contains(c);
                    final catName = widget.catData[c]?[lang] ?? c;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) _selectedCategories.remove(c);
                          else _selectedCategories.add(c);
                        });
                      },
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

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTranslations.t('dateFrom', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
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
                                  Text(_fromDate != null ? UiUtils.formatDate(_fromDate, lang) : 'mm/dd/yyyy', style: const TextStyle(color: AppColors.ink, fontSize: 14)),
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
                          Text(AppTranslations.t('dateTo', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
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
                                  Text(_toDate != null ? UiUtils.formatDate(_toDate, lang) : 'mm/dd/yyyy', style: const TextStyle(color: AppColors.ink, fontSize: 14)),
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
                const SizedBox(height: 16),

                // Amounts
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTranslations.t('minAmount', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white),
                            ),
                            child: TextField(
                              controller: _minController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.ink, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: AppColors.mutedLight, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                          Text(AppTranslations.t('maxAmount', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white),
                            ),
                            child: TextField(
                              controller: _maxController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.ink, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: '৯৯৯৯৯',
                                hintStyle: TextStyle(color: AppColors.mutedLight, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _reset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppTranslations.t('resetFilters', lang), style: const TextStyle(color: AppColors.deepText, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _apply,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF0C563)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(AppTranslations.t('applyFilters', lang), style: const TextStyle(color: Color(0xFF3B1E00), fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
