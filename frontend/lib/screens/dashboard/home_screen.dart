import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/translations.dart';
import '../../core/ui_utils.dart';
import '../../widgets/glass_container.dart';
import '../../services/auth_service.dart';
import '../../providers/dashboard_provider.dart';
import 'transactions_screen.dart';
import 'loans_screen.dart';
import 'reports_screen.dart';
import 'planner_screen.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/add_loan_sheet.dart';
import '../../widgets/add_plan_sheet.dart';
import '../auth/login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _currentTab = 'home';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildBody() {
    switch (_currentTab) {
      case 'txns':
        return const TransactionsScreen();
      case 'loans':
        return const LoansScreen();
      case 'reports':
        return const ReportsScreen();
      case 'planner':
        return const PlannerScreen();
      case 'home':
      default:
        return _DashboardTab(onNavigate: (tab) => setState(() => _currentTab = tab));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final userEmail = ref.watch(authServiceProvider).currentUser?.email ?? AppTranslations.t('demoUser', lang);

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(20, 9, 32, 0.85),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: AppColors.gold, size: 18),
                      const SizedBox(width: 8),
                      Text(AppTranslations.t('appName', lang), style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(AppTranslations.t('loggedInAs', lang), style: const TextStyle(fontSize: 11, color: Color(0xFFD6C3E8))),
                  Text(userEmail, style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildDrawerItem(LucideIcons.home, 'navHome', 'home', lang),
                  _buildDrawerItem(LucideIcons.arrowLeftRight, 'navTxns', 'txns', lang),
                  _buildDrawerItem(LucideIcons.handCoins, 'navLoans', 'loans', lang),
                  _buildDrawerItem(LucideIcons.pieChart, 'navReports', 'reports', lang),
                  _buildDrawerItem(LucideIcons.notebookPen, 'navPlanner', 'planner', lang),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: ListTile(
                leading: const Icon(LucideIcons.logOut, color: Color(0xFFFF9B8E), size: 20),
                title: Text(AppTranslations.t('logout', lang), style: const TextStyle(color: Color(0xFFFF9B8E), fontSize: 14)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () async {
                  await ref.read(authServiceProvider).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1240), Color(0xFF5A2A6B), Color(0xFF8F3F63), Color(0xFFC9683F)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.menu, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const SizedBox(width: 12),
                        Text(AppTranslations.t('appName', lang), style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 0.3, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(languageProvider.notifier).state = lang == 'bn' ? 'en' : 'bn';
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.languages, color: Color(0xFFF2E4C6), size: 14),
                            const SizedBox(width: 4),
                            Text(lang == 'bn' ? 'EN' : 'বাং', style: const TextStyle(color: Color(0xFFF2E4C6), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 74,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(20, 9, 32, 0.65), // Dark glass
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(LucideIcons.home, 'home', 'navHome', lang),
                _buildBottomNavItem(LucideIcons.arrowLeftRight, 'txns', 'navTxns', lang),
                _buildBottomNavItem(LucideIcons.handCoins, 'loans', 'navLoans', lang),
                _buildBottomNavItem(LucideIcons.pieChart, 'reports', 'navReports', lang),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (_currentTab == 'home' || _currentTab == 'txns' || _currentTab == 'loans' || _currentTab == 'planner')
          ? Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.gold, Color(0xFFF0C563)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(LucideIcons.plus, color: Color(0xFF3B1E00), size: 24),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      if (_currentTab == 'loans') return const AddLoanSheet();
                      if (_currentTab == 'planner') return const AddPlanSheet();
                      return const AddTransactionSheet();
                    },
                  );
                },
              ),
            )
          : null,
    );
  }

  Widget _buildDrawerItem(IconData icon, String translationKey, String tabKey, String lang) {
    final isActive = _currentTab == tabKey;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.gold : const Color(0xFFEDE3F5), size: 20),
      title: Text(AppTranslations.t(translationKey, lang), style: TextStyle(color: isActive ? AppColors.gold : const Color(0xFFEDE3F5), fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      tileColor: isActive ? AppColors.gold.withOpacity(0.18) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        setState(() => _currentTab = tabKey);
        Navigator.pop(context); // Close drawer
      },
    );
  }

  Widget _buildBottomNavItem(IconData icon, String tabKey, String translationKey, String lang) {
    final isActive = _currentTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tabKey),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        height: 74,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppColors.gold : Colors.white60, size: 22),
            const SizedBox(height: 4),
            Text(
              AppTranslations.t(translationKey, lang),
              style: TextStyle(
                color: isActive ? AppColors.gold : Colors.white60,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  final Function(String) onNavigate;

  const _DashboardTab({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      data: (data) {
        final double pocket = double.tryParse(data['pocketBalance'].toString()) ?? 0.0;
        final double income = double.tryParse(data['totalIncome'].toString()) ?? 0.0;
        final double expense = double.tryParse(data['totalExpense'].toString()) ?? 0.0;
        final double lentDue = double.tryParse(data['totalLentDue'].toString()) ?? 0.0;
        final double borrowDue = double.tryParse(data['totalBorrowedDue'].toString()) ?? 0.0;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Circular Gauge
              Container(
                width: 176,
                height: 176,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldSoft, width: 2, style: BorderStyle.solid),
                ),
                child: GlassContainer(
                  borderRadius: 100,
                  padding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 62,
                          startDegreeOffset: 270,
                          sections: [
                            PieChartSectionData(value: pocket > 0 ? pocket : 1, color: AppColors.gold, radius: 20, showTitle: false),
                            PieChartSectionData(value: expense > 0 ? expense : 0, color: Colors.white30, radius: 20, showTitle: false),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppTranslations.t('inPocket', lang), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(UiUtils.formatAmount(pocket, lang), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 4 Stat Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(AppTranslations.t('statIncome', lang), income, AppColors.income, LucideIcons.arrowUpRight, lang)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(AppTranslations.t('statExpense', lang), expense, AppColors.expense, LucideIcons.arrowDownRight, lang)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(AppTranslations.t('statLent', lang), lentDue, AppColors.lent, LucideIcons.handCoins, lang)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(AppTranslations.t('statBorrowed', lang), borrowDue, AppColors.borrow, LucideIcons.handCoins, lang)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppTranslations.t('recentTxns', lang), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => onNavigate('txns'),
                      child: Text(AppTranslations.t('viewAll', lang), style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Recent Transactions List (placeholder for now until we build the TxnRow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(AppTranslations.t('noTxn', lang), style: const TextStyle(color: Colors.white70)),
                  ),
                ),
              ),
              const SizedBox(height: 120), // Padding to clear bottom navigation bar and FAB
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildStatCard(String label, double value, Color color, IconData icon, String lang) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(UiUtils.formatAmount(value, lang), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk')),
        ],
      ),
    );
  }
}
