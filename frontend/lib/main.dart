import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/auth/login_screen.dart';
import 'screens/dashboard/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://ihnvsbjayzebmtouravh.supabase.co',
    anonKey: 'sb_publishable_-LNf1Y1z5sexOzmDg1JFqw_eZ1SZH8n',
  );

  runApp(
    const ProviderScope(
      child: MyPoyshaApp(),
    ),
  );
}

class MyPoyshaApp extends StatelessWidget {
  const MyPoyshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPoysha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.hindSiliguriTextTheme(),
      ),
      home: const InitialAuthWrapper(),
    );
  }
}

class InitialAuthWrapper extends ConsumerWidget {
  const InitialAuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = Supabase.instance.client.auth.currentSession;
    
    // Simple routing based on session
    if (session != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
