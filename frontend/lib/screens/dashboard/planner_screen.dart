import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../widgets/glass_container.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);
    final lang = ref.watch(languageProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(AppTranslations.t('navPlanner', lang), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Tiro Bangla')),
        ),
        Expanded(
          child: plansAsync.when(
            data: (plans) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 120),
                children: [
                  // Inline Form Card (JSX style)
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.notebookPen, color: AppColors.deepText, size: 16),
                            const SizedBox(width: 8),
                            Text(AppTranslations.t('plannerTitle', lang), style: const TextStyle(color: AppColors.deepText, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(AppTranslations.t('plannerSub', lang), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        const SizedBox(height: 16),
                        
                        Text(AppTranslations.t('forDate', lang), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            children: [
                              Text('2026-08-17', style: TextStyle(color: Colors.white, fontSize: 14)), // Placeholder
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(AppTranslations.t('plannerTitle', lang), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(AppTranslations.t('planPlaceholder', lang), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ),
                        const SizedBox(height: 16),

                        Container(
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
                          child: Text(AppTranslations.t('savePlan', lang), style: const TextStyle(color: Color(0xFF3B1E00), fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(AppTranslations.t('yourPlans', lang), style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  if (plans.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text(AppTranslations.t('noPlans', lang), style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    )
                  else
                    ...plans.map((plan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(plan['planDate'] ?? '', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  const Icon(LucideIcons.trash2, color: Colors.white54, size: 14),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(plan['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.5)),
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
}
