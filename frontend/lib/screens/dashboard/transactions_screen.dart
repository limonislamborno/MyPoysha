import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../core/ui_utils.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/advanced_filter_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // all, income, expense
  Map<String, dynamic>? _advFilters;

  static const Map<String, Map<String, dynamic>> _catData = {
    'food': {'color': Color(0xFFFF6F61), 'icon': LucideIcons.utensilsCrossed, 'bn': 'খাবার', 'en': 'Food'},
    'rent': {'color': Color(0xFFD89A4E), 'icon': LucideIcons.home, 'bn': 'বাসাভাড়া', 'en': 'Rent'},
    'transport': {'color': Color(0xFF6FA0E8), 'icon': LucideIcons.bus, 'bn': 'যাতায়াত', 'en': 'Transport'},
    'bills': {'color': Color(0xFFE8B84B), 'icon': LucideIcons.zap, 'bn': 'বিল', 'en': 'Bills'},
    'shopping': {'color': Color(0xFFB27FE8), 'icon': LucideIcons.shoppingBag, 'bn': 'কেনাকাটা', 'en': 'Shopping'},
    'health': {'color': Color(0xFFE87FB0), 'icon': LucideIcons.heartPulse, 'bn': 'স্বাস্থ্য', 'en': 'Health'},
    'education': {'color': Color(0xFF2FBF9F), 'icon': LucideIcons.graduationCap, 'bn': 'শিক্ষা', 'en': 'Education'},
    'other': {'color': Color(0xFF8B7D93), 'icon': LucideIcons.moreHorizontal, 'bn': 'অন্যান্য', 'en': 'Other'},
    'loan_given': {'color': AppColors.lent, 'icon': LucideIcons.handCoins, 'bn': 'ধার দেওয়া', 'en': 'Loan given'},
    'loan_repay_expense': {'color': AppColors.expense, 'icon': LucideIcons.handCoins, 'bn': 'ধার শোধ করলাম', 'en': 'Loan repaid by me'},
    'salary': {'color': AppColors.income, 'icon': LucideIcons.briefcase, 'bn': 'বেতন', 'en': 'Salary'},
    'business': {'color': AppColors.income, 'icon': LucideIcons.trendingUp, 'bn': 'ব্যবসা', 'en': 'Business'},
    'other_income': {'color': AppColors.income, 'icon': LucideIcons.gift, 'bn': 'অন্যান্য আয়', 'en': 'Other income'},
    'loan_taken': {'color': AppColors.income, 'icon': LucideIcons.handCoins, 'bn': 'ধার নেওয়া', 'en': 'Loan taken'},
    'loan_repay_income': {'color': AppColors.income, 'icon': LucideIcons.handCoins, 'bn': 'ধার ফেরত পেলাম', 'en': 'Loan repaid to me'},
  };

  @override
  Widget build(BuildContext context) {
    final txnsAsync = ref.watch(transactionsProvider);
    final lang = ref.watch(languageProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(AppTranslations.t('navTxns', lang), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Tiro Bangla')),
        ),
        
        // Search & Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, color: Colors.white60, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppTranslations.t('searchTxn', lang),
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final result = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AdvancedFilterSheet(initialFilters: _advFilters, catData: _catData),
                  );
                  if (result != null) {
                    setState(() => _advFilters = result);
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 12,
                      child: Icon(LucideIcons.slidersHorizontal, color: _advFilters != null ? AppColors.gold : Colors.white70, size: 16),
                    ),
                    if (_advFilters != null && (_advFilters!['categories'].isNotEmpty || _advFilters!['fromDate'] != null || _advFilters!['toDate'] != null || _advFilters!['minAmount'] != null || _advFilters!['maxAmount'] != null))
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.income,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Type Pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildPill('all', AppTranslations.t('fAll', lang)),
              const SizedBox(width: 8),
              _buildPill('income', AppTranslations.t('fIncome', lang)),
              const SizedBox(width: 8),
              _buildPill('expense', AppTranslations.t('fExpense', lang)),
            ],
          ),
        ),

        Expanded(
          child: txnsAsync.when(
            data: (txns) {
              final filteredTxns = txns.where((txn) {
                if (_filter != 'all' && txn['type'] != _filter) return false;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  final cat = (txn['categoryId'] ?? '').toLowerCase();
                  final note = (txn['note'] ?? '').toLowerCase();
                  if (!cat.contains(q) && !note.contains(q)) return false;
                }

                if (_advFilters != null) {
                  final cats = _advFilters!['categories'] as List<String>? ?? [];
                  if (cats.isNotEmpty && !cats.contains(txn['categoryId'])) return false;
                  
                  final from = _advFilters!['fromDate'] as DateTime?;
                  final to = _advFilters!['toDate'] as DateTime?;
                  if (from != null || to != null) {
                    final dateStr = txn['txnDate'] as String?;
                    if (dateStr != null && dateStr.isNotEmpty) {
                      final dt = DateTime.tryParse(dateStr);
                      if (dt != null) {
                        if (from != null && dt.isBefore(from)) return false;
                        if (to != null && dt.isAfter(to.add(const Duration(days: 1)))) return false;
                      }
                    }
                  }
                  
                  final minA = _advFilters!['minAmount'] as double?;
                  if (minA != null && (txn['amount'] ?? 0) < minA) return false;
                  
                  final maxA = _advFilters!['maxAmount'] as double?;
                  if (maxA != null && (txn['amount'] ?? 0) > maxA) return false;
                }

                return true;
              }).toList();

              if (filteredTxns.isEmpty) {
                return Center(child: Text(AppTranslations.t('noTxn', lang), style: const TextStyle(color: Colors.white70)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 120),
                itemCount: filteredTxns.length,
                itemBuilder: (context, index) {
                  final txn = filteredTxns[index];
                  final isIncome = txn['type'] == 'income';
                  final rawCat = txn['categoryId'] ?? 'other';
                  final catMeta = _catData[rawCat] ?? _catData['other']!;
                  final color = isIncome ? AppColors.income : (catMeta['color'] as Color);
                  final icon = catMeta['icon'] as IconData;
                  final label = catMeta[lang] as String? ?? rawCat;
                  final note = txn['note'];
                  final dateStr = txn['txnDate'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                                if (note != null && note.toString().isNotEmpty || dateStr.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '${note != null && note.toString().isNotEmpty ? note : ''}${note != null && note.toString().isNotEmpty && dateStr.isNotEmpty ? " · " : ""}${UiUtils.formatDate(dateStr, lang, format: "MMM d, yyyy")}',
                                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${isIncome ? '+' : '-'}${UiUtils.formatAmount(txn['amount'], lang)}',
                            style: TextStyle(
                              color: isIncome ? AppColors.income : AppColors.expense,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          ),
        ),
      ],
    );
  }

  Widget _buildPill(String value, String label) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.deepText : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.deepText : Colors.white70),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
