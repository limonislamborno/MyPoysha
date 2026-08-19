import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getDashboard();
});

final transactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getTransactions();
});

final loansProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getLoans();
});

final plansProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getPlans();
});

final monthlyTrendProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getMonthlyTrend();
});

final categoryBreakdownProvider = FutureProvider.family<List<dynamic>, String>((ref, month) async {
  final api = ref.read(apiServiceProvider);
  return await api.getCategoryBreakdown(month);
});
