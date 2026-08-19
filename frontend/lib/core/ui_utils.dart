import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class UiUtils {
  static const Map<String, String> _bnDigits = {
    '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
    '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
  };

  static String toBangla(String input, String lang) {
    if (lang != 'bn') return input;
    String result = input;
    _bnDigits.forEach((en, bn) {
      result = result.replaceAll(en, bn);
    });
    return result;
  }

  static String formatAmount(dynamic num, String lang) {
    final value = double.tryParse(num.toString()) ?? 0.0;
    final formatted = '৳${NumberFormat("#,##0", "en_US").format(value)}';
    return toBangla(formatted, lang);
  }

  static String formatDate(dynamic date, String lang, {String format = 'MM/dd/yyyy'}) {
    if (date == null) return '';
    DateTime? dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      dt = DateTime.tryParse(date);
    }
    if (dt == null) return '';
    final formatted = DateFormat(format).format(dt);
    return toBangla(formatted, lang);
  }

  static void showSuccessPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.income.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.checkCircle2, color: AppColors.income, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontFamily: 'Hind Siliguri',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

