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

class AddPlanSheet extends ConsumerStatefulWidget {
  const AddPlanSheet({super.key});

  @override
  ConsumerState<AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends ConsumerState<AddPlanSheet> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  Future<void> _submit() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'text': _textController.text,
        'planDate': _selectedDate.toIso8601String().split('T')[0],
      };
      await ref.read(apiServiceProvider).createPlan(data);
      ref.invalidate(plansProvider);
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
                    Text(AppTranslations.t('plannerTitle', lang), style: const TextStyle(color: AppColors.deepText, fontSize: 19, fontFamily: 'Tiro Bangla', fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(LucideIcons.x, color: AppColors.muted, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(AppTranslations.t('plannerSub', lang), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 16),

                // Date
                Text(AppTranslations.t('forDate', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
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
                        Text(UiUtils.formatDate(_selectedDate, lang), style: const TextStyle(color: AppColors.ink, fontSize: 14)),
                        const Icon(LucideIcons.calendarDays, color: AppColors.ink, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Text
                Text(AppTranslations.t('plannerTitle', lang), style: const TextStyle(fontFamily: 'Hind Siliguri', color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: 4,
                    minLines: 3,
                    style: const TextStyle(color: AppColors.ink, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppTranslations.t('planPlaceholder', lang),
                      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        : Text(AppTranslations.t('savePlan', lang), style: const TextStyle(color: Color(0xFF3B1E00), fontSize: 14, fontWeight: FontWeight.bold)),
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
