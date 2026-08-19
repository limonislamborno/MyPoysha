import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../core/ui_utils.dart';
import '../../widgets/glass_container.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  String _loanTab = 'lent'; // lent, borrowed
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansProvider);
    final lang = ref.watch(languageProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(AppTranslations.t('navLoans', lang), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Tiro Bangla')),
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
                            hintText: AppTranslations.t('searchLoan', lang),
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
              GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: 12,
                child: const Icon(LucideIcons.slidersHorizontal, color: Colors.white70, size: 16),
              ),
            ],
          ),
        ),

        // Tab Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildTabBtn('lent', AppTranslations.t('lentTab', lang))),
              const SizedBox(width: 8),
              Expanded(child: _buildTabBtn('borrowed', AppTranslations.t('borrowedTab', lang))),
            ],
          ),
        ),

        Expanded(
          child: loansAsync.when(
            data: (loans) {
              double totalAmount = 0;
              double dueAmount = 0;

              for (var loan in loans) {
                if (loan['type'] == _loanTab) {
                  totalAmount += double.tryParse(loan['amount']?.toString() ?? '0') ?? 0;
                  dueAmount += (double.tryParse(loan['amount']?.toString() ?? '0') ?? 0) - (double.tryParse(loan['paidAmount']?.toString() ?? '0') ?? 0);
                }
              }

              final filteredLoans = loans.where((loan) {
                if (loan['type'] != _loanTab) return false;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  final person = (loan['personName'] ?? '').toLowerCase();
                  if (!person.contains(q)) return false;
                }
                return true;
              }).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 120),
                children: [
                  // Banner
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.circleDollarSign, color: _loanTab == 'lent' ? AppColors.lent : AppColors.borrow, size: 15),
                            const SizedBox(width: 8),
                            Text(_loanTab == 'lent' ? AppTranslations.t('totalLentBanner', lang) : AppTranslations.t('totalBorrowedBanner', lang), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(UiUtils.formatAmount(totalAmount, lang), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('${UiUtils.formatAmount(dueAmount, lang)} ${AppTranslations.t('stillDue', lang)}', style: const TextStyle(fontSize: 11.5, color: Colors.white60)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (filteredLoans.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text(AppTranslations.t('noLoan', lang), style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    )
                  else
                    ...filteredLoans.map((loan) {
                      final amount = double.tryParse(loan['amount']?.toString() ?? '0') ?? 0;
                      final paid = double.tryParse(loan['paidAmount']?.toString() ?? '0') ?? 0;
                      final due = amount - paid;
                      final pct = amount > 0 ? (paid / amount) : 0.0;
                      final note = loan['note']?.toString();
                      final person = loan['personName']?.toString() ?? '';
                      final dueDate = loan['dueDate']?.toString() ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(person, style: const TextStyle(color: AppColors.deepText, fontWeight: FontWeight.w600, fontSize: 14.5)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: due == 0 ? const Color.fromRGBO(47, 191, 159, 0.18) : const Color.fromRGBO(255, 111, 97, 0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      due == 0 ? AppTranslations.t('paidBadge', lang) : AppTranslations.t('dueBadge', lang),
                                      style: TextStyle(fontSize: 11, color: due == 0 ? AppColors.income : AppColors.expense),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(UiUtils.formatAmount(amount, lang), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                                  if (dueDate != null && dueDate.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, top: 2),
                                      child: Text('${AppTranslations.t('dueDateLabel', lang)}: ${UiUtils.formatDate(dueDate, lang)}', style: TextStyle(color: (due == 0) ? AppColors.income : const Color(0xFFE8935C), fontSize: 11.5)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (pct * 100).toInt(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _loanTab == 'lent' ? AppColors.lent : AppColors.borrow,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: ((1 - pct) * 100).toInt(),
                                      child: const SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${AppTranslations.t('paidSoFar', lang)} ${UiUtils.formatAmount(paid, lang)}', style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                                  if (dueDate.isNotEmpty)
                                    Text('${AppTranslations.t('dueDateLabel', lang)} $dueDate', style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBtn(String value, String label) {
    final isActive = _loanTab == value;
    return GestureDetector(
      onTap: () => setState(() => _loanTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.deepText : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.deepText : Colors.white70),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
