import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../services/auth_service.dart';
import 'set_password_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  final bool isReset;
  const OtpScreen({super.key, required this.email, this.isReset = false});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      await ref.read(authServiceProvider).verifyOtp(widget.email, _otpController.text.trim(), isReset: widget.isReset);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SetPasswordScreen()));
      }
    } catch (e) {
      setState(() {
        _error = "OTP যাচাই ব্যর্থ হয়েছে। সঠিক কোড দিন।";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      if (widget.isReset) {
        await ref.read(authServiceProvider).resetPasswordForEmail(widget.email);
      } else {
        await ref.read(authServiceProvider).sendOtp(widget.email);
      }
      if (mounted) {
        final lang = ref.read(languageProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTranslations.t('otpResent', lang))));
      }
    } catch (e) {
      // Ignore
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
                    Text(AppTranslations.t('otpTitle', lang), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('${widget.email} ${AppTranslations.t('otpSubtitlePrefix', lang)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                        Text(AppTranslations.t('otpCode', lang), style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          style: const TextStyle(color: AppColors.ink, letterSpacing: 8, fontWeight: FontWeight.bold, fontSize: 24),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '12345678',
                            hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 8, fontSize: 24),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            counterText: "",
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
                            onPressed: _isLoading ? null : _verifyOtp,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: AppColors.ink)
                                : Text(AppTranslations.t('verify', lang), style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: _resendOtp,
                            child: Text.rich(
                              TextSpan(
                                text: '${AppTranslations.t('noCode', lang)} ',
                                style: const TextStyle(color: AppColors.muted),
                                children: [
                                  TextSpan(text: AppTranslations.t('resend', lang), style: const TextStyle(color: AppColors.deepText, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          AppTranslations.t('demoOtp', lang),
                          style: const TextStyle(color: AppColors.muted, fontSize: 12, fontStyle: FontStyle.italic),
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
