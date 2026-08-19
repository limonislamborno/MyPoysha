import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> sendOtp(String email) async {
    await _supabase.auth.signInWithOtp(email: email);
  }

  Future<AuthResponse> verifyOtp(String email, String token, {bool isReset = false}) async {
    if (isReset) {
      return await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
    }
    
    try {
      return await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.magiclink, // For returning users
      );
    } catch (e) {
      // If magiclink fails, it might be a brand new user, so the token is a signup token
      return await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup, // For new users
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
