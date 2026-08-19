import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          // Use 127.0.0.1 for Web/Desktop, 10.0.2.2 for Android Emulator
          baseUrl: kIsWeb ? 'http://127.0.0.1:8080/api' : 'http://10.0.2.2:8080/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        return handler.next(options);
      },
    ));
  }

  // Dashboard API
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dio.get('/dashboard');
    return response.data;
  }

  // Transactions API
  Future<List<dynamic>> getTransactions() async {
    final response = await _dio.get('/transactions');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final response = await _dio.post('/transactions', data: data);
    return response.data;
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/transactions/$id');
  }

  // Loans API
  Future<List<dynamic>> getLoans() async {
    final response = await _dio.get('/loans');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createLoan(Map<String, dynamic> data) async {
    final response = await _dio.post('/loans', data: data);
    return response.data;
  }

  Future<void> recordLoanPayment(String loanId, Map<String, dynamic> data) async {
    await _dio.post('/loans/$loanId/payments', data: data);
  }

  // Plans API
  Future<List<dynamic>> getPlans() async {
    final response = await _dio.get('/plans');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> data) async {
    final response = await _dio.post('/plans', data: data);
    return response.data;
  }

  Future<void> deletePlan(String id) async {
    await _dio.delete('/plans/$id');
  }

  // Reports API
  Future<List<dynamic>> getMonthlyTrend({int months = 6}) async {
    final response = await _dio.get('/reports/monthly-trend', queryParameters: {'months': months});
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getCategoryBreakdown(String month) async {
    final response = await _dio.get('/reports/category-breakdown', queryParameters: {'month': month});
    return response.data as List<dynamic>;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
