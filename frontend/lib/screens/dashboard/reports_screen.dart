import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../core/ui_utils.dart';
import '../../widgets/glass_container.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final trendAsync = ref.watch(monthlyTrendProvider);
    final now = DateTime.now();
    final currentMonthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final catAsync = ref.watch(categoryBreakdownProvider(currentMonthStr)); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            AppTranslations.t('navReports', lang), 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Tiro Bangla')
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 120),
            child: Column(
              children: [
                trendAsync.when(
                  data: (trendsRaw) {
                    if (trendsRaw.isEmpty) return const SizedBox.shrink();
                    
                    // Pad trends to have at least 6 items for better UI layout
                    final trends = List<dynamic>.from(trendsRaw);
                    while (trends.length < 6) {
                      trends.insert(0, {'month': '', 'income': 0, 'expense': 0});
                    }

                    return GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.t('trendTitle', lang),
                            style: const TextStyle(color: AppColors.deepText, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(trends),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) => Colors.white.withOpacity(0.8),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      if (rod.toY == 0) return null;
                                      final isIncome = rodIndex == 0;
                                      return BarTooltipItem(
                                        UiUtils.formatAmount(rod.toY, lang),
                                        TextStyle(
                                          color: isIncome ? AppColors.income : AppColors.expense,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 && value.toInt() < trends.length) {
                                          final rawMonth = trends[value.toInt()]['month'] ?? '';
                                          if (rawMonth.isEmpty) return const SizedBox.shrink();
                                          final translatedMonth = _getMonthLabel(rawMonth, lang);
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              translatedMonth,
                                              style: const TextStyle(color: AppColors.muted, fontSize: 10),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                                barGroups: List.generate(trends.length, (index) {
                                  final trend = trends[index];
                                  final rawI = trend['income'] ?? 0;
                                  final rawE = trend['expense'] ?? 0;
                                  final income = (rawI is num) ? rawI.toDouble() : double.tryParse(rawI.toString()) ?? 0.0;
                                  final expense = (rawE is num) ? rawE.toDouble() : double.tryParse(rawE.toString()) ?? 0.0;
                                  return BarChartGroupData(
                                    x: index,
                                    barsSpace: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: income,
                                        color: AppColors.income,
                                        width: 12,
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      BarChartRodData(
                                        toY: expense,
                                        color: AppColors.expense,
                                        width: 12,
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                ),
                const SizedBox(height: 16),
                catAsync.when(
                  data: (cats) {
                    if (cats.isEmpty) {
                      return GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Center(
                          child: Text(
                            AppTranslations.t('noTxn', lang),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }
                    return GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.t('catTitle', lang),
                            style: const TextStyle(color: AppColors.deepText, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 28,
                                    sections: List.generate(cats.length, (index) {
                                      final cat = cats[index];
                                      final rawVal = cat['value'] ?? 0;
                                      final value = (rawVal is num) ? rawVal.toDouble() : double.tryParse(rawVal.toString()) ?? 0.0;
                                      return PieChartSectionData(
                                        color: _getCategoryColor(cat['id'] ?? ''),
                                        value: value,
                                        title: '',
                                        radius: 26,
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: cats.map<Widget>((cat) {
                                    final id = cat['id'] ?? '';
                                    final label = _getCategoryLabel(id, lang);
                                    final val = cat['value'] ?? 0;
                                    final color = _getCategoryColor(id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                              const SizedBox(width: 6),
                                              Text(label, style: const TextStyle(color: AppColors.ink, fontSize: 12)),
                                            ],
                                          ),
                                          Text(
                                            UiUtils.formatAmount(val, lang),
                                            style: const TextStyle(color: AppColors.muted, fontSize: 12, fontFamily: 'Space Grotesk'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  error: (err, stack) => Center(child: Text('Chart Error: $err', style: const TextStyle(color: Colors.redAccent))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxY(List<dynamic> trends) {
    double max = 0;
    for (var t in trends) {
      final rawI = t['income'] ?? 0;
      final rawE = t['expense'] ?? 0;
      final i = (rawI is num) ? rawI.toDouble() : double.tryParse(rawI.toString()) ?? 0.0;
      final e = (rawE is num) ? rawE.toDouble() : double.tryParse(rawE.toString()) ?? 0.0;
      if (i > max) max = i;
      if (e > max) max = e;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  Color _getCategoryColor(String id) {
    switch (id) {
      case 'food': return const Color(0xFFFF6F61);
      case 'rent': return const Color(0xFFD89A4E);
      case 'transport': return const Color(0xFF6FA0E8);
      case 'bills': return const Color(0xFFE8B84B);
      case 'shopping': return const Color(0xFFB27FE8);
      case 'health': return const Color(0xFFE87FB0);
      case 'education': return const Color(0xFF2FBF9F);
      case 'loanGiven': return AppColors.lent;
      case 'loanRepayExpense': return AppColors.expense;
      default: return const Color(0xFF8B7D93);
    }
  }

  String _getCategoryLabel(String id, String lang) {
    final bnMap = {
      'food': 'খাবার', 'rent': 'বাসাভাড়া', 'transport': 'যাতায়াত', 'bills': 'বিল',
      'shopping': 'কেনাকাটা', 'health': 'স্বাস্থ্য', 'education': 'শিক্ষা', 'other': 'অন্যান্য',
      'loanGiven': 'ধার দেওয়া', 'loanRepayExpense': 'ধার শোধ করলাম',
    };
    final enMap = {
      'food': 'Food', 'rent': 'Rent', 'transport': 'Transport', 'bills': 'Bills',
      'shopping': 'Shopping', 'health': 'Health', 'education': 'Education', 'other': 'Other',
      'loanGiven': 'Loan given', 'loanRepayExpense': 'Loan repaid by me',
    };
    return (lang == 'bn' ? bnMap[id] : enMap[id]) ?? id;
  }

  String _getMonthLabel(String rawMonth, String lang) {
    final bnMap = {
      'mar': 'মার্চ', 'apr': 'এপ্রিল', 'may': 'মে', 'jun': 'জুন', 'jul': 'জুলাই', 'aug': 'আগস্ট'
    };
    final enMap = {
      'mar': 'Mar', 'apr': 'Apr', 'may': 'May', 'jun': 'Jun', 'jul': 'Jul', 'aug': 'Aug'
    };
    return (lang == 'bn' ? bnMap[rawMonth.toLowerCase()] : enMap[rawMonth.toLowerCase()]) ?? rawMonth;
  }
}
