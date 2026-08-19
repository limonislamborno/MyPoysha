import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants.dart';
import '../../widgets/glass_container.dart';
import '../../services/auth_service.dart';
import '../../core/translations.dart';
import 'otp_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      await ref.read(authServiceProvider).sendOtp(_emailController.text.trim());
      // Navigate to OTP Screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP পাঠানো হয়েছে')));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = "OTP পাঠাতে সমস্যা হয়েছে।";
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
                    Text(AppTranslations.t('signupTitle', lang), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(AppTranslations.t('signupSub', lang), style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                        Text(AppTranslations.t('emailLabel', lang), style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'you@example.com',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(LucideIcons.mail, color: Colors.black26),
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
                            onPressed: _isLoading ? null : _sendOtp,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: AppColors.ink)
                                : Text(AppTranslations.t('sendOtp', lang), style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Go back to login
                            },
                            child: Text.rich(
                              TextSpan(
                                text: '${AppTranslations.t('haveAccount', lang)} ',
                                style: const TextStyle(color: AppColors.muted),
                                children: [
                                  TextSpan(text: AppTranslations.t('loginBtn', lang), style: const TextStyle(color: AppColors.deepText, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
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
