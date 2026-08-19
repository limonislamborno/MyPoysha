import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../services/auth_service.dart';
import '../../main.dart'; // To navigate to InitialAuthWrapper
import '../../providers/dashboard_provider.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _setPassword() async {
    final lang = ref.read(languageProvider);
    if (_passController.text.length < 6) {
      setState(() => _error = AppTranslations.t('errPassShort', lang));
      return;
    }
    if (_passController.text != _confirmPassController.text) {
      setState(() => _error = AppTranslations.t('errPassMismatch', lang));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      await ref.read(authServiceProvider).updatePassword(_passController.text);
      
      ref.invalidate(dashboardProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(loansProvider);
      ref.invalidate(plansProvider);
      ref.invalidate(monthlyTrendProvider);
      ref.invalidate(categoryBreakdownProvider);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const InitialAuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _error = "পাসওয়ার্ড সেট করতে সমস্যা হয়েছে।";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A2470), Color(0xFF7A3B8F), Color(0xFFB25A7A), Color(0xFFE8935C)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 24, top: 24, bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Icon(LucideIcons.wallet, color: AppColors.gold, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          AppTranslations.t('appName', lang),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppTranslations.t('setPassTitle', lang), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(AppTranslations.t('setPassSub', lang), style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppTranslations.t('newPassword', lang), style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passController,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '••••••••',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(LucideIcons.lock, color: Colors.black26),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(AppTranslations.t('confirmPassword', lang), style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPassController,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '••••••••',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(LucideIcons.lock, color: Colors.black26),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _setPassword,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: AppColors.ink)
                                : Text(AppTranslations.t('resetBtn', lang), style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
